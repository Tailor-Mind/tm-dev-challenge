--[[
  Los casos de demo. Son de verdad y pasan: sirven para ver cómo se prueba esto
  y para que tengas una red desde el minuto uno.

  Añade los tuyos aquí mismo. Se corren con `love . --test`, sin instalar nada.
]]
return function (t)
  local motor = require("src.motor")

  t("el jugador cae con la gravedad", function (esperar)
    local m = motor.nuevo()
    local y0 = m.jugador.y
    m:actualizar(0.1, {})
    esperar(m.jugador.y > y0, "debería haber bajado")
  end)

  t("el suelo lo para", function (esperar)
    local m = motor.nuevo()
    for _ = 1, 200 do m:actualizar(1 / 60, {}) end
    esperar(m.jugador.enSuelo, "tendría que estar en el suelo")
    esperar(m.jugador.y + m.jugador.h <= m.alto - 40 + 0.5, "no atraviesa el suelo")
  end)

  t("solo salta si está apoyado", function (esperar)
    local m = motor.nuevo()
    for _ = 1, 200 do m:actualizar(1 / 60, {}) end
    m:actualizar(1 / 60, { saltar = true })
    esperar(m.jugador.vy < 0, "el salto le da impulso hacia arriba")
    local vy = m.jugador.vy
    m:actualizar(1 / 60, { saltar = true })
    esperar(m.jugador.vy > vy, "en el aire, saltar otra vez no hace nada")
  end)

  t("no se sale por los lados", function (esperar)
    local m = motor.nuevo()
    for _ = 1, 600 do m:actualizar(1 / 60, { izquierda = true }) end
    esperar(m.jugador.x >= 0, "se quedó dentro por la izquierda")
  end)

  t("caerse del mundo devuelve al inicio", function (esperar)
    local m = motor.nuevo()
    m.jugador.y = m.alto + 400
    m:actualizar(1 / 60, {})
    esperar(m.jugador.y == m.inicio.y, "vuelve donde empezó")
  end)
end
