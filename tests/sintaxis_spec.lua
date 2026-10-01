--[[
  Que todo el repositorio compile. Incluido `main.lua`.

  Las otras pruebas cargan módulos sueltos de `src/`; ninguna compila el
  arranque. Un paréntesis sin cerrar en `main.lua` dejaría el juego sin abrir con
  toda la suite en verde, que es la peor combinación posible.

  Es la prueba más barata del repo y la que más veces te va a salvar: si rompes
  un fichero, lo sabes en medio segundo en vez de al abrir la ventana.
]]
return function (t)
  local function ficheros(dir, acc)
    acc = acc or {}
    for _, nombre in ipairs(love.filesystem.getDirectoryItems(dir)) do
      local ruta = (dir == "" and nombre or dir .. "/" .. nombre)
      local info = love.filesystem.getInfo(ruta)
      if info.type == "directory" then
        ficheros(ruta, acc)
      elseif ruta:match("%.lua$") then
        acc[#acc + 1] = ruta
      end
    end
    return acc
  end

  t("todos los .lua compilan", function (esperar)
    for _, ruta in ipairs(ficheros("")) do
      local fuente = love.filesystem.read(ruta)
      local chunk, err = loadstring and loadstring(fuente, ruta) or load(fuente, ruta)
      esperar(chunk ~= nil, ruta .. ": " .. tostring(err))
    end
  end)
end
