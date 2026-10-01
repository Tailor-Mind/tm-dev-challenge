--[[
  El reto — TailorMind.

  Arranca así:
      love .                      juega
      love . --test               corre las pruebas y sale
      love . --run TU@CORREO --clave TU_CLAVE
                                  abre tu partida y empieza el goteo de requisitos
                                  (la clave te llegó en tu correo de confirmación)

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

local mundo, panel, correo, clave = nil, true, nil, nil

--- Sella el plan, abre la partida y arranca el reloj. En ese orden.
local function sellarYEmpezar()
  local f = io.open("PLAN-SELLADO.md", "w")
  if f then
    f:write("# El plan que sellé antes de empezar\n\n")
    for _, fila in ipairs(plan.filas) do
      f:write(("- **%s**: %s\n"):format(fila.titulo, fila.opciones[fila.elegido]))
    end
    f:write(("\n**Cuando llegue algo que no cabe, voy a:** %s\n"):format(plan.noCabe))
    f:write(("\nSellado el %s.\n"):format(os.date("!%Y-%m-%d %H:%M UTC")))
    f:close()
  end
  requisitos.empezar(ENDPOINT, correo, clave)
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
    if a == "--clave" and args[i + 1] then clave = args[i + 1] end
    if a == "--run" and args[i + 1] then
      -- Si ya hay partida abierta en este repo, se reanuda. Reiniciar el juego
      -- para ver tus cambios no abre otra ni te devuelve el reloj a cero.
      if not requisitos.reanudar(ENDPOINT) then
        -- El plan va primero y no gasta reloj: la partida se abre al sellarlo.
        correo = args[i + 1]
        plan.abrir()
      end
    end
  end
  -- Aunque abras con `love .` a secas: si hay una partida en marcha en esta
  -- carpeta, se reanuda. Lo contrario sería perder el panel por abrir el juego
  -- sin acordarse del argumento.
  if not requisitos.run and not plan.activo then requisitos.reanudar(ENDPOINT) end

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
  -- LÖVE no recarga en caliente. F5 reinicia el juego entero, que tarda menos de
  -- un segundo: tus cambios entran y la partida sigue donde estaba, porque el
  -- reloj lo lleva el servidor y el identificador está en `.tm-run`.
  if tecla == "f5" then love.event.quit("restart") end
  if tecla == "escape" then love.event.quit() end
end

function love.resize(w, h)
  if mundo then mundo.ancho, mundo.alto = w, h end
end
