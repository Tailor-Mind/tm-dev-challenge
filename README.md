# El reto — TailorMind

Un juego de plataformas en Lua, en **30 minutos** — con una decisión al final
que puede darte 10 más. Los requisitos llegan mientras trabajas.

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
   Diez pruebas en verde, en `tests/`. Son de verdad: te sirven de red y de
   ejemplo de cómo se prueba esto sin abrir una ventana. La de sintaxis compila
   todos los ficheros del repo, `main.lua` incluido.
4. Mira `demo/requisitos-demo.md`: tres requisitos de ejemplo con la forma exacta
   que tendrán los de verdad. Practica con ellos lo que quieras. **No cuentan.**

Usa la IA que quieras, y úsala todo lo que quieras. Te lo pedimos.

## Primero el plan, y no cuenta tiempo

Al arrancar con `--run` **no empieza el reloj**: lo primero que sale es tu plan.

Cinco decisiones y una línea: quién escribe el código, quién escribe las pruebas,
qué revisas de lo que te devuelve el agente, si pruebas a mano, a qué dedicas más
de los 30 minutos, y qué vas a hacer cuando llegue algo que no cabe.

Ninguna opción es la correcta. Delegar el código entero y no revisar nada es
defendible si lo que entregas funciona; escribirlo todo a mano también, si te da
tiempo. **El reloj arranca cuando sellas**, y el plan queda en `PLAN-SELLADO.md`,
que va en la entrega.

Lo que miramos después no es el plan: es **la distancia entre el plan y lo que
pasó**. Nadie lo cumple entero. Lo que distingue es si la diferencia fue una
decisión o un atropello — y si está dicha.

## Los 30 minutos, y la decisión

```
love . --run TU@CORREO
```

Eso abre tu partida. A partir de ahí:

- Empiezas con **un** requisito. Los demás **van llegando con el reloj**, en el
  panel de la derecha (TAB lo esconde).
- Los requisitos **no están en este repo** y **no se pueden pedir por
  adelantado**. Tampoco puedes pedir más: los que te tocan son los que te tocan,
  y cada candidato recibe un sorteo distinto.
- Dura **30 minutos**. Todos los requisitos llegan dentro de los primeros 28, así
  que los ves todos; el último cae cuando ya no da tiempo a hacerlo, y eso también
  es parte del ejercicio.
- **En el minuto 30 el juego para y te pregunta una sola cosa:** ¿lo que tienes
  entregado ya vale, o quieres diez minutos más? Las dos respuestas están bien, y
  ninguna puntúa por sí sola. Se te pide el motivo en una línea, y **esa línea es
  parte de la evaluación**: lo que miramos es si encaja con lo que hay en el disco.
- O sea: **30 minutos, 40 como máximo** si pides la prórroga.

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
2. **`PLAN-SELLADO.md`**, tal como lo escribió el juego. No lo edites.
3. **`SUPUESTOS.md`** — una línea por decisión que tuviste que tomar sin que el
   requisito la definiera. Este archivo es el documento, no el anexo.
3. **`REQUISITOS-RECIBIDOS.md`**, tal como lo escribió el juego. No lo edites.
4. **Lo que dejaste fuera, y por qué.** En el mismo `SUPUESTOS.md`, al final.
   Dejar algo fuera con un motivo escrito **puntúa más** que entregarlo a medias.
5. Tus pruebas, si las escribiste. `love . --test` debería seguir en verde.

## Esto no es código de confianza

Este armazón se escribió rápido, como el código que vas a heredar en cualquier
trabajo de verdad. No lo des por bueno porque venga de nosotros.

Las pruebas que trae cubren el camino feliz y poco más. **Un test en verde dice
que esa entrada concreta funciona, no que la función esté bien** — y eso vale
tanto para lo que te damos como para lo que escribas tú.

Si te topas con algo que no hace lo que dice, es decisión tuya: arreglarlo,
acotarlo con un test, o dejarlo escrito en `SUPUESTOS.md` y seguir con lo tuyo.
Cualquiera de las tres está bien. Lo que no, es construir encima sin mirar y que
acabe en tu entrega con tu nombre.

## Los skills, por si trabajas con un agente

En `skills/` hay dos, listos para que los lea tu asistente:

- **`tm-apply`** — postular desde la terminal, sin abrir el formulario.
- **`tm-reto`** — preguntar al servidor qué requisitos han llegado, cuánto queda,
  y registrar la decisión del minuto 30.

No hace falta usarlos: el formulario y el panel del juego hacen lo mismo. Están
porque a quien trabaja con agentes le sale más natural así, y porque leerlos te
dice exactamente qué se puede pedir al servidor y qué no.

Spoiler de lo que no se puede: pedir requisitos por adelantado, pedir más de los
que te tocaron, y volver a tirar los dados.

## Recargar tus cambios

LÖVE no recarga en caliente: hay que reiniciar el juego para ver lo que tocaste.
**F5 lo hace** — tarda menos de un segundo.

Reiniciar no te cuesta nada del reto:

- El reloj lo lleva el servidor, no el juego. Cerrar la ventana no lo para, y
  volver a abrirla no lo reinicia.
- Tu partida queda apuntada en `.tm-run`, así que al abrir otra vez **se reanuda
  la misma**: no se abre una nueva, no pierdes los requisitos que ya llegaron, y
  no vuelves a pasar por la pantalla del plan.
- Vale `love .` a secas, sin repetir `--run`.

Si el juego revienta por un error tuyo, pasa lo mismo: lo arreglas, lo vuelves a
abrir y sigues donde estabas.

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
