# Future Breaker 0.1.0 — Android Debug

Prototipo móvil 2D original para Godot 4.7.1. Protege un núcleo energético rebotando una esfera contra matrices corruptas.

## Abrir y ejecutar

1. Instala Godot 4.7.1 estándar.
2. Importa esta carpeta seleccionando `project.godot`.
3. Pulsa **F6/F5**. La escena inicial es `scenes/boot/boot.tscn`.

Para generar el APK de prueba consulta `docs/ANDROID_DEBUG_APK.md`. El preset incluido usa `com.scriptly.futurebreaker`, versión visible `0.1.0`, version code `1` y únicamente ARM64.

Controles: arrastra o toca horizontalmente para mover la plataforma; clic/toque lanza la esfera. En escritorio también funcionan A/D o flechas y Espacio.

## Implementado

- Flujo Boot → menú → sesión → selector → gameplay.
- Invitado persistente y autenticación local/Google simuladas.
- Diez niveles configurables, tres tipos de bloque y tres power-ups.
- Puntuación, récords, vidas, pausa, victoria, derrota y progreso local.
- Ajustes de audio/vibración sin archivos de audio obligatorios.
- UI portrait adaptable, controles táctiles y renderer Compatibility.
- Dirección visual Neon Cosmos construida con dibujo procedural, tema reutilizable, partículas ligeras y sin recursos externos.
- Música contextual en bucle: pantallas externas, niveles 1–5, 6–10 y 11 en adelante.
- Velocidad progresiva global: +5 % cada 5 segundos después del lanzamiento, limitada a 200 %.
- Descenso sincronizado de bloques cada 7.5 segundos y límite de peligro con restauración del nivel.
- Fondos espaciales adaptables por tramo: niveles 1–3, 4–5 y fondo serio para niveles 6–10.
- Efectos de impacto diferenciados para bloques destruibles e indestructibles, con pool compatible con Multi Ball.

## Estructura

`scenes/` contiene pantallas y entidades; `scripts/core/` los Autoloads; `resources/levels/` los diseños; `docs/` las guías; `tests/` las comprobaciones propuestas.

## Limitaciones conocidas

Firebase, Google Sign-In real, audio definitivo, vibración nativa, iconografía final y firma Android requieren configuración externa. El prototipo debe validarse en Godot y en un dispositivo antes de publicarse.

La opción **Efectos visuales** permite desactivar partículas y screen shake en dispositivos limitados. El fondo estelar, la estela y las pulsaciones utilizan nodos 2D simples compatibles con Compatibility.
