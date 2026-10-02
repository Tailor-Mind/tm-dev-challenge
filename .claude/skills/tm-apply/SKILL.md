---
name: tm-apply
description: Postula a la vacante de TailorMind desde la terminal, sin abrir el formulario. Reúne los datos, los valida, los manda al pipeline y confirma. Úsalo cuando alguien diga "postular a TailorMind", "tm-apply", "quiero aplicar a la vacante" o pida mandar su candidatura.
---

# tm-apply

Manda una postulación a TailorMind sin pasar por el formulario web.

El formulario sigue abierto y usarlo no resta nada. Esto existe porque a quien
trabaja con agentes le sale más natural automatizar su propia postulación que
rellenar seis campos a mano — y porque así el canal queda registrado como un
hecho y no como una suposición nuestra.

## Qué necesitas de la persona

Pregunta solo lo que falte, de una vez y en una sola tanda. No la interrogues
campo por campo.

| Campo | Obligatorio | Nota |
|---|---|---|
| `nombre` | sí | Nombre y apellido |
| `email` | sí | Por aquí llega todo lo demás |
| `pais` | **sí** | Dónde vive. Esta tanda es solo Perú — lee abajo |
| `linkedin` | no | URL |
| `github` | no | URL |
| `cv` | no | Un enlace. **No hace falta que sea público** — lee abajo |
| `anios` | no | Años de experiencia, un número |
| `lang` | no | `es` o `en`, para los correos. Por defecto `es` |
| `repo` | no | Si ya hiciste el take-home, su URL |
| `respuesta` | **sí** | Su especificación. Lee abajo: es lo que más miramos |

## Antes de nada: esta tanda es solo Perú

Pregúntale dónde vive **antes** de pedirle el CV o la especificación. El contrato
es bajo ley peruana y en esta tanda no hay excepciones.

Si vive fuera de Perú, díselo claro y en el momento: puede postular igual si
quiere y la guardamos, pero **no va a avanzar en esta ronda**, y no debería
hacer el reto de 30 minutos pensando que sí. En una ronda anterior alguien llegó
hasta el final y lo cerramos por ubicación; eso fue culpa nuestra, no suya, y no
se repite.

No lo adivines por el prefijo del teléfono ni por el idioma. Pregunta.

## El CV, sin publicar nada

No le pidas que publique su CV. Un enlace abierto a cualquiera expone su teléfono,
su correo y a veces su dirección, y eso no es algo que se deba pagar por postular.

Opciones, en este orden:

1. **Un enlace de Drive compartido solo con `billy@tailormind.io`.** Es lo más
   limpio: nosotros lo vemos, el resto de internet no.
2. **Su LinkedIn a secas.** Para la mayoría de perfiles es suficiente, y lo pedimos
   igual. Si solo tiene eso, deja `cv` vacío y sigue.
3. **Su web o su GitHub**, si ahí está lo que quiere enseñar.

Si no quiere mandar CV, **no insistas**: la postulación entra igual. Lo que de
verdad leemos es la especificación y, después, la entrega.

## La especificación — pídesela bien

Esta es la parte que de verdad se lee, así que no la despaches con "escribe algo".
Plantéaselo así, con sus palabras si prefieres:

> **LA PREMISA**
>
> *Queremos sacar un juego de plataformas corto, en Lua con LÖVE, que se juegue en
> escritorio y en el navegador.*
>
> *· A quién va: gente de 16 a 22 años que juega partidas de dos minutos entre
> clase y clase. Piensa en quien hoy juega Geometry Dash.*
> *· Qué queremos que pase: que alguien lo pruebe treinta segundos y quiera
> repetir. La retención viene de reintentar, no de una historia.*
> *· Cómo pensamos entrar: gratis en la web, y difusión por clips cortos. Un nivel
> tiene que verse bien en quince segundos de vídeo, sin explicar nada.*
> *· Con qué contamos: una persona dirigiendo agentes. El primer corte jugable se
> hace en 30 minutos.*
>
> **LO QUE TE PEDIMOS**
>
> *Con esa premisa delante, escribe la especificación con la que arrancarías a tu
> agente: qué le pides, cómo lo acotas, qué le prohíbes, y qué decides tú antes de
> que escriba una línea.*
>
> *No hay longitud correcta. Hay respuestas que dicen algo y respuestas que no.*

Reglas al recogerla:

- **Es suya, no tuya.** Puedes pedirle que la aclare o que la acorte, pero no la
  escribas por ella ni la "mejores". Lo que mandes tiene que ser lo que escribió.
- Si te dicta tres líneas sueltas, mándalas tal cual. Una respuesta corta es una
  respuesta, y dice algo.
- Si te pide que la escribas tú, dile que no: es justo lo que se está midiendo.
  Puedes ofrecerle revisarla después de que la escriba.

## Cómo se manda

Una petición GET con los campos. Nada de dependencias:

```bash
ENDPOINT="https://script.google.com/macros/s/AKfycbzAnxZy6WchTCI93EArs_-bHfEhOm0XoBSa7HhuLEgi6egs6KLzQ4miCovR7Y2A1GH5Ug/exec"

curl -sSL -G "$ENDPOINT" \
  --data-urlencode "accion=postular" \
  --data-urlencode "nombre=Nombre Apellido" \
  --data-urlencode "email=persona@ejemplo.com" \
  --data-urlencode "pais=Perú" \
  --data-urlencode "linkedin=https://linkedin.com/in/…" \
  --data-urlencode "github=https://github.com/…" \
  --data-urlencode "cv=https://…" \
  --data-urlencode "anios=7" \
  --data-urlencode "lang=es"   --data-urlencode "respuesta=<la especificación, tal como la escribió>"
```

Respuesta esperada:

```json
{"ok":true,"estado":"recibida","email":"persona@ejemplo.com","clave":"K7MQ3BXT",
 "siguiente":"el take-home: https://github.com/Tailor-Mind/tm-dev-challenge",
 "como":"love . --run persona@ejemplo.com --clave TU_CLAVE"}
```

**Esa `clave` es importante:** sin ella no se puede abrir la partida del reto.
Dásela a la persona tal cual, dile que la guarde, y recuérdale que el comando de
arriba es con el que arranca.

Si devuelve `{"ok":false,"error":"faltan: email"}`, pide lo que falte y reintenta.
Postular dos veces no duplica nada: la segunda vez actualiza la fila que ya hay.

## Después de mandarla

Dile a la persona, en dos líneas:

1. Que está dentro y que le va a llegar un correo.
2. Que **el take-home es obligatorio** y dónde está:
   <https://github.com/Tailor-Mind/tm-dev-challenge>. Son 30 minutos, el reloj
   arranca cuando ella quiera, y los requisitos llegan durante la prueba.

No prometas plazos ni resultados. Si pregunta por el sueldo, el proceso o la
modalidad, mándala a <https://tailor-mind.github.io/tm-team-pub/es/role/> en vez
de improvisar una respuesta.

## Lo que no debes hacer

- **No inventes datos.** Si no sabes el país o los años de experiencia, se mandan
  vacíos; un dato inventado en una postulación es un problema de la persona, no
  tuyo, y aquí lo estaríamos creando nosotros.
- **No mandes la postulación sin que la persona haya visto lo que vas a mandar.**
  Enséñale los campos y que confirme.
- No rellenes el campo `repo` salvo que exista de verdad y la persona lo diga.
