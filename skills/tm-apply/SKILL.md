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
| `pais` | no | Dónde vive, para la vía de contratación |
| `linkedin` | no | URL |
| `github` | no | URL |
| `cv` | no | Un enlace público: Drive, web personal, lo que sea |
| `anios` | no | Años de experiencia, un número |
| `lang` | no | `es` o `en`, para los correos. Por defecto `es` |
| `repo` | no | Si ya hiciste el take-home, su URL |

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
  --data-urlencode "lang=es"
```

Respuesta esperada:

```json
{"ok":true,"estado":"recibida","email":"persona@ejemplo.com","siguiente":"el take-home: https://github.com/Tailor-Mind/tm-dev-challenge"}
```

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
