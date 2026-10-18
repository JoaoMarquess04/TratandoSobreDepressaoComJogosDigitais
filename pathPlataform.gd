extends Path2D
@export var move_speed: float = 20.0
@export var pausa_nas_pontas: float = 0.0
@export var botao_ativo: BotaoAtivo

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var corpo: AnimatableBody2D = $AnimatableBody2D

var direcao: int = 1
var pausado: bool = false
var ativa: bool = false

func _ready() -> void:
	path_follow.loop = false
	if botao_ativo:
		botao_ativo.desafio_completo.connect(_on_desafio_completo)

func _on_desafio_completo() -> void:
	ativa = true

func _physics_process(delta: float) -> void:
	if not ativa or pausado:
		return

	var novo_progress := path_follow.progress + move_speed * direcao * delta
	var alvo: Vector2 = global_transform * curve.sample_baked(
		clampf(novo_progress, 0.0, curve.get_baked_length()))
	var deslocamento: Vector2 = alvo - corpo.global_position

	#Descendo: se o próximo passo esmagaria o player (contato na cabeça dele,
	#normal pra cima), mata em vez de deixar o solver empurrá-lo pra dentro do chão
	if deslocamento.y > 0.0:
		var params := PhysicsTestMotionParameters2D.new()
		params.from = corpo.global_transform
		params.motion = deslocamento
		var resultado := PhysicsTestMotionResult2D.new()
		if PhysicsServer2D.body_test_motion(corpo.get_rid(), params, resultado):
			var colisor := instance_from_id(resultado.get_collider_id())
			if colisor is Node and colisor.is_in_group("player") and resultado.get_collision_normal().y < -0.5:
				if colisor.has_method("morrer"):
					colisor.morrer()
				return

	path_follow.progress = novo_progress

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
