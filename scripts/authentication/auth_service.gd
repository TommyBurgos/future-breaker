class_name AuthService
extends RefCounted

signal completed(success: bool, message: String, profile: Dictionary)
func login(_email: String, _password: String) -> void: completed.emit(false, "Servicio no implementado", {})
func register(_email: String, _password: String) -> void: completed.emit(false, "Servicio no implementado", {})
func logout() -> void: pass
