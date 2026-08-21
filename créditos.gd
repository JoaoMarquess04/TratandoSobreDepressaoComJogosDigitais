extends Node2D

#===============================================
#FUNÇÃO DO BOTÃO DE VOLTAR AO MENU
#================================================
func _on_voltar_ao_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
