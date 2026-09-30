--[[
  El goteo de requisitos.

  Los requisitos no están en este repo. Se piden a un endpoint nuestro, se
  sortean por candidato y se abren con el reloj. No se pueden pedir por
  adelantado y no hay forma de pedir más: la prueba no es hacerlos todos.

  Si no hay red, el juego sigue: se queda con lo último que bajó y lo dice.
]]

local https_ok, https = pcall(require, "https")

local R = { url = nil, run = nil, minutos = 0, lista = {}, pendientes = 0, error = nil, ultima = 0 }

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

function R.empezar(url, candidato)
  R.url = url
  local cuerpo, err = pedir(url .. "?accion=empezar&candidato=" .. candidato)
  if not cuerpo then R.error = err; return false end
  local d = json(cuerpo)
  if not d or not d.ok then R.error = "respuesta rara del servidor"; return false end
  R.run, R.lista, R.minutos, R.pendientes = d.runId, d.requisitos or {}, d.minutos or 0, 0
  R.error = nil
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
    R.error = nil
  end
end

return R
