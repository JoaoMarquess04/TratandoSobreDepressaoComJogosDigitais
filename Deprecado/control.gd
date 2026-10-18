extends Control

var Orb := 0

@onready var orb_counter: Label = $OrbCounter as Label



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orb_counter.text = str("%01d" % Orb)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	orb_counter.text = str("%01d" % Orb)
