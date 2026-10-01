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

  -- Apoyado encima de la plataforma `p`, no solo a su altura.
  local function sobre(m, p)
    local j = m.jugador
    return j.enSuelo and j.y + j.h == p.y and j.x + j.w > p.x and j.x < p.x + p.w
  end

  t("desde el suelo se sube a la primera plataforma", function (esperar)
    local m = motor.nuevo()
    local p1 = m.plataformas[2]
    for _ = 1, 200 do m:actualizar(1 / 60, {}) end
    local llego = false
    for _ = 1, 600 do
      m:actualizar(1 / 60, { derecha = true, saltar = true })
      if sobre(m, p1) then llego = true; break end
    end
    esperar(llego, "saltando hacia la derecha tendría que acabar encima")
  end)

  t("desde la primera plataforma se sube a la segunda", function (esperar)
    local m = motor.nuevo()
    local p1, p2 = m.plataformas[2], m.plataformas[3]
    local j = m.jugador
    -- Colocado en el borde derecho de la primera, ya apoyado.
    j.x, j.y, j.vy = p1.x + p1.w - j.w, p1.y - j.h, 0
    m:actualizar(1 / 60, {})
    esperar(sobre(m, p1), "empieza apoyado en la primera")
    local llego = false
    m:actualizar(1 / 60, { derecha = true, saltar = true })
    for _ = 1, 120 do
      m:actualizar(1 / 60, { derecha = true })
      if sobre(m, p2) then llego = true; break end
    end
    esperar(llego, "un salto hacia la derecha tendría que dejarlo encima")
  end)
end
