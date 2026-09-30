-- Configuración de LÖVE. Se lee antes de arrancar el juego.
function love.conf(t)
  t.window.title = "El reto — TailorMind"
  t.window.width = 960
  t.window.height = 540
  t.window.resizable = true
  t.console = false
  t.version = "11.4"
end
