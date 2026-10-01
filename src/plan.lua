--[[
  El plan, antes de que arranque el reloj.

  Esto es la hoja de reparto: quién escribe el código, quién escribe las
  pruebas, qué se revisa y cómo se reparten los 30 minutos. Se sella antes de
  empezar, y planificar **no gasta tiempo del reto** — el reloj arranca cuando
  sellas, no cuando abres el juego.

  Por eso el plan se puede leer con dureza después: no es una intención escrita
  a la carrera, es lo que dijiste que ibas a hacer con todo el tiempo del mundo
  para pensarlo. Y lo que se corrige no es el plan: es **la distancia entre el
  plan y lo que pasó**. Nadie cumple su plan entero; lo que distingue es si la
  diferencia fue una decisión o un atropello.

  Ninguna opción es la correcta. Delegar el código entero a un agente y no
  revisar nada es una postura defendible si lo que entregas funciona; escribirlo
  todo a mano también, si te da tiempo. Lo que no sobrevive es que el plan diga
  una cosa y el repositorio diga otra sin que nadie lo mencione.
]]

local P = {
  activo = false,
  fila = 1,
  escribiendo = false,
  noCabe = "",
}

P.filas = {
  { clave = "codigo", titulo = "El código lo escribe",
    opciones = { "mi agente", "yo a mano", "a medias" }, elegido = 1 },
  { clave = "pruebas", titulo = "Las pruebas las escribe",
    opciones = { "mi agente", "yo a mano", "no voy a escribir" }, elegido = 1 },
  { clave = "revision", titulo = "Lo que me devuelve el agente lo reviso",
    opciones = { "entero", "por bloques de cambios", "por encima", "no lo reviso" }, elegido = 1 },
  { clave = "manual", titulo = "El juego lo pruebo a mano",
    opciones = { "en cada cambio", "por bloques de cambios", "al final", "no me va a dar tiempo" },
    elegido = 1 },
  { clave = "reparto", titulo = "De los 30 minutos, dedico más a",
    opciones = { "construir", "revisar lo construido", "repartirlo parejo" }, elegido = 1 },
  { clave = "especificar", titulo = "Cuando llega un requisito, lo primero que hago",
    opciones = { "se lo paso tal cual al agente", "lo reescribo como spec", "lo parto en pasos",
                 "escribo la prueba primero" }, elegido = 1 },
}

function P.abrir()
  P.activo = true
end

function P.hoja()
  local partes = {}
  for _, f in ipairs(P.filas) do
    partes[#partes + 1] = f.clave .. "=" .. f.opciones[f.elegido]
  end
  return table.concat(partes, "; ")
end

--- Teclas. Devuelve true mientras la pantalla esté abierta: el juego no corre.
--- La última línea es una fila más de la lista: se baja hasta ella con la flecha
--- y se escribe ahí mismo. Antes había que adivinar que Enter abría el campo.
local function enTexto() return P.fila > #P.filas end

function P.teclado(tecla)
  if not P.activo then return false end

  if tecla == "up" then P.fila = math.max(1, P.fila - 1); P.escribiendo = enTexto(); return true end
  if tecla == "down" then P.fila = math.min(#P.filas + 1, P.fila + 1); P.escribiendo = enTexto(); return true end

  if enTexto() then
    P.escribiendo = true
    if tecla == "backspace" then
      P.noCabe = P.noCabe:sub(1, -2)
    elseif tecla == "return" and #P.noCabe > 0 then
      P.escribiendo = false
      P.listo = true
    end
    return true
  end

  if tecla == "left" or tecla == "right" then
    local f = P.filas[P.fila]
    local paso = (tecla == "right") and 1 or -1
    f.elegido = ((f.elegido - 1 + paso) % #f.opciones) + 1
  end
  -- Enter desde cualquier fila salta al final, que es donde se cierra el plan.
  if tecla == "return" then P.fila = #P.filas + 1; P.escribiendo = true end
  return true
end

function P.texto(t)
  if P.escribiendo and #P.noCabe < 160 then P.noCabe = P.noCabe .. t end
end

function P.dibujar()
  if not P.activo then return end
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.clear(0.05, 0.06, 0.08)

  local x, y, cw = 60, 50, math.min(760, w - 120)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Tu plan, antes de empezar", x, y, cw)
  love.graphics.setColor(0.6, 0.67, 0.78)
  love.graphics.printf(
    "Esto no gasta tiempo del reto: el reloj arranca cuando selles.\n" ..
    "Ninguna opción es la correcta. Lo que miramos después es la distancia entre\n" ..
    "lo que dijiste aquí y lo que acabó pasando.\n", x, y + 26, cw)

  local fy = y + 100
  for i, f in ipairs(P.filas) do
    local activa = (i == P.fila and not P.escribiendo)
    love.graphics.setColor(activa and 1 or 0.55, activa and 1 or 0.6, activa and 1 or 0.7)
    love.graphics.printf((activa and "> " or "  ") .. f.titulo, x, fy, cw * 0.56)
    love.graphics.setColor(activa and 0.31 or 0.4, activa and 0.61 or 0.5, activa and 0.98 or 0.6)
    love.graphics.printf("< " .. f.opciones[f.elegido] .. " >", x + cw * 0.58, fy, cw * 0.42)
    fy = fy + 30
  end

  fy = fy + 14
  love.graphics.setColor(P.escribiendo and 1 or 0.55, P.escribiendo and 1 or 0.6, P.escribiendo and 1 or 0.7)
  love.graphics.printf("Cuando llegue algo que no cabe, voy a:", x, fy, cw)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("> " .. P.noCabe .. (P.escribiendo and "_" or ""), x, fy + 24, cw)

  love.graphics.setColor(0.45, 0.5, 0.6)
  love.graphics.printf(
    P.escribiendo
      and "\nEscribe una línea y pulsa Enter para sellar el plan y arrancar el reloj."
      or "\n↑↓ para moverte · ←→ para elegir · Enter para escribir la última línea",
    x, fy + 56, cw)
  love.graphics.setColor(1, 1, 1)
end

return P
