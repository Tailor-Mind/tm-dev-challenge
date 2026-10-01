--[[
  El reto — TailorMind.

  Arranca así:
      love .                      juega
      love . --test               corre las pruebas y sale
      love . --run TU@CORREO      abre tu partida y empieza el goteo de requisitos

  Lo que ves ahora es el punto de partida: un personaje que corre, salta y no
  atraviesa el suelo. A partir de ahí, los requisitos van llegando solos.
]]

local motor = require("src.motor")
local pintar = require("src.pintar")
local requisitos = require("src.requisitos")

-- Cámbialo si te damos otra: es el endpoint del goteo.
local ENDPOINT = os.getenv("TM_ENDPOINT") or
  "https://script.google.com/macros/s/AKfycbzAnxZy6WchTCI93EArs_-bHfEhOm0XoBSa7HhuLEgi6egs6KLzQ4miCovR7Y2A1GH5Ug/exec"

local mundo, panel = nil, true

function love.load(args)
  for i, a in ipairs(args or {}) do
    if a == "--test" then
      local codigo = require("tests.correr")()
      love.event.quit(codigo)
      return
    end
    if a == "--run" and args[i + 1] then
      requisitos.empezar(ENDPOINT, args[i + 1])
    end
  end
  mundo = motor.nuevo(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.update(dt)
  if not mundo then return end
  -- dt con techo: si arrastras la ventana, el juego no se teletransporta.
  dt = math.min(dt, 1 / 30)
  mundo:actualizar(dt, {
    izquierda = love.keyboard.isDown("left", "a"),
    derecha = love.keyboard.isDown("right", "d"),
    saltar = love.keyboard.isDown("space", "up", "w"),
  })
  requisitos.refrescar(dt)
end

function love.draw()
  if not mundo then return end
  pintar.mundo(mundo)
  if panel then pintar.requisitos(requisitos) end
end

function love.keypressed(tecla)
  if tecla == "tab" then panel = not panel end
  if tecla == "r" then mundo:reiniciar() end
  if tecla == "escape" then love.event.quit() end
end

function love.resize(w, h)
  if mundo then mundo.ancho, mundo.alto = w, h end
end
