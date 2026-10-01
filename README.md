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

## Qué necesitas

Windows, macOS o Linux, da igual:

- **LÖVE 11.4 o superior** — <https://love2d.org>
- **`curl`**, solo si tu compilación de LÖVE no trae el módulo `https`. Viene de
  serie en Windows 10+, macOS y casi todo Linux; compruébalo con `curl --version`.

Nada más: ni luarocks, ni dependencias, ni build. El panel del juego te dice por
qué vía está hablando con el servidor.

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
- Dura **30 minutos**. Los requisitos caen en los minutos **0, 4, 8, 12, 16, 20,
  24 y 28**: los ves todos, y el último llega cuando ya no da tiempo a hacerlo.
  Eso también es parte del ejercicio.
- **Puedes entregar antes.** Con `E` cierras la prueba cuando quieras: te pide el
  motivo en una línea y se acabó. Terminar pronto con cosas acabadas y probadas
  es un resultado, no una rendición — y quedarse mirando el reloj no suma nada.
- **Un requisito, un commit.** Pon su id en el mensaje: `R-10: monedas y
  marcador`. No es burocracia: es la única forma de ver qué hiciste y en qué
  orden, y de que un cambio que rompe algo se pueda señalar sin adivinar.
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

Un repo tuyo, público, con:

1. **El juego funcionando.** `love .` tiene que arrancar y jugarse. Si no
   arranca, no hay nada que mirar — y eso pasa más de lo que crees, así que
   pruébalo en limpio antes de mandarlo.
2. **`chat.md` — la conversación entera con tu agente.** No es un anexo:
   **sin transcripción no evaluamos la entrega.** Lee el apartado de abajo.
3. **`PLAN-SELLADO.md`** y **`REQUISITOS-RECIBIDOS.md`**, tal como los escribió el
   juego. No los edites.
4. **`SUPUESTOS.md`** — una línea por decisión que tuviste que tomar sin que el
   requisito la definiera, y al final lo que dejaste fuera con su motivo. Dejar
   algo fuera por escrito **puntúa más** que entregarlo a medias.
5. Tus pruebas, si las escribiste. `love . --test` debería seguir en verde.

### La transcripción, en serio

Pega en `chat.md` la sesión completa con tu agente: tus prompts, lo que te
devolvió, las correcciones, los callejones sin salida y lo que descartaste.
**Cruda, sin editar y sin resumir.**

Es lo que más miramos, y por un motivo sencillo: el código terminado se parece
bastante de un candidato a otro, y la conversación no se parece en nada. Ahí se
ve cómo acotas, cuándo corriges, qué aceptas sin leer y en qué momento decides
que algo no cabe.

Con Claude Code, `/export` te la deja en un fichero. Con otros asistentes, copiar
y pegar basta.

Que se vea que algo te costó, que te equivocaste o que el modelo te mandó a un
callejón **no resta**. Una transcripción demasiado limpia sí hace preguntarse qué
falta.

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

## Postular: se hace desde aquí

Clonas, abres tu agente en esta carpeta y escribes:

```
/tm-apply
```

Eso es todo. El repo trae el skill en `.claude/skills/tm-apply/`, así que tu
agente lo ve nada más abrirlo. Te va a pedir tus datos y, sobre todo, **la
especificación con la que arrancarías este reto**, que es lo que de verdad
leemos. Te devuelve tu clave: guárdala, sin ella no se abre la partida.

Funciona con Claude Code tal cual. Si usas otro asistente, ábrele
`.claude/skills/tm-apply/SKILL.md` y pídele que lo siga — es un fichero de texto
con un `curl` dentro, no hay magia.

¿Y si no quieres usar un agente para postular? Está el
[formulario](https://tailor-mind.github.io/tm-team-pub/es/apply/) y no resta
nada. Pero el puesto consiste en dirigir agentes, así que empezar por ahí dice
algo de cómo trabajas — y nosotros lo apuntamos.

El otro skill es **`/tm-reto`**: pregunta al servidor qué requisitos llegaron,
cuánto queda y registra la decisión del minuto 30. Léelo aunque no lo uses: dice
exactamente qué se le puede pedir al servidor y qué no. Lo que **no** se puede:
requisitos por adelantado, más de los que te tocaron, y volver a tirar los dados.

## Si rompes el juego, no rompes la prueba

Tu código corre dentro de una red. Si lanza un error, **no se cierra nada**: lo
ves en pantalla, el reloj sigue, los requisitos siguen llegando y lo que decidas
se sigue registrando. Lo arreglas y pulsas `R`.

Eso es a propósito. Lo único que no puede fallar es lo que deja constancia de tu
trabajo, así que el reloj y el envío van por delante del juego y no dependen de
él. Si aun así el panel se cayera, el reloj del servidor sigue corriendo y la
decisión del minuto 30 se puede mandar desde la terminal con el skill `tm-reto`.

Y si el juego ni siquiera arranca por un error de sintaxis, nada se pierde: la
partida vive en el servidor, y `PLAN-SELLADO.md` y `REQUISITOS-RECIBIDOS.md`
están escritos en disco desde el minuto cero.

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
