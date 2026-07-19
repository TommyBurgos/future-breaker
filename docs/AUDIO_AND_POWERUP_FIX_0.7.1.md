# Correcciones de audio y power-ups — 0.7.1

- Se corrigió `default_bus_layout.tres` declarando el tipo `AudioBusLayout` requerido por Godot 4.7.1.
- `AudioManager` crea de forma defensiva los buses `Music` y `SFX` si el recurso no estuviera disponible.
- Los impactos reciben ganancia propia (+16 dB normal, +17 dB indestructible) antes del volumen configurable del bus `SFX`.
- Se inicializó explícitamente el reproductor disponible del pool para eliminar la advertencia `UNASSIGNED_VARIABLE`.
- La recolección de power-ups utiliza `set_deferred()` y una bandera contra reentrada.
- Multi Ball crea las nuevas pelotas mediante una llamada diferida, fuera del vaciado de consultas físicas.
