--[[
  Un decodificador de JSON pequeño y completo.

  Existe porque el apaño anterior —reescribir el texto con expresiones regulares
  y pasárselo a `load`— se rompía con la respuesta real en cuanto había una lista
  de objetos, un acento o un apóstrofo dentro de una cadena. "Casi funciona" en
  un analizador sintáctico significa "no funciona".

  Solo decodifica: no hace falta más.
]]

local json = {}

local function saltarBlancos(txt, i)
  local _, fin = txt:find("^[ \n\r\t]*", i)
  return (fin or i - 1) + 1
end

local ESCAPES = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f",
                  n = "\n", r = "\r", t = "\t" }

local leerValor

local function leerCadena(txt, i)
  -- `i` apunta a la comilla de apertura.
  local partes, j = {}, i + 1
  while j <= #txt do
    local c = txt:sub(j, j)
    if c == '"' then
      return table.concat(partes), j + 1
    elseif c == "\\" then
      local e = txt:sub(j + 1, j + 1)
      if e == "u" then
        -- \uXXXX: con lo que mandamos basta el rango básico; lo demás se deja
        -- como interrogante antes que romper el análisis entero.
        local hex = txt:sub(j + 2, j + 5)
        local n = tonumber(hex, 16) or 63
        partes[#partes + 1] = (n < 128) and string.char(n) or "?"
        j = j + 6
      else
        partes[#partes + 1] = ESCAPES[e] or e
        j = j + 2
      end
    else
      partes[#partes + 1] = c
      j = j + 1
    end
  end
  return nil, j, "cadena sin cerrar"
end

local function leerLista(txt, i)
  local salida, j = {}, saltarBlancos(txt, i + 1)
  if txt:sub(j, j) == "]" then return salida, j + 1 end
  while true do
    local v, sig, err = leerValor(txt, j)
    if err then return nil, sig, err end
    salida[#salida + 1] = v
    j = saltarBlancos(txt, sig)
    local c = txt:sub(j, j)
    if c == "," then j = saltarBlancos(txt, j + 1)
    elseif c == "]" then return salida, j + 1
    else return nil, j, "esperaba , o ] en la posición " .. j end
  end
end

local function leerObjeto(txt, i)
  local salida, j = {}, saltarBlancos(txt, i + 1)
  if txt:sub(j, j) == "}" then return salida, j + 1 end
  while true do
    if txt:sub(j, j) ~= '"' then return nil, j, "esperaba una clave en la posición " .. j end
    local clave, sig, err = leerCadena(txt, j)
    if err then return nil, sig, err end
    j = saltarBlancos(txt, sig)
    if txt:sub(j, j) ~= ":" then return nil, j, "esperaba : en la posición " .. j end
    local valor, sig2, err2 = leerValor(txt, saltarBlancos(txt, j + 1))
    if err2 then return nil, sig2, err2 end
    salida[clave] = valor
    j = saltarBlancos(txt, sig2)
    local c = txt:sub(j, j)
    if c == "," then j = saltarBlancos(txt, j + 1)
    elseif c == "}" then return salida, j + 1
    else return nil, j, "esperaba , o } en la posición " .. j end
  end
end

leerValor = function (txt, i)
  i = saltarBlancos(txt, i)
  local c = txt:sub(i, i)
  if c == '"' then return leerCadena(txt, i) end
  if c == "{" then return leerObjeto(txt, i) end
  if c == "[" then return leerLista(txt, i) end
  if txt:sub(i, i + 3) == "true" then return true, i + 4 end
  if txt:sub(i, i + 4) == "false" then return false, i + 5 end
  if txt:sub(i, i + 3) == "null" then return nil, i + 4 end
  local num = txt:match("^%-?%d+%.?%d*[eE]?[%+%-]?%d*", i)
  if num and #num > 0 then return tonumber(num), i + #num end
  return nil, i, "no sé qué es esto, en la posición " .. i
end

--- Devuelve la tabla, o `nil` y el motivo. Nunca lanza.
function json.decodificar(txt)
  if type(txt) ~= "string" or txt == "" then return nil, "vacío" end
  local ok, valor, _, err = pcall(leerValor, txt, 1)
  if not ok then return nil, tostring(valor) end
  if err then return nil, err end
  return valor
end

return json
