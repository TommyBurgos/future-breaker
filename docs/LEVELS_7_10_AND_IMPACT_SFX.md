# Niveles 7–10 y efectos de impacto — 0.7.0

- Niveles 7 y 8: cinco bloques indestructibles cada uno.
- Niveles 9 y 10: seis bloques indestructibles cada uno.
- El progreso continúa desbloqueándose de forma secuencial hasta el nivel 10.
- Los niveles 7–10 usan provisionalmente `img_nvl6.png` y la música del tramo 6–10.
- `AudioManager` mantiene ocho reproductores SFX independientes del reproductor musical, limita cada sonido a tres voces y evita ráfagas duplicadas dentro de 28 ms.
- `brick_hit.wav` utiliza el bus `SFX` para bloques destruibles; `indestructible_hit.wav` utiliza el mismo bus con una variación de tono más grave.
