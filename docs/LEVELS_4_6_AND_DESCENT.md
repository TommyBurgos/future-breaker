# Niveles 4–6 y descenso de bloques

## Catálogo

- Niveles 1–3: sin indestructibles y dificultad creciente mediante cantidad/resistencia.
- Nivel 4, “Centinelas gemelos”: 2 indestructibles.
- Nivel 5, “Tríada orbital”: 3 indestructibles.
- Nivel 6, “Bastión cuántico”: 4 indestructibles.

Los indestructibles están distribuidos sin cerrar completamente ninguna zona. No reciben daño, no suman puntos y no pertenecen a `destructible_blocks`; por tanto, no impiden la victoria.

## Descenso

El intervalo es 7.5 segundos de gameplay activo. Una fila equivale a 72 px, el mismo valor utilizado para ubicar las filas al construir el nivel. El movimiento dura 0.32 segundos con interpolación seno. Pausa, victoria, derrota y pelota aún unida detienen el contador.

`danger_line_y` y `danger_warning_rows` son propiedades exportadas de Gameplay. Cuando un bloque cruza el límite, `danger_handling` evita eventos duplicados, se pierde una vida y se reconstruye la distribución desde su Resource.
