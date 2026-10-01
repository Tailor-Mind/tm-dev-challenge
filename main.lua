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
local decision = require("src.decision")
local plan = require("src.plan")

-- Cámbialo si te damos otra: es el endpoint del goteo.
local ENDPOINT = os.getenv("TM_ENDPOINT") or
  "https://script.google.com/macros/s/AKfycbzAnxZy6WchTCI93EArs_-bHfEhOm0XoBSa7HhuLEgi6egs6KLzQ4miCovR7Y2A1GH5Ug/exec"

local mundo, panel, correo = nil, true, nil

--- Sella el plan, abre la partida y arranca el reloj. En ese orden.
local function sellarYEmpezar()
  local f = io.open("PLAN-SELLADO.md", "w")
  if f then
    f:write("# El plan que sellé antes de empezar

")
    for _, fila in ipairs(plan.filas) do
      f:write(("- **%s**: %s
"):format(fila.titulo, fila.opciones[fila.elegido]))
    end
    f:write(("
**Cuando llegue algo que no cabe, voy a:** %s
"):format(plan.noCabe))
    f:write(("
Sellado el %s.
"):format(os.date("!%Y-%m-%d %H:%M UTC")))
    f:close()
  end
  requisitos.empezar(ENDPOINT, correo)
  requisitos.sellarPlan(plan.hoja(), plan.noCabe)
  plan.activo = false
end

function love.load(args)
  for i, a in ipairs(args or {}) do
    if a == "--test" then
      local codigo = require("tests.correr")()
      love.event.quit(codigo)
      return
    end
    if a == "--run" and args[i + 1] then
      -- El plan va primero y no gasta reloj: la partida se abre al sellarlo.
      correo = args[i + 1]
      plan.abrir()
    end
  end
  mundo = motor.nuevo(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.update(dt)
  if not mundo then return end
  if plan.activo then
    if plan.listo then sellarYEmpezar() end
    return
  end
  decision.actualizar(requisitos)
  if decision.bloquea() then return end
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
  if plan.activo then plan.dibujar(); return end
  pintar.mundo(mundo)
  if panel then pintar.requisitos(requisitos) end
  decision.dibujar(requisitos)
end

function love.textinput(t)
  if plan.activo then plan.texto(t) else decision.texto(t) end
end

function love.keypressed(tecla)
  if plan.teclado(tecla) then return end
  if decision.teclado(tecla, requisitos) then return end
  decision.cerrarAviso()
  if tecla == "tab" then panel = not panel end
  if tecla == "r" then mundo:reiniciar() end
  if tecla == "escape" then love.event.quit() end
end

function love.resize(w, h)
  if mundo then mundo.ancho, mundo.alto = w, h end
end
