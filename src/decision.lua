--[[
  El minuto 30.

  El reto son 30 minutos. Cuando se cumplen, el juego para y pregunta una sola
  cosa: ¿lo que tienes entregado ya vale, o quieres diez minutos más?

  Las dos respuestas son válidas y ninguna puntúa por sí sola. Lo que se mira es
  si la respuesta encaja con lo que hay en el disco: parar con tres cosas
  terminadas es acertar; parar con todo a medias, no. Pedir diez minutos para
  cerrar algo concreto es acertar; pedirlos para empezar lo que no se empezó, no.

  Por eso se pide un motivo en una línea. Esa línea es la respuesta.
]]

local D = {
  estado = "jugando",   -- jugando | preguntando | escribiendo | cerrado
  eleccion = nil,       -- "parar" | "seguir"
  motivo = "",
  limite = 30,
  avisado = false,
}

local function anotar(linea)
  local f = io.open("REQUISITOS-RECIBIDOS.md", "a")
  if not f then return end
  f:write(linea, "\n")
  f:close()
end

--- Se llama cada cuadro con el cliente de requisitos, que sabe el minuto real.
function D.actualizar(R)
  if not R.run then return end
  local base = R.base or 30

  if D.estado == "jugando" and R.minutos >= base then
    D.estado = "preguntando"
  end

  if D.estado == "cerrado" and not D.avisado and R.minutos >= D.limite then
    D.avisado = true
    anotar(("\n---\n\nSe acabó el tiempo en el minuto %d."):format(R.minutos))
  end
end

--- Teclas. Devuelve true si se la quedó, para que el juego no la vea.
function D.teclado(tecla, R)
  if D.estado == "preguntando" then
    if tecla == "1" then D.eleccion = "parar" end
    if tecla == "2" then D.eleccion = "seguir" end
    if D.eleccion then D.estado = "escribiendo" end
    return true
  end

  if D.estado == "escribiendo" then
    if tecla == "backspace" then
      D.motivo = D.motivo:sub(1, -2)
    elseif tecla == "return" and #D.motivo > 0 then
      D.enviar(R)
    end
    return true
  end

  return false
end

function D.texto(t)
  if D.estado == "escribiendo" and #D.motivo < 160 then D.motivo = D.motivo .. t end
end

function D.enviar(R)
  D.limite = (D.eleccion == "seguir") and ((R.base or 30) + (R.prorroga or 10)) or (R.base or 30)
  D.estado = "cerrado"

  anotar(("\n---\n\n## Minuto %d — la decisión\n\n**%s**\n\n> %s\n")
    :format(R.minutos or 0,
      D.eleccion == "parar" and "Entrego aquí." or "Pido diez minutos más.",
      D.motivo))

  R.decidir(D.eleccion, D.motivo)
end

--- Lo que se ve. Se dibuja encima de todo, y mientras pregunta, el juego no corre.
function D.dibujar(R)
  if D.estado == "jugando" then return end

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setColor(0, 0, 0, 0.82)
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(1, 1, 1)

  local x, y, cw = w * 0.12, h * 0.26, w * 0.76

  if D.estado == "preguntando" then
    love.graphics.printf("Llevas 30 minutos.", x, y, cw)
    love.graphics.setColor(0.72, 0.78, 0.88)
    love.graphics.printf(
      "\n¿Lo que tienes entregado ya vale, o quieres diez minutos más?\n\n" ..
      "Las dos respuestas están bien. Lo que miramos es si encaja con lo que hay.\n\n" ..
      "  [1]  Entrego aquí\n" ..
      "  [2]  Diez minutos más\n", x, y + 24, cw)

  elseif D.estado == "escribiendo" then
    love.graphics.printf(
      D.eleccion == "parar" and "Entregas aquí. ¿Por qué?" or "Diez minutos más. ¿Para qué, exactamente?",
      x, y, cw)
    love.graphics.setColor(0.72, 0.78, 0.88)
    love.graphics.printf("Una línea. Esta frase es parte de la evaluación.\n", x, y + 24, cw)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("> " .. D.motivo .. "_", x, y + 64, cw)
    love.graphics.setColor(0.5, 0.56, 0.66)
    love.graphics.printf("\nEnter para confirmar", x, y + 96, cw)

  elseif D.estado == "cerrado" then
    local quedan = math.max(0, D.limite - (R.minutos or 0))
    if quedan > 0 then
      love.graphics.printf(("Sigue. Te quedan %d minuto(s)."):format(quedan), x, y, cw)
      love.graphics.setColor(0.72, 0.78, 0.88)
      love.graphics.printf("\nPulsa cualquier tecla para volver al juego.", x, y + 24, cw)
    else
      love.graphics.printf("Se acabó el tiempo.", x, y, cw)
      love.graphics.setColor(0.72, 0.78, 0.88)
      love.graphics.printf(
        "\nEntrega lo que hay: el juego, SUPUESTOS.md con lo que asumiste y lo que " ..
        "dejaste fuera, y REQUISITOS-RECIBIDOS.md tal como está.", x, y + 24, cw)
    end
  end

  love.graphics.setColor(1, 1, 1)
end

--- Mientras pregunta o escribe, el juego se congela.
function D.bloquea()
  return D.estado == "preguntando" or D.estado == "escribiendo"
end

--- Un aviso para volver al juego después de decidir.
function D.cerrarAviso()
  if D.estado == "cerrado" then D.estado = "jugando" end
end

return D
