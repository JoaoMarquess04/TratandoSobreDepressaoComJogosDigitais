extends Path2D
@export var move_speed: float = 20.0
@export var pausa_nas_pontas: float = 0.0
@export var botao_ativo: BotaoAtivo

@onready var path_follow: PathFollow2D = $PathFollow2D

var direcao: int = 1
var pausado: bool = false
var ativa: bool = false

func _ready() -> void:
	path_follow.loop = false
	if botao_ativo:
		botao_ativo.desafio_completo.connect(_on_desafio_completo)

func _on_desafio_completo() -> void:
	ativa = true

func _process(delta: float) -> void:
	if not ativa or pausado:
		return
	
	path_follow.progress += move_speed * direcao * delta
	
	if path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0
		direcao = -1
		if pausa_nas_pontas > 0:
			await pausar()
	elif path_follow.progress_ratio <= 0.0:
		path_follow.progress_ratio = 0.0
		direcao = 1
		if pausa_nas_pontas > 0:
			await pausar()

func pausar() -> void:
	pausado = true
	await get_tree().create_timer(pausa_nas_pontas).timeout
	pausado = false
