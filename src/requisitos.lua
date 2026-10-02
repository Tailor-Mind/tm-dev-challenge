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
  -- El reloj lo lleva el servidor, pero entre consulta y consulta corre aquí:
  -- un número que solo se mueve cada veinte segundos no es un cronómetro.
  --
  -- `sincronizado` existe porque al reanudar no sabemos nada hasta que llega la
  -- primera respuesta: contar desde cero mientras tanto enseñaría 00:00:03 en una
  -- partida de media hora, y un reloj que miente es peor que no tener reloj.
  segundos = 0, empezadoEn = nil, horaInicio = nil, sincronizado = false,
  -- El acuse de la decisión: nil mientras no se ha mandado, luego "enviando",
  -- "recibido" o "falló". Decir "entregado" sin mirar si llegó es mentir en la
  -- única pantalla donde no se puede mentir.
  acuse = nil, ultimaDecision = nil,
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
  R.acuse = "enviando"
  R.ultimaDecision = { eleccion = eleccion, motivo = limpio }
  pedir(base() .. "decidir&run=" .. R.run .. "&eleccion=" .. eleccion ..
        "&motivo=" .. limpio, "decision")
  return true
end

--- Volver a mandar la decisión si la primera no llegó. Se ofrece en pantalla:
--- nadie debería quedarse con un "falló" y sin forma de arreglarlo.
function R.reintentarDecision()
  local d = R.ultimaDecision
  if not d or not R.run then return false end
  R.acuse = "enviando"
  pedir(base() .. "decidir&run=" .. R.run .. "&eleccion=" .. d.eleccion ..
        "&motivo=" .. d.motivo, "decision")
  return true
end

-- ------------------------------------------------------------ las respuestas

--- "2026-10-01T19:33:23.660Z" → la hora local en HH:MM, para enseñar cuándo
--- empezó. Si viene raro, se deja en blanco antes que inventar una hora.
local function horaDe(iso)
  if type(iso) ~= "string" then return nil end
  local a, m, d, h, mi, s = iso:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not a then return nil end
  local utc = os.time({ year = tonumber(a), month = tonumber(m), day = tonumber(d),
                        hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) })
  -- `os.time` interpreta la tabla como hora local, así que se corrige la
  -- diferencia con UTC para que lo que se enseña sea la hora del reloj de pared.
  local desfase = os.difftime(os.time(), os.time(os.date("!*t")))
  return os.date("%H:%M", utc + desfase)
end

local function aplicar(etiqueta, d)
  if etiqueta == "empezar" then
    R.run, R.estado = d.runId, "en marcha"
    R.base, R.prorroga = d.base or 30, d.prorroga or 10
    R.lista, R.minutos, R.pendientes = d.requisitos or {}, d.minutos or 0, d.pendientes or 0
    R.empezadoEn = d.empezadoEn or R.empezadoEn
    R.horaInicio = horaDe(R.empezadoEn) or R.horaInicio
    R.segundos = (d.minutos or 0) * 60
    R.sincronizado = true
    anotar(("# Requisitos recibidos\n\npartida `%s` · abierta el %s\n")
      :format(R.run, os.date("!%Y-%m-%d %H:%M UTC")))
    anotarNuevos(R.lista, R.minutos)
    recordar()
  elseif etiqueta == "estado" then
    R.estado = "en marcha"
    R.lista = d.requisitos or R.lista
    R.minutos, R.pendientes = d.minutos or R.minutos, d.pendientes or 0
    R.empezadoEn = d.empezadoEn or R.empezadoEn
    R.horaInicio = horaDe(R.empezadoEn) or R.horaInicio
    -- El servidor manda minutos enteros; se resincroniza sin perder los
    -- segundos que ya iban contados dentro de ese minuto.
    if not R.sincronizado or math.abs(R.segundos - (d.minutos or 0) * 60) > 70 then
      R.segundos = (d.minutos or 0) * 60
    end
    R.sincronizado = true
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
        if msg.etiqueta == "decision" then R.acuse = "falló" end
      else
        local d, err = json.decodificar(msg.cuerpo)
        if not d then
          R.error = "no entendí la respuesta: " .. tostring(err)
          if msg.etiqueta == "empezar" then R.estado = "sin partida" end
          if msg.etiqueta == "decision" then R.acuse = "falló" end
        elseif d.ok == false then
          R.error = d.error or "el servidor dijo que no"
          if msg.etiqueta == "empezar" then R.estado = "sin partida" end
          if msg.etiqueta == "decision" then R.acuse = "falló" end
          -- Una partida que el servidor no conoce no se arregla reintentando:
          -- se deja de preguntar y se dice qué hacer, en vez de insistir cada
          -- veinte segundos con un error que parece de red y no lo es.
          if (d.error or ""):find("no conozco esa partida") then
            R.estado, R.run = "sin partida", nil
            R.error = "esa partida ya no existe. Borra `.tm-run` y vuelve a abrir " ..
                      "con `love . --run TU@CORREO --clave TU_CLAVE`"
          end
        else
          R.error = nil
          if msg.etiqueta == "decision" then R.acuse = "recibido" end
          aplicar(msg.etiqueta, d)
        end
      end
      msg = respuestas:pop()
    end
  end

  if R.estado ~= "en marcha" or not R.run then return end

  -- El cronómetro corre aquí entre consulta y consulta, pero solo después de
  -- saber por dónde va: antes de la primera respuesta no hay nada que contar.
  if R.sincronizado then
    R.segundos = R.segundos + dt
    R.minutos = math.floor(R.segundos / 60)
  end

  R.ultima = R.ultima + dt
  if R.ultima < 20 then return end
  R.ultima = 0
  pedir(base() .. "siguiente&run=" .. R.run, "estado")
end

--- El cronómetro, en HH:MM:SS.
function R.reloj()
  local s = math.max(0, math.floor(R.segundos))
  return ("%02d:%02d:%02d"):format(math.floor(s / 3600), math.floor(s % 3600 / 60), s % 60)
end

--- Lo que falta para que se acabe, en MM:SS. El límite crece si pediste la
--- prórroga en el minuto 30.
function R.restante()
  local limite = (R.base + (R.decision == "seguir" and R.prorroga or 0)) * 60
  local s = math.floor(limite - R.segundos)
  if s <= 0 then return "se acabó" end
  return ("quedan %02d:%02d"):format(math.floor(s / 60), s % 60)
end

--- Un requisito en Markdown, listo para pegárselo a un agente. Sin número, van
--- todos; con número, solo ese — que es como se trabaja de verdad: de uno en uno.
function R.comoTexto(n)
  if #R.lista == 0 then return "" end

  if n then
    local r = R.lista[n]
    if not r then return "" end
    return ("## [%s] %s\n\n%s\n"):format(r.id, r.titulo, r.cuerpo)
  end

  local partes = { "# Requisitos abiertos\n" }
  for _, r in ipairs(R.lista) do
    partes[#partes + 1] = ("## [%s] %s\n\n%s\n"):format(r.id, r.titulo, r.cuerpo)
  end
  return table.concat(partes, "\n")
end

return R
