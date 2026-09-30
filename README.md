# El reto — TailorMind

Un juego de plataformas en Lua, en 45 minutos, con los requisitos llegando
mientras trabajas.

**No caben.** Está hecho así a propósito: van a llegar más cosas de las que se
pueden hacer bien en 45 minutos, y algunas se contradicen entre sí. Intentarlo
todo y entregar el juego roto es el peor resultado posible.

No medimos cuántos haces. Medimos **qué decides**: qué entra, qué dejas fuera,
qué preguntas y qué escribes cuando el enunciado no lo dice. Dicho de otra
forma: lo mejor que puedes hacer es entregar **la mayor cantidad de software
que funcione, en el menor tiempo, y decir en voz alta lo que sacrificaste**.

## Antes de empezar (esto no cuenta tiempo)

1. Instala **LÖVE 11.4 o superior** — <https://love2d.org>. Comprueba que está:
   ```
   love --version
   ```
2. Clona este repo y ábrelo:
   ```
   love .
   ```
   Debería aparecer un personaje que corre y salta sobre dos plataformas. Eso es
   el punto de partida, y ya funciona.
3. Corre las pruebas:
   ```
   love . --test
   ```
   Cinco pruebas en verde. Están en `tests/motor_spec.lua` y son de verdad: te
   sirven de red y de ejemplo de cómo se prueba esto sin abrir una ventana.
4. Mira `demo/requisitos-demo.md`: tres requisitos de ejemplo con la forma exacta
   que tendrán los de verdad. Practica con ellos lo que quieras. **No cuentan.**

Usa la IA que quieras, y úsala todo lo que quieras. Te lo pedimos.

## Los 45 minutos

```
love . --run TU@CORREO
```

Eso abre tu partida. A partir de ahí:

- Empiezas con **un** requisito. Los demás **van llegando con el reloj**, en el
  panel de la derecha (TAB lo esconde).
- Los requisitos **no están en este repo** y **no se pueden pedir por
  adelantado**. Tampoco puedes pedir más: los que te tocan son los que te tocan,
  y cada candidato recibe un sorteo distinto.
- Dura **45 minutos**. Cuando se acaba, se acaba: lo que esté sin terminar,
  queda sin terminar. El último requisito llega en el minuto 41, cuando ya no da
  tiempo — eso también es parte del ejercicio.

Si te quedas sin red, el juego sigue con lo último que bajó y te lo dice. Vuelve
a haber red, vuelve a haber requisitos: no se pierde nada.

## Qué entregas

Un repo tuyo (o un ZIP, nos da igual) con:

1. **El juego funcionando.** `love .` tiene que arrancar y jugarse. Si no
   arranca, no hay nada que mirar — y eso pasa más de lo que crees, así que
   pruébalo en limpio antes de mandarlo.
2. **`SUPUESTOS.md`** — una línea por decisión que tuviste que tomar sin que el
   requisito la definiera. Este archivo es el documento, no el anexo.
3. **Lo que dejaste fuera, y por qué.** En el mismo `SUPUESTOS.md`, al final.
   Dejar algo fuera con un motivo escrito **puntúa más** que entregarlo a medias.
4. Tus pruebas, si las escribiste. `love . --test` debería seguir en verde.

## Cómo está montado

```
main.lua            arranque, teclado, bucle
conf.lua            la ventana
src/motor.lua       física, colisiones y estado — Lua puro, sin love.*
src/pintar.lua      lo que se ve
src/requisitos.lua  el cliente del goteo
tests/              el corredor de pruebas y los casos de demo
```

La separación entre `motor.lua` y `pintar.lua` está puesta a propósito: la lógica
se prueba sin abrir ventana, y por eso las pruebas tardan medio segundo. Puedes
romper esa separación si quieres — pero entonces dilo en `SUPUESTOS.md` y di por
qué, que para eso está.

## Lo que miramos al corregir

En este orden:

1. **Qué dejaste fuera y si lo dijiste.** Hacerlo todo no es una opción: no cabe.
   Elegir sí, y elegir bien se nota.
2. **`SUPUESTOS.md`.** Cuando un requisito no define algo — y alguno no lo va a
   definir — la respuesta buena nunca es rellenar el hueco en silencio. Es
   preguntarlo, o dejar escrito lo que asumiste.
3. **Que arranque y se juegue.** Sin ceremonia: `love .` y ya.
4. **El código**, al final. Si se lee y las pruebas pasan, está bien. No estamos
   buscando arquitectura de astronauta en 45 minutos.

Y una última, que es la que más pesa: **software entregado por minuto gastado**.
Tres cosas terminadas, probadas y jugables valen más que siete a medias — y
bastante más que seis terminadas y una que rompió el juego.

Una cosa más, y va en serio: **usar IA no resta, presentarla sin leer sí**. Si
algo te lo dio el modelo y no lo verificaste, dilo. Eso no quita puntos. Lo que
no sobrevive es entregar como propio algo que nadie miró.
