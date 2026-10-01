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

--[[
  Lanzar un proceso en Windows sin que aparezca una consola.

  `ShellExecute` con SW_HIDE no basta: si la consola por defecto es Windows
  Terminal, re-aloja el proceso en una pestaña nueva y la ventana sale igual.
  Lo único que Windows respeta siempre es crear el proceso con
  CREATE_NO_WINDOW, que es lo que hace esto.
]]
if ffi_ok and esWindows then
  pcall(ffi.cdef, [[
    typedef struct {
      unsigned long  cb;
      char          *lpReserved;
      char          *lpDesktop;
      char          *lpTitle;
      unsigned long  dwX, dwY, dwXSize, dwYSize;
      unsigned long  dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags;
      unsigned short wShowWindow, cbReserved2;
      unsigned char *lpReserved2;
      void          *hStdInput, *hStdOutput, *hStdError;
    } STARTUPINFOA;

    typedef struct {
      void *hProcess, *hThread;
      unsigned long dwProcessId, dwThreadId;
    } PROCESS_INFORMATION;

    int CreateProcessA(const char *app, char *cmd, void *procAttr, void *threadAttr,
                       int heredar, unsigned long flags, void *entorno, const char *dir,
                       STARTUPINFOA *si, PROCESS_INFORMATION *pi);
    unsigned long WaitForSingleObject(void *handle, unsigned long ms);
    int CloseHandle(void *handle);
  ]])
end

local function temporal()
  local dir = os.getenv("TEMP") or os.getenv("TMP") or "."
  return dir .. "\\tm-reto-" .. tostring(math.random(1e9)) .. ".json"
end

local CREATE_NO_WINDOW = 0x08000000

--- `curl` sin ventana, de verdad. Devuelve el cuerpo, o nil y el motivo.
local function porCurlOculto(url)
  local salida = temporal()
  local kernel32 = ffi.load("kernel32")

  local linea = 'cmd.exe /c curl -sSL --max-time 15 "' .. url .. '" -o "' .. salida .. '"'
  -- CreateProcess escribe sobre la línea de comandos, así que tiene que ser un
  -- buffer mutable y no una cadena de Lua.
  local buf = ffi.new("char[?]", #linea + 1)
  ffi.copy(buf, linea)

  local si = ffi.new("STARTUPINFOA")
  si.cb = ffi.sizeof("STARTUPINFOA")
  local pi = ffi.new("PROCESS_INFORMATION")

  local ok = kernel32.CreateProcessA(nil, buf, nil, nil, 0, CREATE_NO_WINDOW, nil, nil, si, pi)
  if ok == 0 then return nil, "no pude lanzar curl" end

  kernel32.WaitForSingleObject(pi.hProcess, 20000)
  kernel32.CloseHandle(pi.hProcess)
  kernel32.CloseHandle(pi.hThread)

  local f = io.open(salida, "r")
  if not f then return nil, "curl no dejó respuesta. ¿Está instalado? (`curl --version`)" end
  local cuerpo = f:read("*a")
  f:close()
  os.remove(salida)
  if not cuerpo or cuerpo == "" then return nil, "el servidor no respondió a tiempo" end
  return cuerpo
end

--- `curl` por tubería. En macOS y Linux no abre ninguna ventana, así que aquí no
--- hace falta el rodeo de arriba.
local function porCurl(url)
  local tuberia = io.popen('curl -sSL --max-time 15 "' .. url .. '"', "r")
  if not tuberia then return nil, "no pude lanzar curl" end
  local cuerpo = tuberia:read("*a")
  tuberia:close()
  if not cuerpo or cuerpo == "" then
    return nil, "sin respuesta. ¿Tienes `curl` instalado y red? (`curl --version`)"
  end
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
