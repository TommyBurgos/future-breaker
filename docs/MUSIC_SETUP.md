# Música contextual

## Distribución

- `space.mp3`: Boot, menú, autenticación, selector y ajustes.
- `TallGrass.mp3`: niveles 1–5.
- `TallGrass2.mp3`: niveles 6–10. Corresponde al archivo adjunto originalmente llamado `Run.mp3`.
- `cyberpunk-gaming.mp3`: nivel 11 en adelante.

`AudioManager` utiliza un solo `AudioStreamPlayer` en el bus `Music`. Al cambiar de pista realiza fade-out, reemplaza el stream y hace fade-in; por ello no hay canciones superpuestas. Si la pista solicitada ya está sonando, no se reinicia. Los cuatro `AudioStreamMP3` activan `loop` al iniciar.

## Comprobación en Godot

1. Abre el proyecto y confirma que los MP3 aparecen en `assets/audio/music/` sin errores de importación.
2. Ejecuta normalmente: Boot, menú, login, niveles y ajustes deben conservar `space.mp3` sin reiniciarla.
3. Inicia cualquiera de los niveles 1–5: debe entrar `TallGrass.mp3` con transición gradual.
4. Para probar rangos aún no incluidos en el prototipo, ejecuta temporalmente desde el depurador remoto `AudioManager.play_game_music(6)` y luego `AudioManager.play_game_music(11)`. Deben sonar `TallGrass2.mp3` y `cyberpunk-gaming.mp3` respectivamente.
5. Ejecuta `AudioManager.play_game_music(6)` dos veces y confirma que la segunda llamada no reinicia la pista.
6. En Ajustes mueve Música y Volumen general; coloca el control en cero para verificar silencio. Reinicia el juego y confirma persistencia.

El nivel 6 ya permite comprobar automáticamente `TallGrass2.mp3`. Los niveles 7–10 y 11+ todavía requieren contenido futuro o una llamada de prueba desde el Evaluador.
