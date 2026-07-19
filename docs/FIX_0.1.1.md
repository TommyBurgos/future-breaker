# Corrección 0.1.1

## Causa

La victoria pausaba el `SceneTree`; los botones **Siguiente nivel** y **Reintentar** recargaban la escena sin quitar esa pausa. La pelota se instanciaba y `active_balls` pasaba a 1, pero su posición unida a la plataforma solo se actualizaba en `_physics_process()`. Al seguir pausada la escena nueva, permanecía en `(0,0)` y no era visible.

## Cambios

- Las transiciones quitan la pausa y pasan por `SceneManager`.
- La pelota recibe su posición inicial inmediatamente en `setup()`.
- El contador local de pelotas y el temporizador Phase Ball se reinician al entrar en cada nivel.
- Las conexiones del HUD ahora usan métodos con nombre y se desconectan al salir.
- `SignalBus` encapsula la emisión de sus propias señales.
- El parámetro `position` fue renombrado para no ocultar `Node2D.position`.
