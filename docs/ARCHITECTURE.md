# Arquitectura

## Flujo

`Boot` inicializa servicios y abre `MainMenu`. La sesión conduce al selector o a `Gameplay`. Las escenas se cambian mediante `SceneManager` para impedir transiciones duplicadas.

## Autoloads

- `AppManager`: arranque coordinado.
- `SaveManager`: JSON versionado, valores por defecto y escritura temporal en `user://`.
- `SessionManager`: perfil no sensible de invitado o usuario simulado.
- `GameStateManager`: partida, puntos, vidas, victoria y derrota.
- `SceneManager`, `AudioManager` y `SignalBus`: navegación, buses de audio y eventos desacoplados.

## Gameplay

`Gameplay` carga un `LevelData`, instancia bloques y administra las pelotas. `CharacterBody2D` hace deterministas los rebotes. El bloque encapsula daño/puntuación. Los power-ups emiten un evento único y el controlador aplica Giant Paddle, Multi Ball o Phase Ball.

Cada escena de gameplay reinicia su registro local de pelotas y posiciona la pelota inicial durante `setup()`. Las transiciones de reintento/siguiente nivel quitan la pausa antes de cambiar escena. Las conexiones globales usan métodos con nombre y se desconectan en `_exit_tree()`, evitando conservar referencias de niveles anteriores.

## Capa visual Neon Cosmos

La lógica visual vive en `scripts/visual/` y no modifica el estado del gameplay. `neon_cosmos_theme.tres` centraliza estados de botones, paneles y campos. `NeonBackground`, `EnergyCore`, `NeonFrame` y `SafeAreaMargin` son componentes reutilizables. Los efectos de destrucción son instancias independientes y se pueden desactivar desde ajustes.

## Música

`AudioManager` selecciona la música según ruta de escena y nivel. Mantiene un solo reproductor persistente, configura loop en cada MP3 y realiza transiciones secuenciales sin solapamiento. `SceneManager` solicita la pista antes de cambiar de escena y `Gameplay` la confirma al iniciar, sin reiniciarla si coincide.

## Velocidad progresiva

`GameStateManager` conserva un único multiplicador, tiempo acumulado y cantidad de pelotas lanzadas. Emite el cambio mediante `SignalBus`; `Gameplay` lo aplica de forma segura a todas las `EnergyBall`. Cada pelota mantiene `base_speed`, por lo que cambiar el multiplicador no modifica su dirección. La transición al siguiente nivel marca explícitamente que debe preservarse el estado, mientras que una partida nueva o un reintento comienzan desde la velocidad base.

## Descenso y peligro

`Gameplay` acumula el intervalo de 7.5 segundos únicamente cuando `GameStateManager.launched_ball_count > 0`. El nodo padre `Blocks` se desplaza `GRID_VERTICAL_SPACING` mediante un solo Tween, garantizando sincronización y alineación. Tras el movimiento se compara el borde inferior de cada bloque con `danger_line_y`. El manejador de peligro bloquea reentradas, descuenta una vida, limpia pelotas/power-ups/bloques y reconstruye el `LevelData` original.

Los niveles 1–6 son Resources independientes. Los tipos de celda siguen siendo 0=vacío, 1=básico, 2=resistente y 3=indestructible. Solo los destruibles pertenecen al grupo que determina la victoria.

## Extender

- Nivel: crea otro `.tres` con filas 0=vacío, 1=básico, 2=resistente, 3=indestructible y agrégalo al catálogo.
- Bloque: amplía `configure()` o crea un `BlockData` para más estadísticas.
- Power-up: agrega un ID, apariencia y caso de aplicación; la caída/recolección permanece común.
- Servicio real: implementa `AuthService`, sustituye el mock y no expongas tokens al resto del juego.
