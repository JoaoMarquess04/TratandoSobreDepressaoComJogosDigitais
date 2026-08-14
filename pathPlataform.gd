extends Path2D

@export var loop: bool = true
@export var move_speed: float = 20.0
@export var speed_ratio: float = 1.0

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if not loop:
		anim.play("move")#nome da animacao
		anim.speed_scale = speed_ratio

func _process(delta: float) -> void:
	path_follow.progress += move_speed * delta
