--[[
  Pruebas de `src/util.lua`. Están en verde.

  Cada una comprueba un caso y nada más: el que se le ocurrió a quien la escribió
  un martes por la tarde. Si vas a apoyarte en estas funciones, mira qué entradas
  cubren y cuáles no.
]]
return function (t)
  local util = require("src.util")

  t("el reloj formatea un minuto y medio", function (esperar)
    esperar(util.reloj(90) == "1:30", "90 s deberían ser 1:30, salió " .. util.reloj(90))
  end)

  t("limitar respeta el rango", function (esperar)
    esperar(util.limitar(5, 0, 10) == 5, "dentro del rango no toca nada")
    esperar(util.limitar(-3, 0, 10) == 0, "por debajo lo sube al mínimo")
    esperar(util.limitar(99, 0, 10) == 10, "por encima lo baja al máximo")
  end)

  t("contar cuenta los que cumplen", function (esperar)
    local monedas = { { tomada = true }, { tomada = true }, { tomada = false } }
    local n = util.contar(monedas, function (m) return m.tomada end)
    esperar(n == 2, "había dos tomadas, contó " .. n)
  end)

  t("porcentaje de la mitad", function (esperar)
    esperar(util.porcentaje(5, 10) == 50, "5 de 10 es 50%")
  end)
end
