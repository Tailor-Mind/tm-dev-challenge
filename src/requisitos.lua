--[[
  El goteo de requisitos.

  Los requisitos no están en este repo: se piden al servidor, se sortean por
  candidato y se abren con el reloj. No se pueden pedir por adelantado y no hay
  forma de pedir más.

  Todo el tráfico va por un hilo aparte (`hilo_red.lua`), así que el juego nunca
  se congela esperando. Una petición tarda uno o dos segundos; pararlo todo cada
  vez se nota, y encima estropea la sensación del salto, que es justo lo que
  algún requisito te va a pedir ajustar.

  Si no hay red, la partida sigue con lo último que bajó y el panel lo dice.
]]

local json = require("src.json")

local R = {
  url = nil, run = nil, clave = nil, minutos = 0, lista = {}, pendientes = 0,
  base = 30, prorroga = 10, decision = "", error = nil, via = nil,
  estado = "sin partida",   -- sin partida | abriendo | en marcha
  ultima = 0,
}

local MARCA = ".tm-run"
local hilo, pedidos, respuestas
local vistos = {}

-- ------------------------------------------------------------------ el hilo

local function arrancarHilo()
  if hilo then return end
  hilo = love.thread.newThread("src/hilo_red.lua")
  pedidos = love.thread.getChannel("tm_pedidos")
  respuestas = love.thread.getChannel("tm_respuestas")
  hilo:start()
end

local function pedir(url, etiqueta)
  arrancarHilo()
  pedidos:push({ url = url, etiqueta = etiqueta })
end

-- --------------------------------------------------------------- el fichero

local function anotar(linea)
  local f = io.open("REQUISITOS-RECIBIDOS.md", "a")
  if not f then return end
  f:write(linea, "\n")
  f:close()
end

local function anotarNuevos(lista, minutos)
  for _, r in ipairs(lista or {}) do
    if not vistos[r.id] then
      vistos[r.id] = true
      anotar(("\n## [%s] %s\n\n*llegó en el minuto %d · %s*\n\n%s")
        :format(r.id, r.titulo, minutos, r.tipo or "feature", r.cuerpo))
    end
  end
end

local function recordar()
  local f = io.open(MARCA, "w")
  if not f then return end
  f:write((R.run or "") .. "\n" .. (R.clave or ""))
  f:close()
end

-- ------------------------------------------------------------- las acciones

local function base()
  return R.url .. "?accion="
end

--- Abre la partida. Vuelve en cuanto manda la petición: la respuesta llega por
--- el hilo y se recoge en `refrescar`.
function R.empezar(url, candidato, clave)
  R.url, R.clave, R.estado = url, clave, "abriendo"
  pedir(base() .. "empezar&candidato=" .. candidato .. "&clave=" .. (clave or ""), "empezar")
end

--- Retoma la partida apuntada en `.tm-run`, si la hay.
function R.reanudar(url)
  local f = io.open(MARCA, "r")
  if not f then return false end
  local texto = f:read("*a") or ""
  f:close()
  local id, clave = texto:match("^%s*([^\n]*)\n?(.*)$")
  if not id or id == "" then return false end

  R.url, R.run, R.clave, R.estado = url, id, (clave or ""):gsub("%s", ""), "en marcha"
  pedir(base() .. "estado&run=" .. id, "estado")
  return true
end

function R.sellarPlan(hoja, noCabe)
  if not R.run then return false end
  local esc = function (t)
    return (t or ""):gsub("[^%w%sáéíóúñÁÉÍÓÚÑ=;,.:¿?¡!%-]", ""):gsub("%s+", "%%20")
  end
  pedir(base() .. "plan&run=" .. R.run .. "&hoja=" .. esc(hoja) ..
        "&cuando_no_cabe=" .. esc(noCabe), "ack")
  return true
end

function R.decidir(eleccion, motivo)
  if not R.run then return false end
  local limpio = (motivo or ""):gsub("[^%w%sáéíóúñÁÉÍÓÚÑ,.:;¿?¡!%-]", ""):gsub("%s+", "%%20")
  R.decision = eleccion
  pedir(base() .. "decidir&run=" .. R.run .. "&eleccion=" .. eleccion ..
        "&motivo=" .. limpio, "ack")
  return true
end

-- ------------------------------------------------------------ las respuestas

local function aplicar(etiqueta, d)
  if etiqueta == "empezar" then
    R.run, R.estado = d.runId, "en marcha"
    R.base, R.prorroga = d.base or 30, d.prorroga or 10
    R.lista, R.minutos, R.pendientes = d.requisitos or {}, d.minutos or 0, d.pendientes or 0
    anotar(("# Requisitos recibidos\n\npartida `%s` · abierta el %s\n")
      :format(R.run, os.date("!%Y-%m-%d %H:%M UTC")))
    anotarNuevos(R.lista, R.minutos)
    recordar()
  elseif etiqueta == "estado" then
    R.estado = "en marcha"
    R.lista = d.requisitos or R.lista
    R.minutos, R.pendientes = d.minutos or R.minutos, d.pendientes or 0
    R.base, R.prorroga = d.base or R.base, d.prorroga or R.prorroga
    R.decision = d.decision or R.decision
    anotarNuevos(R.lista, R.minutos)
  end
end

--- Recoge lo que haya traído el hilo y, cada 20 s, vuelve a preguntar.
function R.refrescar(dt)
  if respuestas then
    local msg = respuestas:pop()
    while msg do
      if msg.via then R.via = msg.via end
      if not msg.cuerpo then
        R.error = msg.error or "sin respuesta del servidor"
        if msg.etiqueta == "empezar" then R.estado = "sin partida" end
      else
        local d, err = json.decodificar(msg.cuerpo)
        if not d then
          R.error = "no entendí la respuesta: " .. tostring(err)
          if msg.etiqueta == "empezar" then R.estado = "sin partida" end
        elseif d.ok == false then
          R.error = d.error or "el servidor dijo que no"
          if msg.etiqueta == "empezar" then R.estado = "sin partida" end
        else
          R.error = nil
          aplicar(msg.etiqueta, d)
        end
      end
      msg = respuestas:pop()
    end
  end

  if R.estado ~= "en marcha" or not R.run then return end
  R.ultima = R.ultima + dt
  if R.ultima < 20 then return end
  R.ultima = 0
  pedir(base() .. "siguiente&run=" .. R.run, "estado")
end

return R
