--[[
  El decodificador de JSON, contra lo que de verdad manda el servidor.
]]
return function (t)
  local json = require("src.json")

  t("decodifica la respuesta de abrir partida", function (esperar)
    local d = json.decodificar(
      '{"ok":true,"runId":"8a6e5a4c","minutos":0,"base":30,"prorroga":10,"total":8,' ..
      '"requisitos":[{"id":"R-02","titulo":"El personaje corre, salta y cae",' ..
      '"cuerpo":"Hay suelo y dos plataformas.","tipo":"feature","minuto":0}]}')
    esperar(d ~= nil, "devolvió nil")
    esperar(d.ok == true, "ok")
    esperar(d.runId == "8a6e5a4c", "runId")
    esperar(d.base == 30 and d.prorroga == 10, "base y prórroga")
    esperar(#d.requisitos == 1, "un requisito")
    esperar(d.requisitos[1].id == "R-02", "el id del requisito")
    esperar(d.requisitos[1].titulo:find("salta") ~= nil, "el título llega entero")
  end)

  t("aguanta acentos, comillas y saltos de línea", function (esperar)
    local d = json.decodificar('{"a":"camión \\"con\\" comillas","b":"ñandú","c":"dos\nlíneas"}')
    esperar(d ~= nil, "no devolvió nada")
    esperar(d.a == 'camión "con" comillas', "escapes: " .. tostring(d and d.a))
    esperar(d.b == "ñandú", "acentos")
    esperar(d.c == "dos\nlíneas", "salto de línea escapado")
  end)

  t("listas vacías y nulos", function (esperar)
    local d = json.decodificar('{"requisitos":[],"decision":null,"n":-3.5}')
    esperar(type(d.requisitos) == "table" and #d.requisitos == 0, "lista vacía")
    esperar(d.decision == nil, "null es nil")
    esperar(d.n == -3.5, "números negativos con decimales")
  end)

  t("un error se devuelve, no revienta", function (esperar)
    local d, err = json.decodificar('{"roto": ')
    esperar(d == nil, "no devuelve tabla")
    esperar(err ~= nil, "y dice por qué")
  end)
end
