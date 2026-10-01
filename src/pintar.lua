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
  love.graphics.print(
    "flechas o A/D · espacio salta · R reinicia · C copia · E entrega ya · " ..
    "F5 recarga (si se cierra, vuelve a abrir con `love .`) · TAB esconde el panel", 14, 12)
  love.graphics.setColor(1, 1, 1)
end

-- Cuánto está bajada la lista de requisitos, y cuánto se puede bajar.
pintar.scroll = 0
pintar.maxScroll = 0

--- La rueda del ratón mueve la lista. 40 px por muesca.
function pintar.rueda(dy)
  pintar.scroll = math.max(0, math.min(pintar.maxScroll, pintar.scroll - dy * 40))
end

function pintar.requisitos(R, copiado)
  local x, y, w = love.graphics.getWidth() - 360, 50, 346
  love.graphics.setColor(0, 0, 0, 0.72)
  love.graphics.rectangle("fill", x, y, w, love.graphics.getHeight() - y - 20, 8)

  love.graphics.setColor(0.65, 0.72, 0.85)
  if R.estado == "abriendo" then
    love.graphics.printf("Abriendo tu partida…", x + 14, y + 14, w - 28)
  elseif not R.run then
    love.graphics.printf(
      "Sin partida abierta.\n\nArranca con:\n  love . --run TU@CORREO --clave TU_CLAVE\n\n" ..
      "La clave te llegó al postular.", x + 14, y + 14, w - 28)
  else
    -- El reloj primero y grande: es el dato que gobierna todas las decisiones de
    -- la siguiente media hora.
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(R.sincronizado and R.reloj() or "--:--:--", x + 14, y + 12, w - 28)
    -- Lo que queda, al lado: el tiempo transcurrido informa, el que falta decide.
    local quedan = R.sincronizado and R.restante() or "preguntando al servidor"
    love.graphics.setColor(quedan == "se acabó" and 0.9 or 0.55,
                           quedan == "se acabó" and 0.45 or 0.62,
                           quedan == "se acabó" and 0.35 or 0.75)
    love.graphics.printf(("(%s)"):format(quedan), x + 90, y + 12, w - 28)
    love.graphics.setColor(0.55, 0.62, 0.75)
    love.graphics.printf(
      ("empezaste a las %s · tienes %d min%s"):format(
        R.horaInicio or "—", R.base,
        R.decision == "seguir" and (" + " .. R.prorroga) or ""),
      x + 14, y + 34, w - 28)
    love.graphics.printf(
      R.sincronizado and ("%s · quedan %d por llegar"):format(R.run, R.pendientes)
        or (R.run .. " · sincronizando…"),
      x + 14, y + 52, w - 28)
    -- La ayuda puede ocupar una línea o dos según el ancho de la ventana, así
    -- que se mide: con una altura fija, el primer requisito se montaba encima.
    local ayuda = "1-9 copia uno · C todos · rueda baja · los tienes en REQUISITOS-RECIBIDOS.md"
    local fuente = love.graphics.getFont()
    local _, lineasAyuda = fuente:getWrap(ayuda, w - 28)
    love.graphics.setColor(0.45, 0.55, 0.7)
    love.graphics.printf(ayuda, x + 14, y + 66, w - 28)

    -- La lista crece hasta pasarse del panel: se recorta a su zona y se mueve
    -- con la rueda. Sin esto, los últimos requisitos se pintan fuera de la
    -- pantalla y no hay forma de leerlos.
    local arriba = y + 72 + fuente:getHeight() * #lineasAyuda + 8
    local abajo = love.graphics.getHeight() - 56
    love.graphics.setScissor(x, arriba, w, abajo - arriba)
    local dy = arriba + 6 - pintar.scroll
    for i, r in ipairs(R.lista) do
      -- El número delante es la tecla que lo copia: trabajar es mandarle uno al
      -- agente, no la lista entera.
      love.graphics.setColor(0.45, 0.62, 0.95)
      love.graphics.printf(tostring(i), x + 14, dy, 16)
      love.graphics.setColor(1, 1, 1)
      local titulo = ("[%s] %s"):format(r.id, r.titulo)
      local _, lineasTit = fuente:getWrap(titulo, w - 46)
      love.graphics.printf(titulo, x + 32, dy, w - 46)
      dy = dy + fuente:getHeight() * #lineasTit + 4
      love.graphics.setColor(0.6, 0.66, 0.78)
      local _, lineas = fuente:getWrap(r.cuerpo, w - 46)
      love.graphics.printf(r.cuerpo, x + 32, dy, w - 46)
      dy = dy + fuente:getHeight() * #lineas + 16
    end
    love.graphics.setScissor()

    -- Cuánto se puede bajar: lo que mide la lista menos lo que cabe.
    pintar.maxScroll = math.max(0, (dy + pintar.scroll) - abajo)
    if pintar.scroll > pintar.maxScroll then pintar.scroll = pintar.maxScroll end

    if pintar.maxScroll > 0 then
      love.graphics.setColor(0.45, 0.5, 0.62)
      if pintar.scroll > 0 then love.graphics.printf("▲", x + w - 30, arriba - 2, 20) end
      if pintar.scroll < pintar.maxScroll then love.graphics.printf("▼", x + w - 30, abajo - 16, 20) end
    end
  end

  -- El aviso de copiado va en medio de la pantalla, no en una esquina del panel:
  -- si no se ve, la tecla parece rota aunque haya funcionado.
  if copiado then
    local W, H = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(0.1, 0.35, 0.2, 0.92)
    love.graphics.rectangle("fill", W / 2 - 190, H / 2 - 26, 380, 52, 8)
    love.graphics.setColor(0.6, 0.95, 0.7)
    love.graphics.printf(
      copiado == "todos" and "todos los requisitos, copiados"
        or ("copiado: " .. tostring(copiado)),
      W / 2 - 180, H / 2 - 8, 360, "center")
  end
  if R.run then
    love.graphics.setColor(0.4, 0.45, 0.55)
    love.graphics.printf("vía " .. (R.via or "?"), x + 14, love.graphics.getHeight() - 34, w - 28)
  end
  if R.error then
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.printf("sin red: " .. R.error, x + 14, love.graphics.getHeight() - 60, w - 28)
  end
  love.graphics.setColor(1, 1, 1)
end

return pintar
