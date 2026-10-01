--[[
  El hilo de red.

  Las peticiones tardan uno o dos segundos y el juego no puede congelarse cada
  vez: en una prueba de 30 minutos, un parón por consulta se nota y encima
  arruina la sensación del salto, que es lo que algunos requisitos piden ajustar.

  Así que todo lo que habla con el servidor vive aquí. El juego empuja peticiones
  a un canal y recoge respuestas cuando están; nunca espera.

  Dos transportes, el que haya: el módulo `https` de LÖVE si la compilación lo
  trae, y si no `curl`, que viene de serie en Windows 10+, macOS y casi todo
  Linux.
]]
require("love.thread")

local pedidos = love.thread.getChannel("tm_pedidos")
local respuestas = love.thread.getChannel("tm_respuestas")

local https_ok, https = pcall(require, "https")

local function porCurl(url)
  local tuberia = io.popen('curl -sSL --max-time 15 "' .. url .. '"', "r")
  if not tuberia then return nil, "no pude lanzar curl" end
  local cuerpo = tuberia:read("*a")
  tuberia:close()
  if not cuerpo or cuerpo == "" then return nil, "curl no devolvió nada" end
  return cuerpo, nil, "curl"
end

while true do
  local p = pedidos:demand()
  if p == "fin" then break end

  local cuerpo, err, via
  if https_ok then
    local ok, code, respuesta = pcall(https.request, p.url)
    if ok and code == 200 then cuerpo, via = respuesta, "https" end
  end
  if not cuerpo then cuerpo, err, via = porCurl(p.url) end

  respuestas:push({ etiqueta = p.etiqueta, cuerpo = cuerpo, error = err, via = via })
end
