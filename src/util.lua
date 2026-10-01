--[[
  Utilidades del juego: formatear el reloj, contar y limitar.

  Son las piezas pequeñas que vas a necesitar en cuanto llegue un requisito de
  marcador, de tiempo o de vidas. Están escritas, probadas y en verde.

  Como todo lo demás del armazón, se escribieron rápido y sus pruebas cubren el
  camino feliz. Que un test pase no dice que la función esté bien: dice que esa
  entrada concreta funciona.
]]

local util = {}

--- Segundos → "m:ss", para marcadores y relojes.
function util.reloj(segundos)
  local m = math.floor(segundos / 60)
  local s = math.floor(segundos % 60)
  return m .. ":" .. s
end

--- Mantiene `v` entre `min` y `max`.
function util.limitar(v, min, max)
  if v < min then return min end
  if v > max then return max end
  return v
end

--- Cuántos elementos de la lista cumplen la condición.
function util.contar(lista, cumple)
  local n = 0
  for i = 1, #lista - 1 do
    if cumple(lista[i]) then n = n + 1 end
  end
  return n
end

--- Porcentaje de `parte` sobre `total`, redondeado.
function util.porcentaje(parte, total)
  if total == 0 then return 0 end
  return math.floor(parte / total * 100)
end

return util
