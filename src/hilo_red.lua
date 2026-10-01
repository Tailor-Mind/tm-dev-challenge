--[[
  El hilo de red.

  Dos razones para que esto viva aquí y no en el bucle del juego:

  1. Una petición tarda uno o dos segundos. Congelar el juego cada vez se nota, y
     estropea justo lo que algún requisito te va a pedir ajustar: cómo se siente
     el salto.
  2. En Windows, lanzar `curl` con `io.popen` **abre una ventana de consola** cada
     vez. Aquí se lanza oculto con ShellExecute (SW_HIDE) a través de la FFI de
     LuaJIT, que LÖVE trae de serie, y la salida se recoge de un fichero temporal.

  Tres transportes, por orden: el módulo `https` de LÖVE si la compilación lo
  trae, `curl` oculto en Windows, y `curl` con `io.popen` en el resto.
]]
require("love.thread")

local pedidos = love.thread.getChannel("tm_pedidos")
local respuestas = love.thread.getChannel("tm_respuestas")

local https_ok, https = pcall(require, "https")
local ffi_ok, ffi = pcall(require, "ffi")

local esWindows = package.config:sub(1, 1) == "\\"

if ffi_ok and esWindows then
  pcall(ffi.cdef, [[
    int ShellExecuteA(void *hwnd, const char *op, const char *file,
                      const char *params, const char *dir, int show);
    void Sleep(unsigned long ms);
  ]])
end

local function temporal()
  local dir = os.getenv("TEMP") or os.getenv("TMP") or "."
  return dir .. "\\tm-reto-" .. tostring(math.random(1e9)) .. ".json"
end

--- `curl` sin ventana. Devuelve el cuerpo, o nil y el motivo.
local function porCurlOculto(url)
  local salida = temporal()
  local shell32 = ffi.load("shell32")
  local comando = '/c curl -sSL --max-time 15 "' .. url .. '" -o "' .. salida .. '"'
  -- 0 = SW_HIDE: nada de consola parpadeando encima del juego.
  shell32.ShellExecuteA(nil, "open", "cmd.exe", comando, nil, 0)

  -- No hay a quién esperar, así que se espera al fichero. 15 s de techo, igual
  -- que el que lleva curl.
  local kernel32 = ffi.load("kernel32")
  for _ = 1, 150 do
    kernel32.Sleep(100)
    local f = io.open(salida, "r")
    if f then
      local cuerpo = f:read("*a")
      f:close()
      if cuerpo and cuerpo ~= "" then
        os.remove(salida)
        return cuerpo
      end
    end
  end
  os.remove(salida)
  return nil, "la petición no respondió a tiempo"
end

local function porCurl(url)
  local tuberia = io.popen('curl -sSL --max-time 15 "' .. url .. '"', "r")
  if not tuberia then return nil, "no pude lanzar curl" end
  local cuerpo = tuberia:read("*a")
  tuberia:close()
  if not cuerpo or cuerpo == "" then return nil, "curl no devolvió nada" end
  return cuerpo
end

while true do
  local p = pedidos:demand()
  if p == "fin" then break end

  local cuerpo, err, via
  if https_ok then
    local ok, code, respuesta = pcall(https.request, p.url)
    if ok and code == 200 then cuerpo, via = respuesta, "https" end
  end
  if not cuerpo and ffi_ok and esWindows then
    local ok, c, e = pcall(porCurlOculto, p.url)
    if ok and c then cuerpo, via = c, "curl oculto" else err = (ok and e) or tostring(c) end
  end
  if not cuerpo then
    cuerpo, err = porCurl(p.url)
    if cuerpo then via = "curl" end
  end

  respuestas:push({ etiqueta = p.etiqueta, cuerpo = cuerpo, error = err, via = via })
end
