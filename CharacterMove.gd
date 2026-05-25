extends CharacterBody2D

const  SPEED = 200.0
const JUMP_VELOCITY = -300.0

#BarraDeVida
var maxHp = 100
var hp = 100


#ConfigDash 
const DASH_SPEED = 700.0
const DASH_TIME = 0.2
const DASH_VERTICAL_MULTIPLIER = 0.6
const DASH_COOLDOWN = 1.0


#RespawnSystem
const FALL_LIMIT = 1000.0
 
var is_dashing = false
var dash_timer = 1.0
var dash_direction = Vector2.ZERO
var can_dash = true
var dash_cooldown_timer = 0.0

var respawn_position: Vector2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

func _ready():
	#salvar posição inicial
	respawn_position = global_position

func _physics_process(delta: float) -> void:
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	
	
	#BarraDeVida
	if Input.is_action_just_pressed(""):
		hp -= 10
	else:
			hp += 1 * delta
	
	if hp <= 0:
		respawn()
		hp = 100 
	
	#verificar queda
	if global_position.y > FALL_LIMIT:
		respawn()

	#dash reset
	if is_on_floor() and dash_cooldown_timer <= 0:
		can_dash = true

	#dash input
	if Input.is_action_just_pressed("Dash") and can_dash:
		start_dash()

	#DashSystem
	if is_dashing:
		dash_timer -= delta
		
		var dash_velocity = dash_direction * DASH_SPEED
		dash_velocity.y *= DASH_VERTICAL_MULTIPLIER
		
		velocity = dash_velocity
		
		if dash_timer <= 0:
			is_dashing = false
	
	else:
		#Normal Movement
		#Gravidade
		if not is_on_floor():
			velocity += get_gravity() * delta
			sprite_2d.animation = "jumping"

		#Jump
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		#HorMove
		var direction := Input.get_axis("ui_left", "ui_right")
		
		if direction:
			velocity.x = direction * SPEED
			sprite_2d.animation = "running"
		else:
			velocity.x = move_toward(velocity.x, 0, 20)
			sprite_2d.animation = "default"

	move_and_slide()

	sprite_2d.flip_h = velocity.x < 0

#DashFunc
func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME
	can_dash = false
	dash_cooldown_timer = DASH_COOLDOWN

	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)

	if input_dir == Vector2.ZERO:
		input_dir = Vector2(-1, 0) if sprite_2d.flip_h else Vector2(1, 0)

	dash_direction = input_dir.normalized()

#RespawnFunc
func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	is_dashing = false


func _on_radio_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
