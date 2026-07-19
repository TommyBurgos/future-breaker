# Firebase y Google Sign-In

1. Crea un proyecto Firebase y registra Android con `com.scriptly.futurebreaker`.
2. Descarga `google-services.json`; evita publicarlo en repositorios públicos.
3. Registra SHA-1 y SHA-256 del certificado usado.
4. Activa Email/Password y Google en Authentication.
5. Elige un plugin compatible con Godot 4.7 cuya procedencia, licencia y mantenimiento puedas verificar.
6. Implementa el adaptador en `firebase_auth_service.gd` y sustituye los mocks desde el controlador de autenticación.
7. Prueba alta, inicio, cierre, renovación de sesión, modo offline y errores de red.

No se incluyen IDs, tokens ni credenciales inventadas. Tampoco se guardan contraseñas en `user://`.
