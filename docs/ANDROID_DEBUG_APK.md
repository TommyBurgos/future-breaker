# APK Android de prueba — Future Breaker 0.1.0

Este proyecto incluye el preset **Android Debug** para generar exclusivamente un APK ARM64 de prueba. No genera AAB, no publica en Google Play y no contiene claves de producción.

## 1. Generar directamente desde Godot 4.7.1

Requisitos:

- Godot 4.7.1 estándar y sus Export Templates 4.7.1.
- OpenJDK 17.
- Android SDK con Platform Tools, Android Platform 35 y Build Tools 35.0.1. Para reproducir exactamente la nube, instala también Command-line Tools latest, CMake 3.10.2.4988404 y NDK r28b.

Pasos:

1. Abre `project.godot` con Godot 4.7.1 y espera que finalice la importación.
2. En **Editor → Editor Settings → Export → Android**, configura Android SDK, Java SDK y el debug keystore estándar.
3. Abre **Project → Export**.
4. Selecciona **Android Debug**.
5. Verifica que el formato sea APK, arquitectura ARM64 y paquete `com.scriptly.futurebreaker`.
6. Pulsa **Export Project** y guarda como `build/FutureBreaker-debug.apk`.

También puede ejecutarse desde una terminal correctamente configurada:

```bash
godot --headless --editor --path . --import
godot --headless --path . --export-debug "Android Debug" build/FutureBreaker-debug.apk
```

## 2. Subir el proyecto a GitHub

1. Crea un repositorio vacío en GitHub.
2. Copia el proyecto completo, incluyendo `.github/workflows/build-android-debug.yml` y `export_presets.cfg`.
3. No subas `.godot`, `android`, keystores, contraseñas ni archivos de producción.
4. Confirma los archivos y realiza `push` a la rama principal.

## 3. Ejecutar GitHub Actions manualmente

1. Abre el repositorio en GitHub.
2. Entra en **Actions**.
3. Selecciona **Build Android Debug APK**.
4. Pulsa **Run workflow** y confirma la rama.
5. Espera que finalice **Godot 4.7.1 Android Debug** en color verde.

El workflow descarga exactamente Godot 4.7.1 y sus templates, configura JDK 17 y Android SDK, crea una clave debug temporal con una contraseña aleatoria solo durante la ejecución, importa el proyecto, ejecuta una prueba headless y exporta el APK. Si falla, conserva un artifact separado con los logs. La clave y su contraseña no se suben como artifacts ni se guardan en el repositorio.

## 4. Descargar el artifact

1. Abre la ejecución finalizada desde **Actions**.
2. Baja hasta **Artifacts**.
3. Descarga **FutureBreaker-debug-apk**.
4. Si la compilación falla, descarga **FutureBreaker-android-build-logs** y revisa primero `import.log`, `smoke-test.log` y `android-export.log`.

## 5. Extraer el APK

GitHub entrega el artifact como ZIP. Extráelo y confirma que contiene `FutureBreaker-debug.apk` con tamaño mayor que cero.

## 6. Copiarlo al teléfono

Conecta el teléfono por USB y copia el APK a **Descargas**, o transfiérelo por Drive, correo o una aplicación de archivos. No cambies su extensión.

## 7. Permitir temporalmente fuentes desconocidas

En Android abre **Ajustes → Seguridad/Privacidad → Instalar aplicaciones desconocidas**. Autoriza solamente la aplicación desde la que abrirás el APK, por ejemplo **Archivos** o el navegador. La ruta exacta cambia según el fabricante.

Revoca este permiso después de instalarlo.

## 8. Instalar

Abre `FutureBreaker-debug.apk`, pulsa **Instalar** y después **Abrir**. Android puede mostrar que es una aplicación de prueba o de origen desconocido; esto es normal para un APK debug.

## 9. Actualizar una instalación anterior

Instala el nuevo APK sobre el anterior si ambos utilizan `com.scriptly.futurebreaker` y una firma compatible. El workflow crea una clave debug temporal nueva en cada ejecución, por lo que Android puede rechazar la actualización entre artifacts distintos. En ese caso desinstala la versión anterior e instala la nueva; la desinstalación elimina los datos locales.

Para actualizaciones debug conservando datos desde una computadora, usa siempre el mismo `~/.android/debug.keystore`; nunca conviertas esa clave en una firma de producción.

## 10. Recopilar errores y logs del teléfono

Activa **Opciones de desarrollador → Depuración USB**, conecta el dispositivo y ejecuta:

```bash
adb logcat -c
adb logcat | findstr /I "godot futurebreaker script error"
```

En Linux o macOS sustituye `findstr` por `grep -Ei`. Para detener la captura pulsa `Ctrl+C` y guarda la salida en un archivo de texto.

## Pruebas en un dispositivo real

- Abrir el juego sin cierre inesperado.
- Confirmar orientación vertical, pantalla adaptable y modo inmersivo.
- Escuchar la música del menú.
- Probar por separado volumen general, música y efectos.
- Iniciar como invitado.
- Mover la plataforma con el dedo y lanzar la pelota.
- Jugar y desbloquear progresivamente los niveles 1–10.
- Comprobar los fondos de los niveles 1–3, 4–5 y 6–10.
- Escuchar ambos sonidos de impacto.
- Probar Giant Paddle, Multi Ball y Phase Ball.
- Pausar y continuar.
- Perder una vida y verificar la restauración correcta.
- Completar un nivel y avanzar al siguiente.
- Cerrar completamente y volver a abrir el juego.
- Verificar progreso, récords y configuración persistentes.
