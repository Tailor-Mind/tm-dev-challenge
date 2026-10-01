# El reto — TailorMind

Un juego de plataformas en Lua, en **30 a 45 minutos**, con los requisitos
llegando mientras trabajas.

**No caben.** Está hecho así a propósito: van a llegar más cosas de las que se
pueden hacer bien en ese rato, y algunas se contradicen entre sí. Intentarlo
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

## Los 30 a 45 minutos

```
love . --run TU@CORREO
```

Eso abre tu partida. A partir de ahí:

- Empiezas con **un** requisito. Los demás **van llegando con el reloj**, en el
  panel de la derecha (TAB lo esconde).
- Los requisitos **no están en este repo** y **no se pueden pedir por
  adelantado**. Tampoco puedes pedir más: los que te tocan son los que te tocan,
  y cada candidato recibe un sorteo distinto.
- Dura **entre 30 y 45 minutos**: paras cuando quieras dentro de esa ventana, y
  entregas lo que haya. **Todos los requisitos llegan dentro de los primeros 28
  minutos**, así que nadie se queda sin ver los suyos por parar antes; el último
  cae cuando ya no da tiempo a hacerlo, y eso también es parte del ejercicio.

Si te quedas sin red, el juego sigue con lo último que bajó y te lo dice. Vuelve
a haber red, vuelve a haber requisitos: no se pierde nada.

Mientras corre, el juego va escribiendo `REQUISITOS-RECIBIDOS.md` con lo que te
llegó y en qué minuto. **Ese archivo va en la entrega**: es tu copia de lo que
te tocó, y la nuestra de contra qué te corregimos.

## Por qué el reto no está en este repo

Este repo es el **armazón**: el arranque que funciona, las pruebas y el panel.
Nada más. Los requisitos se descargan cuando abres tu partida, se sortean por
candidato y se sueltan con el reloj.

El motivo es simple: que clonar esto hoy valga lo mismo que clonarlo la semana
pasada. Si el reto estuviera aquí, quien lo mire antes tendría más tiempo que
los demás, y entonces no estaríamos midiendo lo mismo en todos.

Prepara el entorno todo lo que quieras antes: instala LÖVE, lee el código, toca
el motor, practica con los de demo. Eso es tiempo tuyo y no cuenta. **Lo que
corregimos empieza cuando abres la partida** — y los commits llevan hora, así
que no hace falta que nadie se autocontrole: se ve solo.

## Qué entregas

Un repo tuyo (o un ZIP, nos da igual) con:

1. **El juego funcionando.** `love .` tiene que arrancar y jugarse. Si no
   arranca, no hay nada que mirar — y eso pasa más de lo que crees, así que
   pruébalo en limpio antes de mandarlo.
2. **`SUPUESTOS.md`** — una línea por decisión que tuviste que tomar sin que el
   requisito la definiera. Este archivo es el documento, no el anexo.
3. **`REQUISITOS-RECIBIDOS.md`**, tal como lo escribió el juego. No lo edites.
4. **Lo que dejaste fuera, y por qué.** En el mismo `SUPUESTOS.md`, al final.
   Dejar algo fuera con un motivo escrito **puntúa más** que entregarlo a medias.
5. Tus pruebas, si las escribiste. `love . --test` debería seguir en verde.

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
   buscando arquitectura de astronauta en media hora.

Y una última, que es la que más pesa: **software entregado por minuto gastado**.
Tres cosas terminadas, probadas y jugables valen más que siete a medias — y
bastante más que seis terminadas y una que rompió el juego.

Una cosa más, y va en serio: **usar IA no resta, presentarla sin leer sí**. Si
algo te lo dio el modelo y no lo verificaste, dilo. Eso no quita puntos. Lo que
no sobrevive es entregar como propio algo que nadie miró.
