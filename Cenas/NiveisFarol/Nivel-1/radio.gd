extends Area2D

@export var texts: Array[String]
@onready var label = $Label

var player_near := false
var can_interact := true
var dialog_scene = preload("res://Cenas/dialog_box.tscn")

var dialog_open := false



#FUNCAO PARA RODAR NO INICIO QUANDO CARREGAR O JOGO
func _ready():

	label.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)



#FUNCAO QUE O PLAYER ENTRA NA AREA2D
func _on_body_entered(body):
	if body is CharacterBody2D:
		player_near = true
		label.visible = true

#FUNCAO EM QUE O PLAYER SAI DA AREA2D
func _on_body_exited(body):
	if body is CharacterBody2D:
		player_near = false
		label.visible = false

#FUNCAO EXECUTADA A CADA FRAME
func _process(delta):
	if player_near and can_interact:
		if Input.is_action_just_pressed("interagir"):
			if !dialog_open:
				show_dialog()

#FUNCAO DE INCIAR O DIALOGO 
func show_dialog():
	print("SHOW DIALOG")
	can_interact = false
	label.visible = false
	dialog_open = true
	
	var dialog = dialog_scene.instantiate()
	get_tree().current_scene.add_child(dialog)
	dialog.global_position = global_position + Vector2(0, -100)
	dialog.start_dialog(texts)
	dialog.dialog_finished.connect(_on_dialog_finished)
	#get_tree().paused = true

#FUNCAO DE FINALIZAR O DIALOGO
func _on_dialog_finished():
	await get_tree().process_frame
	await get_tree().create_timer(0.02).timeout
	can_interact = true
	dialog_open = false
	#get_tree().paused = false
