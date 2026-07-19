# Velocidad progresiva

## Reglas

- Base: multiplicador `1.0×` sobre `LevelData.ball_speed`.
- Incremento: multiplicación acumulativa por `1.05` cada 5 segundos activos.
- Máximo: `2.0×` de la velocidad base de cada pelota.
- El contador solo avanza con gameplay activo, partida no finalizada y al menos una pelota lanzada.
- La pausa detiene automáticamente `_process`; una pelota unida no se cuenta como lanzada.

## Reinicios

La pérdida de la última pelota o la recolección de cualquier power-up llama `reset_ball_speed()`, que restablece multiplicador y tiempo. Multi Ball crea sus nuevas pelotas después del reinicio, por lo que todas nacen sincronizadas en `1.0×`.

## Cambio de nivel

El botón Siguiente llama `prepare_next_level_transition()`. El nuevo nivel conserva multiplicador y fracción de tiempo restante, pero registra cero pelotas lanzadas hasta que el jugador lance la nueva esfera. Reiniciar o entrar desde el menú no activa esta marca y comienza desde la base.
