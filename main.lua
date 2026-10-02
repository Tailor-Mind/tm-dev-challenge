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

-- `motor` y `pintar` no son locales fijos: F5 los vuelve a cargar.
local motor = require("src.motor")
local pintar = require("src.pintar")
local requisitos = require("src.requisitos")
local decision = require("src.decision")
local plan = require("src.plan")

-- Cámbialo si te damos otra: es el endpoint del goteo.
local ENDPOINT = os.getenv("TM_ENDPOINT") or
  "https://script.google.com/macros/s/AKfycbzAnxZy6WchTCI93EArs_-bHfEhOm0XoBSa7HhuLEgi6egs6KLzQ4miCovR7Y2A1GH5Ug/exec"

local mundo, panel, correo, clave = nil, true, nil, nil
local copiado = 0        -- segundos que queda el aviso en pantalla
local copiadoQue = ""    -- qué se copió, para decirlo en el aviso
local fallo = nil        -- el último error de tu código, si lo hubo
local falloRed = nil     -- y el del panel, que nunca debería tumbar la partida
local recargado = 0      -- segundos que queda el aviso de recarga

--[[
  F5: recargar tu código sin reiniciar la partida.

  Antes esto llamaba a `love.event.quit("restart")`, que según la versión de LÖVE
  reinicia… o cierra y ya. Y aunque reinicie, tira el hilo de red y vuelve a
  pedirle todo al servidor.

  Esto es mejor: se sueltan los módulos tuyos, se vuelven a cargar, y el reloj,
  el panel y la partida siguen intactos porque ni se enteran. Si lo que cargas
  está roto, se queda el anterior y te lo dice: nunca te deja sin juego.
]]
local INFRA = {
  ["src.requisitos"] = true, ["src.plan"] = true, ["src.decision"] = true,
  ["src.json"] = true, ["src.hilo_red"] = true,
}

local function recargar()
  local sueltos = {}
  for nombre in pairs(package.loaded) do
    if type(nombre) == "string" and nombre:match("^src%.") and not INFRA[nombre] then
      sueltos[#sueltos + 1] = nombre
    end
  end
  local copia = {}
  for _, n in ipairs(sueltos) do copia[n] = package.loaded[n]; package.loaded[n] = nil end

  local ok, err = pcall(function ()
    motor = require("src.motor")
    pintar = require("src.pintar")
    local nuevo = motor.nuevo(love.graphics.getWidth(), love.graphics.getHeight())
    -- Se conserva dónde estabas: recargar no debería devolverte al principio.
    if mundo and mundo.jugador and nuevo.jugador then
      nuevo.jugador.x, nuevo.jugador.y = mundo.jugador.x, mundo.jugador.y
    end
    mundo = nuevo
  end)

  if not ok then
    -- Vuelta atrás: con el módulo roto fuera, el juego sigue siendo jugable.
    for n, m in pairs(copia) do package.loaded[n] = m end
    fallo = "al recargar: " .. tostring(err)
    return
  end
  fallo, recargado = nil, 1.5
end

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
  if copiado > 0 then copiado = copiado - dt end
  if recargado > 0 then recargado = recargado - dt end
  decision.actualizar(requisitos)

  -- El reloj y el envío van **antes** que el juego y fuera de su suerte: si lo
  -- que escribes revienta, la partida tiene que seguir contando y hablando con
  -- el servidor. Perder la evidencia por un error tuyo sería perder la prueba.
  -- Ni siquiera esto puede tumbar la partida: si el panel falla, el reloj del
  -- servidor sigue y la decisión del minuto 30 se puede mandar desde la terminal
  -- con el skill `tm-reto`.
  local okRed, errRed = pcall(requisitos.refrescar, dt)
  if not okRed then falloRed = tostring(errRed) end

  if decision.bloquea() then return end
  -- dt con techo: si arrastras la ventana, el juego no se teletransporta.
  dt = math.min(dt, 1 / 30)

  -- Tu código, en una red. Un error no cierra el proceso: se enseña en pantalla
  -- y el resto sigue vivo.
  local ok, err = pcall(function ()
    mundo:actualizar(dt, {
      izquierda = love.keyboard.isDown("left", "a"),
      derecha = love.keyboard.isDown("right", "d"),
      saltar = love.keyboard.isDown("space", "up", "w"),
    })
  end)
  if not ok then fallo = tostring(err) end
end

function love.draw()
  if not mundo then return end
  if plan.activo then plan.dibujar(); return end

  local ok, err = pcall(pintar.mundo, mundo)
  if not ok then fallo = tostring(err) end

  if falloRed then
    love.graphics.setColor(0.95, 0.4, 0.35)
    love.graphics.printf("el panel falló: " .. falloRed ..
      "\nel reloj del servidor sigue; puedes seguir y usar el skill tm-reto",
      14, love.graphics.getHeight() - 110, love.graphics.getWidth() - 400)
    love.graphics.setColor(1, 1, 1)
  end
  if fallo then
    love.graphics.setColor(0.95, 0.55, 0.35)
    love.graphics.printf("tu juego lanzó un error (el reloj sigue corriendo):\n" .. fallo,
      14, love.graphics.getHeight() - 70, love.graphics.getWidth() - 400)
    love.graphics.setColor(1, 1, 1)
  end

  if recargado > 0 then
    love.graphics.setColor(0.5, 0.85, 0.6)
    love.graphics.print("recargado", 14, 34)
    love.graphics.setColor(1, 1, 1)
  end
  if panel then pintar.requisitos(requisitos, copiado > 0 and copiadoQue or nil) end
  decision.dibujar(requisitos)
end

function love.textinput(t)
  if plan.activo then plan.texto(t) else decision.texto(t) end
end

function love.keypressed(tecla)
  if plan.teclado(tecla) then return end
  if decision.teclado(tecla, requisitos) then return end
  decision.cerrarAviso(requisitos)
  if tecla == "tab" then panel = not panel end
  -- Terminar antes es un resultado, no una rendición: quien ya tiene lo suyo
  -- acabado y probado no gana nada mirando el reloj.
  if tecla == "e" then decision.terminarYa(requisitos) end
  if tecla == "r" then fallo = nil; pcall(function () mundo:reiniciar() end) end
  -- Los requisitos se trabajan pegándoselos a tu agente de uno en uno, y en un
  -- lienzo no se pueden seleccionar con el ratón. Cada número copia el suyo;
  -- C los copia todos, para cuando quieras el panorama completo.
  local n = tonumber(tecla)
  if n and n >= 1 and n <= 9 then
    local texto = requisitos.comoTexto(n)
    if texto ~= "" then
      love.system.setClipboardText(texto)
      copiado, copiadoQue = 2.5, (requisitos.lista[n] or {}).id or ""
    end
  end
  if tecla == "c" then
    local texto = requisitos.comoTexto()
    if texto ~= "" then
      love.system.setClipboardText(texto)
      copiado, copiadoQue = 2.5, "todos"
    end
  end
  if tecla == "f5" then recargar() end
  if tecla == "escape" then love.event.quit() end
end

function love.wheelmoved(_, dy)
  if panel then pintar.rueda(dy) end
end

function love.resize(w, h)
  if mundo then mundo.ancho, mundo.alto = w, h end
end
