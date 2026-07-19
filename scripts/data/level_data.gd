class_name LevelData
extends Resource

@export var level_number: int = 1
@export var title: String = "Nexo inicial"
@export var ball_speed: float = 760.0
@export var rows: Array[String] = []

func cell_type(row: int, column: int) -> int:
	if row < 0 or row >= rows.size() or column < 0 or column >= rows[row].length(): return 0
	return int(rows[row].substr(column, 1))
