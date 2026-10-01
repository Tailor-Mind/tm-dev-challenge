--[[
  El goteo de requisitos.

  Los requisitos no están en este repo. Se piden a un endpoint nuestro, se
  sortean por candidato y se abren con el reloj. No se pueden pedir por
  adelantado y no hay forma de pedir más: la prueba no es hacerlos todos.

  Si no hay red, el juego sigue: se queda con lo último que bajó y lo dice.
]]

local https_ok, https = pcall(require, "https")

local R = { url = nil, run = nil, minutos = 0, lista = {}, pendientes = 0, error = nil, ultima = 0,
            base = 30, prorroga = 10, decision = "" }

local function pedir(url)
  if not https_ok then
    return nil, "esta versión de LÖVE no trae el módulo https (hace falta 11.4+)"
  end
  local code, cuerpo = https.request(url)
  if code ~= 200 then return nil, "el servidor respondió " .. tostring(code) end
  return cuerpo
end

--- Decodificador mínimo: lo justo para leer la respuesta del endpoint.
local function json(txt)
  local f = load("return " .. txt
    :gsub('"(%w[%w_]*)"%s*:', '["%1"]=')
    :gsub('":', '"]=')          -- claves con espacios o acentos
    :gsub('{%s*"', '{["')
    :gsub('null', 'nil'))
  local ok, v = pcall(f)
  return ok and v or nil
end

--- Deja constancia en el repo de qué llegó y cuándo. Va en la entrega.
local function anotar(linea)
  local f = io.open("REQUISITOS-RECIBIDOS.md", "a")
  if not f then return end
  f:write(linea, "\n")
  f:close()
end

local vistos = {}

local function anotarNuevos(lista, minutos)
  for _, r in ipairs(lista or {}) do
    if not vistos[r.id] then
      vistos[r.id] = true
      anotar(("\n## [%s] %s\n\n*llegó en el minuto %d · %s*\n\n%s")
        :format(r.id, r.titulo, minutos, r.tipo or "feature", r.cuerpo))
    end
  end
end

--- La partida vive en disco: reiniciar el juego no abre otra ni pierde el reloj.
local MARCA = ".tm-run"

function R.recordar()
  local f = io.open(MARCA, "w")
  if not f then return end
  f:write(R.run or "")
  f:close()
end

function R.reanudar(url)
  local f = io.open(MARCA, "r")
  if not f then return false end
  local id = (f:read("*a") or ""):gsub("%s", "")
  f:close()
  if id == "" then return false end

  R.url, R.run = url, id
  local cuerpo = pedir(url .. "?accion=estado&run=" .. id)
  if not cuerpo then R.error = "no pude hablar con el servidor; sigo con lo que hay"; return true end
  local d = json(cuerpo)
  if d and d.ok then
    R.lista, R.minutos, R.pendientes = d.requisitos or {}, d.minutos or 0, d.pendientes or 0
    R.base, R.prorroga, R.decision = d.base or 30, d.prorroga or 10, d.decision or ""
    for _, r in ipairs(R.lista) do vistos[r.id] = true end   -- no se vuelven a anotar
  end
  return true
end

function R.empezar(url, candidato)
  R.url = url
  local cuerpo, err = pedir(url .. "?accion=empezar&candidato=" .. candidato)
  if not cuerpo then R.error = err; return false end
  local d = json(cuerpo)
  if not d or not d.ok then R.error = "respuesta rara del servidor"; return false end
  R.run, R.lista, R.minutos, R.pendientes = d.runId, d.requisitos or {}, d.minutos or 0, 0
  R.base, R.prorroga = d.base or 30, d.prorroga or 10
  R.error = nil
  -- El reloj arranca aquí y queda escrito. Lo que hubiera antes en el repo es
  -- preparación; lo que cuenta empieza en este minuto, y así vale lo mismo
  -- clonar hoy que clonar la semana pasada.
  anotar(("# Requisitos recibidos\n\npartida `%s` · abierta el %s\n")
    :format(R.run, os.date("!%Y-%m-%d %H:%M UTC")))
  anotarNuevos(R.lista, 0)
  R.recordar()
  return true
end

--- Se llama sola cada 30 s desde `main.lua`. Barata y sin bloquear la partida.
function R.refrescar(dt)
  R.ultima = R.ultima + dt
  if not R.run or R.ultima < 30 then return end
  R.ultima = 0
  local cuerpo, err = pedir(R.url .. "?accion=siguiente&run=" .. R.run)
  if not cuerpo then R.error = err; return end
  local d = json(cuerpo)
  if d and d.ok then
    R.lista, R.minutos, R.pendientes = d.requisitos or R.lista, d.minutos or R.minutos, d.pendientes or 0
    R.base, R.prorroga = d.base or R.base, d.prorroga or R.prorroga
    R.error = nil
    anotarNuevos(R.lista, R.minutos)
  end
end

--- Manda la decisión del minuto 30. Si no hay red, el juego sigue igual: la
--- decisión ya quedó escrita en REQUISITOS-RECIBIDOS.md, que es lo que se entrega.
function R.decidir(eleccion, motivo)
  if not R.run then return false end
  local limpio = (motivo or ""):gsub("[^%w%sáéíóúñÁÉÍÓÚÑ,.:;¿?¡!%-]", ""):gsub("%s+", "%%20")
  local cuerpo = pedir(R.url .. "?accion=decidir&run=" .. R.run ..
    "&eleccion=" .. eleccion .. "&motivo=" .. limpio)
  R.decision = eleccion
  return cuerpo ~= nil
end

--- Sella el plan en el servidor. Si no hay red, no pasa nada: el plan ya quedó
--- escrito en PLAN-SELLADO.md, que es lo que se entrega.
function R.sellarPlan(hoja, noCabe)
  if not R.run then return false end
  local esc = function (t)
    return (t or ""):gsub("[^%w%sáéíóúñÁÉÍÓÚÑ=;,.:¿?¡!%-]", ""):gsub("%s+", "%%20")
  end
  return pedir(R.url .. "?accion=plan&run=" .. R.run ..
    "&hoja=" .. esc(hoja) .. "&cuando_no_cabe=" .. esc(noCabe)) ~= nil
end

return R
