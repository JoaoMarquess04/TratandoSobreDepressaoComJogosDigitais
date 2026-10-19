extends Node2D

func _ready() -> void:
	$Hud.get_node("Voltar ao menu").grab_focus()

#===============================================
#FUNÇÃO DO BOTÃO DE VOLTAR AO MENU
#================================================
func _on_voltar_ao_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
