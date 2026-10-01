--[[
  Un corredor de pruebas de 30 líneas, para no pedirte que instales luarocks ni
  busted antes de escribir la primera línea de código.

    love . --test

  Devuelve 0 si todo pasa y 1 si algo falla, así que sirve en CI tal cual.
]]
return function ()
  local fallos, total = 0, 0
  local function prueba(nombre, cuerpo)
    total = total + 1
    local errores = {}
    local function esperar(cond, porque)
      if not cond then errores[#errores + 1] = porque or "sin detalle" end
    end
    local ok, err = pcall(cuerpo, esperar)
    if not ok then errores[#errores + 1] = tostring(err) end
    if #errores == 0 then
      print("  ok   " .. nombre)
    else
      fallos = fallos + 1
      print("  FALLA " .. nombre)
      for _, e in ipairs(errores) do print("         " .. e) end
    end
  end

  for _, fichero in ipairs({ "tests.motor_spec", "tests.util_spec", "tests.sintaxis_spec" }) do
    local suite = require(fichero)
    suite(prueba)
  end

  print(("\n%d prueba(s), %d fallo(s)"):format(total, fallos))
  return fallos == 0 and 0 or 1
end
