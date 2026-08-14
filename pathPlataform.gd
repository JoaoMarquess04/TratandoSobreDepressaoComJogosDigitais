extends Path2D
@export var move_speed: float = 20.0
@export var pausa_nas_pontas: float = 0.0  # tempo parado em cada ponta, em segundos

@onready var path_follow: PathFollow2D = $PathFollow2D

var direcao: int = 1
var pausado: bool = false

func _ready() -> void:
	path_follow.loop = false  # impede o "teleporte" de volta pro inicio

func _process(delta: float) -> void:
	if pausado:
		return
	
	path_follow.progress += move_speed * direcao * delta
	
	# Chegou no final do path
	if path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0
		direcao = -1
		if pausa_nas_pontas > 0:
			await pausar()
	
	# Voltou pro inicio do path
	elif path_follow.progress_ratio <= 0.0:
		path_follow.progress_ratio = 0.0
		direcao = 1
		if pausa_nas_pontas > 0:
			await pausar()

func pausar() -> void:
	pausado = true
	await get_tree().create_timer(pausa_nas_pontas).timeout
	pausado = false
