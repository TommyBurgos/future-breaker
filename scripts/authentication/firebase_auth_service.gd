class_name FirebaseAuthService
extends AuthService

# Adaptador intencionalmente vacío. Conecta aquí un plugin Firebase auditado.
func login(_email: String, _password: String) -> void:
	completed.emit(false, "Firebase todavía no está configurado", {})
