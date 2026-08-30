extends Node2D

@export var hora_correta: int = 8      # 0 a 23
@export var minuto_correto: int = 45   # 0 a 59
@export var interface_puzzle: NodePath  # arraste a InterfaceRelogioDigital aqui

var player_perto = false
var puzzle_resolvido = false

@onready var interface: Node = get_node(interface_puzzle)

func _ready():
	$Label.visible = false
	if not interface.resolvido.is_connected(_on_puzzle_resolvido):
		interface.resolvido.connect(_on_puzzle_resolvido)

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir") and not puzzle_resolvido:
		abrir_interface()

func abrir_interface():
	get_tree().paused = true
	interface.iniciar(hora_correta, minuto_correto)
	interface.visible = true

func _on_area_2d_body_entered(body):
	if body.name == "CharacterBody2D2":
		player_perto = true
		if not puzzle_resolvido:
			$Label.visible = true

func _on_area_2d_body_exited(body):
	if body.name == "CharacterBody2D2":
		player_perto = false
		$Label.visible = false

func _on_puzzle_resolvido():
	puzzle_resolvido = true
	$Label.visible = false
	# aqui: trocar sprite do relogio, tocar som, liberar porta, etc.
