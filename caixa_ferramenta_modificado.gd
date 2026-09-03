extends Area2D
 
@export var texts: Array[String]
@onready var label = $Label
 
var player_near := false
var can_interact := true
var dialog_scene = preload("res://Cenas/dialog_box.tscn")
var dialog_open := false
var toolbox_ui_scene = preload("res://Cenas/toolbox_ui.tscn")  
var inventory: Node
var antenna_collected := false
 
 
# ============================================
# INICIALIZAÇÃO
# ============================================
 
func _ready():
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Inventory é um AutoLoad, acessível globalmente
	inventory = Inventory
 
 
# ============================================
# DETECTOR DE PROXIMIDADE
# ============================================
 
func _on_body_entered(body):
	if body is CharacterBody2D:
		player_near = true
		label.visible = true
 
 
func _on_body_exited(body):
	if body is CharacterBody2D:
		player_near = false
		label.visible = false
 
 
# ============================================
# INPUT
# ============================================
 
func _process(delta):
	if player_near and can_interact:
		if Input.is_action_just_pressed("interagir"):
			if !dialog_open:
				show_toolbox_ui()
 
 
# ============================================
# MOSTRAR UI DA CAIXA ABERTA
# ============================================
 
func show_toolbox_ui():
	print("SHOW TOOLBOX UI")
	can_interact = false
	label.visible = false
	
	var toolbox_ui = toolbox_ui_scene.instantiate()
	get_tree().current_scene.add_child(toolbox_ui)
	
	# Conecta o sinal de coleta da antena
	toolbox_ui.antenna_clicked.connect(_on_antenna_clicked)
	# Conecta o sinal de fechar UI
	toolbox_ui.ui_closed.connect(_on_toolbox_ui_closed)
 
 
# ============================================
# QUANDO ANTENA É CLICADA
# ============================================
 
func _on_antenna_clicked():
	print("ANTENNA CLICKED - STARTING DIALOG")
	dialog_open = true
	
	# Coleta a antena
	collect_antenna()
	
	# Inicia o diálogo
	var dialog = dialog_scene.instantiate()
	get_tree().current_scene.add_child(dialog)
	dialog.global_position = global_position + Vector2(0, -100)
	dialog.start_dialog(texts)
	dialog.dialog_finished.connect(_on_dialog_finished)
 
 
# ============================================
# COLETA DA ANTENA
# ============================================
 
func collect_antenna():
	if antenna_collected:
		return
	
	inventory.add_item(
		"Antena",
		load("res://sprites/CasaNivel1/antenna.png"),  # Ajuste o caminho
		1,
		"Uma antena antiga. Pode ser útil em algum lugar."
	)
	antenna_collected = true
	print("Antena coletada!")
 
 
# ============================================
# QUANDO UI É FECHADA
# ============================================
 
func _on_toolbox_ui_closed():
	can_interact = true
 
 
# ============================================
# FINALIZAR DIÁLOGO
# ============================================
 
func _on_dialog_finished():
	await get_tree().process_frame
	await get_tree().create_timer(0.02).timeout
	dialog_open = false
 
