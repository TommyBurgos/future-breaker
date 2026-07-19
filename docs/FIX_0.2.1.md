# Corrección 0.2.1

La escena Boot creaba `Logo` y `PortalCore` dinámicamente y posteriormente intentaba recuperarlos mediante `find_child()`. Ese método filtra por nodos con `owner` de forma predeterminada; los nodos creados en tiempo de ejecución no tenían propietario y el resultado era `null`.

Boot conserva ahora referencias tipadas a ambos controles desde el momento de su creación. Antes de iniciar los Tweens también valida las cuatro referencias dinámicas y utiliza una salida controlada al menú si la construcción visual no pudiera completarse.
