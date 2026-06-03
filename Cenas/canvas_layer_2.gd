extends CanvasLayer

var orb_count = 0

@onready var label = $HBoxContainer/Orbs

func _ready():
	update_ui()

func add_orb():
	orb_count += 1
	update_ui()

func update_ui():
	label.text = "" + str(orb_count)
