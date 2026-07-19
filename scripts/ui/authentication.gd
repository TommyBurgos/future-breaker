extends Control
var email: LineEdit
var password: LineEdit
var confirm: LineEdit
var status: Label
func _ready() -> void:
	var box := UIFactory.screen(self, "ACCESO LOCAL")
	UIFactory.label(box, "Simulación de desarrollo: no ofrece autenticación real.", 22)
	email = LineEdit.new(); email.placeholder_text = "Correo electrónico"; email.custom_minimum_size.y = 72; box.add_child(email)
	password = LineEdit.new(); password.placeholder_text = "Contraseña (mínimo 8 caracteres)"; password.secret = true; password.custom_minimum_size.y = 72; box.add_child(password)
	confirm = LineEdit.new(); confirm.placeholder_text = "Confirmar contraseña (solo registro)"; confirm.secret = true; confirm.custom_minimum_size.y = 72; box.add_child(confirm)
	status = UIFactory.label(box, "", 22)
	UIFactory.button(box, "Iniciar sesión", func(): _submit(false))
	UIFactory.button(box, "Registrarse", func(): _submit(true))
	UIFactory.button(box, "Google Sign-In (simulado)", _google)
	UIFactory.button(box, "Regresar", func(): SceneManager.go("res://scenes/menus/main_menu.tscn"))
func _submit(register: bool) -> void:
	if not email.text.contains("@") or not email.text.contains("."): status.text = "Ingresa un correo válido."; return
	if password.text.length() < 8: status.text = "La contraseña debe tener al menos 8 caracteres."; return
	if register and password.text != confirm.text: status.text = "Las contraseñas no coinciden."; return
	status.text = "Procesando simulación..."
	await get_tree().create_timer(0.35).timeout
	SessionManager.login_mock(email.text.strip_edges().to_lower()); SceneManager.go("res://scenes/menus/main_menu.tscn")
func _google() -> void:
	status.text = "Google Sign-In simulado. Integra Firebase antes de publicar."
	SessionManager.login_mock("google.mock@futurebreaker.local")
