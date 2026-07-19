# Corrección de menú y selección de niveles — 0.5.1

- El menú principal ofrece **INICIAR JUEGO**, que crea una sesión de invitado cuando hace falta y comienza siempre desde el nivel 1.
- Para sesiones activas se conserva **CONTINUAR**, que abre el último nivel guardado.
- Al cargar un guardado, `unlocked_levels` se normaliza desde el nivel 1 hasta el nivel máximo alcanzado. Esto repara guardados antiguos que contenían, por ejemplo, `[4, 5, 6]` y bloqueaban incorrectamente los niveles 1–3.
- La normalización no elimina puntuaciones, sesión, ajustes ni progreso, y no desbloquea niveles posteriores al máximo ya alcanzado.
