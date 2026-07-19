extends Node

var session: Dictionary = {}

func _ready() -> void:
	session = SaveManager.data.get("session", {}).duplicate(true)

func play_as_guest() -> void:
	var guest_id := str(SaveManager.data.get("guest_id", ""))
	if guest_id.is_empty():
		guest_id = "guest_" + str(Time.get_unix_time_from_system()) + "_" + str(randi_range(1000, 9999))
		SaveManager.data.guest_id = guest_id
	session = {"user_id":guest_id,"display_name":"Invitado","email":"","is_guest":true,"is_authenticated":true,"created_at":Time.get_datetime_string_from_system(true)}
	_persist()

func login_mock(email: String) -> void:
	session = {"user_id":"local_" + str(email.hash()),"display_name":email.get_slice("@",0),"email":email,"is_guest":false,"is_authenticated":true,"created_at":Time.get_datetime_string_from_system(true)}
	_persist()

func logout() -> void:
	session = {}; _persist()

func is_active() -> bool: return bool(session.get("is_authenticated", false))
func _persist() -> void:
	SaveManager.data.session = session.duplicate(true)
	SaveManager.save_data()
	SignalBus.publish_session_changed()
