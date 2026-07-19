# Lista de pruebas manuales

## Arranque y menús

- [ ] El proyecto abre sin errores en Godot 4.7.1 y Boot llega al menú.
- [ ] Invitado crea ID una sola vez y se recupera tras reiniciar.
- [ ] Login/registro validan email, longitud y confirmación; indican que son mock.
- [ ] Selector bloquea niveles no alcanzados y muestra récord por nivel.
- [ ] Reiniciar progreso pide confirmación y conserva ajustes.

## Gameplay

- [ ] Toque/arrastre/mouse y teclado mueven suavemente la plataforma sin salir del área.
- [ ] La esfera inicia unida, se lanza y rebota sin ángulos estancados.
- [ ] Bloques 1/2 golpes cambian/desaparecen; indestructibles no cuentan para victoria.
- [ ] Solo se suma una vez por bloque; récord y desbloqueo persisten.
- [ ] La vida baja solo cuando cae la última pelota; con 0 vidas aparece derrota.
- [ ] Pausa, continuar, reiniciar, menú, victoria y siguiente nivel funcionan.
- [ ] Completar nivel 1 y pulsar siguiente carga nivel 2 sin pausa; aparece una pelota unida a la plataforma.
- [ ] Repetir transiciones 1→2→3 y confirmar una sola actualización de HUD por evento, sin referencias antiguas.

## Power-ups

- [ ] Giant Paddle duplica ancho, recolección repetida no acumula escala y restaura a 1×.
- [ ] Multi Ball crea hasta cinco pelotas y no descuenta vidas múltiples.
- [ ] Phase Ball atraviesa bloques, rebota en pared/plataforma y restaura apariencia/colisión.

## Dispositivos

- [ ] Probar 720×1280, 1080×1920, 1080×2340 y tablet; nada queda bajo notch/barras.
- [ ] Probar APK ARM64, suspensión/reanudación, audio apagado, vibración y modo offline.
- [ ] Mantener 60 FPS en gama media y revisar memoria durante 20 minutos.
- [ ] Verificar estados normal, hover, presionado, deshabilitado y focus de botones.
- [ ] Confirmar que notch y barras no cubren Boot, menú ni HUD.
- [ ] Desactivar Efectos visuales y confirmar que partículas/screen shake se reducen sin afectar gameplay.
- [ ] Confirmar estela normal cian y Phase Ball magenta; Giant Paddle cambia a violeta sin acumular escala.

## Música

- [ ] `space.mp3` continúa sin reiniciarse al navegar entre pantallas externas.
- [ ] Niveles 1–5 reproducen `TallGrass.mp3` en loop.
- [ ] Solicitar nivel 6 reproduce `TallGrass2.mp3`; nivel 11 reproduce `cyberpunk-gaming.mp3`.
- [ ] Cambiar de rango realiza fade-out/fade-in sin dos reproductores simultáneos.
- [ ] Volumen general/música en cero silencia; los valores persisten al reiniciar.
- [ ] Pausar/reanudar la aplicación pausa/reanuda la música y cerrar detiene el reproductor.

## Velocidad progresiva

- [ ] Antes de lanzar, esperar más de 5 segundos: la velocidad permanece en `1.0×`.
- [ ] Lanzar y esperar 5 segundos: aparece `VELOCIDAD x1.05` y todas las pelotas aceleran.
- [ ] Confirmar aumentos acumulativos cada 5 segundos y límite exacto `2.0×`.
- [ ] Pausar durante más de 5 segundos: el contador no avanza.
- [ ] Perder la última pelota: velocidad y temporizador vuelven a la base antes de reaparecer.
- [ ] Recoger Giant Paddle, Multi Ball y Phase Ball: cada uno reinicia velocidad y temporizador.
- [ ] Con Multi Ball, todas las pelotas mantienen el mismo multiplicador y solo se reinicia al caer la última.
- [ ] Completar un nivel acelerado y pulsar Siguiente: la nueva pelota conserva el multiplicador; no acelera hasta lanzarse.
- [ ] Reintentar el nivel o entrar desde el selector: comienza en `1.0×`.

## Niveles y descenso

- [ ] Inspeccionar niveles 1–3: contienen cero bloques indestructibles.
- [ ] Niveles 4, 5 y 6 contienen exactamente 2, 3 y 4 indestructibles.
- [ ] Completar cada nivel ignorando los indestructibles confirma la victoria.
- [ ] Completar nivel 3 desbloquea 4; completar 4 desbloquea 5; completar 5 desbloquea 6, incluso tras reiniciar la aplicación.
- [ ] Lanzar la pelota y medir 7.5 segundos: toda la cuadrícula baja exactamente una fila con un único Tween.
- [ ] Pausar antes de 7.5 segundos: el descenso conserva el tiempo restante y no avanza durante pausa.
- [ ] Perder la última pelota reinicia el intervalo de descenso; recoger power-ups no lo reinicia.
- [ ] Al acercarse a dos filas del límite aparece la advertencia visual.
- [ ] Al cruzar el límite se descuenta exactamente una vida y se restauran layout, pelota y temporizador.
- [ ] Con cero vidas por peligro aparece derrota sin descuentos duplicados.
- [ ] Nivel 6 reproduce `TallGrass2.mp3`; niveles 1–5 mantienen `TallGrass.mp3`.
