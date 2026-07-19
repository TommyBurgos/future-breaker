class_name GoogleMockAuthService
extends AuthService

func login(_email: String, _password: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	await tree.create_timer(0.3).timeout
	completed.emit(true, "Google Sign-In simulado; requiere plugin verificado", {"user_id":"google_mock", "email":"google.mock@futurebreaker.local"})
