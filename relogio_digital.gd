extends Node2D

@export var hora_correta: int = 0      # 0 a 23
@export var minuto_correto: int = 0   # 0 a 59
@export var interface_puzzle: NodePath  # arraste a InterfaceRelogioDigital aqui
@export var porta: NodePath
@export var texts: Array[String]  # <- novo: textos do dialogo apos resolver o puzzle

var player_perto = false
var puzzle_resolvido = false
var dialog_scene = preload("res://Cenas/dialog_box.tscn")  # <- novo

@onready var interface: Node = get_node(interface_puzzle)
@onready var porta_node: StaticBody2D = get_node(porta)

func _ready():
	$Label.visible = false
	if not interface.resolvido.is_connected(_on_puzzle_resolvido):
		interface.resolvido.connect(_on_puzzle_resolvido)

func _process(delta):
	if player_perto and Input.is_action_just_pressed("interagir") and not puzzle_resolvido:
		abrir_interface()
	if puzzle_resolvido:
		_on_show_dialog()

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
	
	print("Instanciando dialogo, textos: ", texts)
	
	print("Dialogo iniciado")
	
	print("Puzzle resolvido chamado!")
	puzzle_resolvido = true
	$Label.visible = false
	porta_node.abrir()

func _on_show_dialog():
	var dialog = dialog_scene.instantiate()
	add_child(dialog)
	dialog.global_position = global_position + Vector2(0, -100)
	dialog.start_dialog(texts)
