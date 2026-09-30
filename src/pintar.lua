-- Lo que se ve. Nada de lógica aquí: si una decisión del juego acaba en este
-- fichero, deja de poder probarse sin abrir una ventana.
local pintar = {}

function pintar.mundo(m)
  love.graphics.clear(0.07, 0.08, 0.11)

  love.graphics.setColor(0.18, 0.21, 0.27)
  for _, p in ipairs(m.plataformas) do
    love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 3)
  end

  local j = m.jugador
  love.graphics.setColor(0.31, 0.61, 0.98)
  love.graphics.rectangle("fill", j.x, j.y, j.w, j.h, 4)

  love.graphics.setColor(0.55, 0.6, 0.7)
  love.graphics.print("flechas o A/D para moverte · espacio para saltar · R reinicia · TAB esconde el panel", 14, 12)
  love.graphics.setColor(1, 1, 1)
end

function pintar.requisitos(R)
  local x, y, w = love.graphics.getWidth() - 360, 50, 346
  love.graphics.setColor(0, 0, 0, 0.72)
  love.graphics.rectangle("fill", x, y, w, love.graphics.getHeight() - y - 20, 8)

  love.graphics.setColor(0.65, 0.72, 0.85)
  if not R.run then
    love.graphics.printf("Sin partida abierta.\n\nArranca con:\n  love . --run TU@CORREO",
      x + 14, y + 14, w - 28)
  else
    love.graphics.printf(
      ("partida %s · minuto %d · quedan %d por llegar"):format(R.run, R.minutos, R.pendientes),
      x + 14, y + 14, w - 28)
    local dy = y + 56
    for _, r in ipairs(R.lista) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(("[%s] %s"):format(r.id, r.titulo), x + 14, dy, w - 28)
      dy = dy + 20
      love.graphics.setColor(0.6, 0.66, 0.78)
      local _, lineas = love.graphics.getFont():getWrap(r.cuerpo, w - 28)
      love.graphics.printf(r.cuerpo, x + 14, dy, w - 28)
      dy = dy + 16 * #lineas + 14
    end
  end
  if R.error then
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.printf("sin red: " .. R.error, x + 14, love.graphics.getHeight() - 60, w - 28)
  end
  love.graphics.setColor(1, 1, 1)
end

return pintar
