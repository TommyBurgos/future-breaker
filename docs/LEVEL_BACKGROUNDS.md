# Fondos por nivel — actualizado en 0.7.0

La escena de juego precarga tres texturas y elige automáticamente una según el nivel:

- Niveles 1–3: `img_nvl1A3.png`
- Niveles 4–5: `img_nvl4y5.png`
- Niveles 6–10: `img_nvl6.png`

`GameplayBackground` es un `CanvasLayer` con capa `-10`, situado detrás de toda la jugabilidad y del HUD. Su `TextureRect` ignora el mouse, usa anchors completos, `IGNORE_SIZE` y `KEEP_ASPECT_COVERED`, por lo que conserva la proporción y cubre pantallas verticales sin repetición.

La propiedad exportada `background_dim_opacity` de la escena Gameplay controla la capa oscura sin alterar los PNG originales. El valor predeterminado es `0.18`.

Para verificarlo en Godot, inicia los niveles 1, 3, 4, 5 y 6 desde Selección de nivel; comprueba además Reiniciar, Continuar y Siguiente nivel.
