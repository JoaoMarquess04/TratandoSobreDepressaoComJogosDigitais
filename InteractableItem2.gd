extends Node2D

# ============================================
# SINAIS
# ============================================

signal puzzle_resolvido


# ============================================
# CONFIGURAÇÕES (EXPORT)
# ============================================

@export var interface_puzzle: NodePath   # arraste o nó PuzzleUI (CanvasLayer) aqui
@export var porta: NodePath              # opcional: arraste uma porta/StaticBody2D aqui, se houver


# ============================================
# VARIÁVEIS
# ============================================

var player_perto: bool = false
var ja_resolvido: bool = false


# ============================================
# REFERÊNCIAS
# ============================================

@onready var interface: Node = get_node(interface_puzzle)
@onready var porta_node: Node = get_node(porta) if porta != NodePath("") else null


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready() -> void:
	$Label.visible = false

	if not interface.puzzle_venceu.is_connected(_on_puzzle_venceu):
		interface.puzzle_venceu.connect(_on_puzzle_venceu)


# ============================================
# INPUT
# ============================================

func _process(_delta: float) -> void:
	if player_perto and Input.is_action_just_pressed("interagir") and not ja_resolvido:
		abrir_interface()


# ============================================
# ABRIR A INTERFACE DO PUZZLE
# ============================================

func abrir_interface() -> void:
	get_tree().paused = true
	$Label.visible = false
	interface.iniciar()


# ============================================
# DETECÇÃO DE PROXIMIDADE (Area2D filha)
# ============================================

func _on_area_2d_body_entered(body: Node) -> void:
	if body.name == "CharacterBody2D2":
		player_perto = true
		if not ja_resolvido:
			$Label.visible = true


func _on_area_2d_body_exited(body: Node) -> void:
	if body.name == "CharacterBody2D2":
		player_perto = false
		$Label.visible = false


# ============================================
# CALLBACK QUANDO O PUZZLE É RESOLVIDO
# ============================================

func _on_puzzle_venceu() -> void:
	ja_resolvido = true
	$Label.visible = false

	if porta_node != null and porta_node.has_method("abrir"):
		porta_node.abrir()

	puzzle_resolvido.emit()
	# aqui tambem da pra tocar som, iniciar dialogo, etc., igual fizemos com o relogio
