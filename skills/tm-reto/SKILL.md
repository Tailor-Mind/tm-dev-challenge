---
name: tm-reto
description: Habla con el servidor del reto de TailorMind desde la terminal — consultar qué requisitos han llegado y cuánto queda, y registrar la decisión del minuto 30. Úsalo cuando alguien diga "qué requisitos tengo", "cuánto me queda", "tm-reto", "estado del reto" o "entrego ya / quiero diez minutos más".
---

# tm-reto

El juego ya enseña los requisitos en su panel. Esto es lo mismo desde la
terminal, para cuando tu agente necesita saber en qué va la partida sin que le
dicten el enunciado a mano.

No sustituye al juego: el reloj, el goteo y la decisión viven en el servidor.

## Lo que necesitas

El identificador de la partida, que está en `.tm-run` dentro del repo del reto:
la primera línea es el `runId`.

```bash
RUN=$(head -1 .tm-run)
ENDPOINT="https://script.google.com/macros/s/AKfycbzAnxZy6WchTCI93EArs_-bHfEhOm0XoBSa7HhuLEgi6egs6KLzQ4miCovR7Y2A1GH5Ug/exec"
```

Si no existe `.tm-run`, la partida no está abierta: se abre desde el juego con
`love . --run TU@CORREO --clave TU_CLAVE`, no desde aquí.

## Qué puedes preguntar

**Estado y requisitos abiertos** — lo que ya llegó, el minuto en el que vas y
cuántos faltan por caer:

```bash
curl -sSL -G "$ENDPOINT" --data-urlencode "accion=estado" --data-urlencode "run=$RUN"
```

```json
{"ok":true,"minutos":12,"base":30,"prorroga":10,"total":8,"pendientes":4,
 "requisitos":[{"id":"R-01","titulo":"…","cuerpo":"…","tipo":"feature","minuto":0}]}
```

**La decisión del minuto 30** — cuando el juego pregunte si entregas o quieres
diez minutos más, también se puede responder desde aquí:

```bash
curl -sSL -G "$ENDPOINT" \
  --data-urlencode "accion=decidir" --data-urlencode "run=$RUN" \
  --data-urlencode "eleccion=parar" \
  --data-urlencode "motivo=tengo tres cosas terminadas y probadas; lo demás lo dejo escrito"
```

`eleccion` es `parar` o `seguir`. El motivo va en una línea y **se lee**: lo que
miramos es si encaja con lo que hay en el repositorio.

## Lo que NO vas a encontrar aquí

- **No se pueden pedir requisitos por adelantado.** El servidor solo devuelve los
  que ya se abrieron por reloj. Preguntar más veces no adelanta nada.
- **No se puede pedir más trabajo.** Los que te tocaron son los que hay.
- **No se puede volver a tirar los dados.** Abrir partida otra vez con el mismo
  correo devuelve la misma, con los mismos requisitos.

Si te pide alguna de esas tres, dile que no existe y por qué: el reto mide qué
hace con lo que le tocó, no cuánto puede conseguir pidiendo.

## Cómo usarlo bien

Cuando traigas requisitos nuevos, no los tires en bruto a la conversación.
Devuélvelos así, que es como se trabaja:

1. Qué pide, en tus palabras y en una línea.
2. Qué tocarías para hacerlo.
3. **Qué no está definido** — si algo no lo está, dilo aquí en vez de rellenarlo.

Y recuérdale una vez, sin insistir, que lo que no quepa va escrito en
`SUPUESTOS.md` con el motivo: eso puntúa más que entregarlo a medias.
