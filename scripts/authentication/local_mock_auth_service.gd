class_name LocalMockAuthService
extends AuthService

func login(email: String, _password: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	await tree.create_timer(0.3).timeout
	completed.emit(true, "Autenticación local simulada", {"user_id":"mock_" + str(email.hash()), "email":email})
func register(email: String, password: String) -> void: login(email, password)
