extends Area2D

@export var texts: Array[String]

@onready var label = $Label

var player_near := false
var can_interact := true

var dialog_scene = preload("res://Cenas/dialog_box.tscn")


func _ready():

	label.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):

	if body is CharacterBody2D:

		player_near = true
		label.visible = true


func _on_body_exited(body):

	if body is CharacterBody2D:

		player_near = false
		label.visible = false


func _process(delta):
	
	if player_near and can_interact and Input.is_action_just_pressed("interagir"):

		show_dialog()


func show_dialog():

	can_interact = false
	label.visible = false

	var dialog = dialog_scene.instantiate()
	get_tree().current_scene.add_child(dialog)

	dialog.global_position = global_position + Vector2(0, -100)

	dialog.start_dialog(texts)

	dialog.dialog_finished.connect(_on_dialog_finished)


func _on_dialog_finished():

	await get_tree().process_frame
	await get_tree().create_timer(0.02).timeout
	can_interact = true
