extends CharacterBody2D

#Player VARIAVEIS (configuráveis por cena)
@export var speed := 200.0
@export var jump_velocity := -300.0
@export var can_jump := true
@export var dash_enabled := true
#Dano VARIAVEIS
var taking_damage = false
var damage_generation := 0
#BarraDeVida VARIAVEIS 
var maxHp = 100
var hp = 100
#Respawn VARIAVEIS
const FALL_LIMIT = 1000.0
var respawn_position: Vector2
#WallGrab VARIAVEIS
const wall_jump_pushback = 100
const WALL_JUMP_LOCK = 0.18
const wall_slide_gravity = 40
var is_wall_sliding = false
var wall_jump_lock := 0.0
var ultimo_wall_normal := Vector2.ZERO
var pulou_de_parede := false

#===============================================
#CONFIGURACOES E VARIAVEIS RELACIONADAS AO DASH
#================================================
const DASH_SPEED = 700.0
const DASH_TIME = 0.2
const DASH_VERTICAL_MULTIPLIER = 0.6
const DASH_COOLDOWN = 0.5
var is_dashing = false
var dash_timer = 1.0
var dash_direction = Vector2.ZERO
var can_dash = true
var dash_cooldown_timer = 0.0
#-------------------------------------------------------------#
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

#ESSA FUNCAO AQUI EH PRO PLAYER GERAL, CUIDADO COM O QUE COLOCA
func _physics_process(delta: float) -> void:
	aplicar_gravidade(delta)
	regenerarVida(delta)
	controlar_cooldown_dash(delta)
	if wall_jump_lock > 0:
		wall_jump_lock -= delta
	resetarDash()
	verificar_input_dash()
	controlar_movimento_dash(delta)
	verificar_queda()
	move_and_slide()
	if is_on_floor():
		pulou_de_parede = false
	if can_jump:
		wall_slide(delta)
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0
	
#=========================================================================
#FUNCOES DO DASH EM GERAL REESCRITAS E ORGANIZADAS !!!!!!!!!!!
#=========================================================================
#FUNCAO DE CONTROLE DE COOLDOWN DO DASH   
#=========================================================================             
func controlar_cooldown_dash(delta):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
#=========================================================================
#FUNCAO DE RESET DO DASH 
#=========================================================================                                 
func resetarDash():
	if is_on_floor() and dash_cooldown_timer <= 0:
		can_dash = true
	if is_on_wall() and dash_cooldown_timer <= 0:
		can_dash = true
#============================================================================
#FUNCAO PARA VERIFICAR INPUT DO DASH (SE FOI PRESSIONADO OU NAO BASICAMENTE) 
#============================================================================     
func verificar_input_dash():
	if dash_enabled and Input.is_action_just_pressed("Dash") and can_dash:
		iniciar_dash()
#===============================================================================================
#FUNCAO PARA CONTROLAR O MOVIMENTO ( OU EXECUTA O DASH, OU DEIXA O MOVIMENTO NORMAL DO PLAYER)
#===============================================================================================
func controlar_movimento_dash(delta):
	if is_dashing:
		executar_dash(delta)
	else:
		movimento_normal()	
#=============================
#FUNCAO DE EXECUTAR O DASH
#=============================
func executar_dash(delta):
	dash_timer -= delta
	var dash_velocity = dash_direction * DASH_SPEED
	dash_velocity.y *= DASH_VERTICAL_MULTIPLIER
	velocity = dash_velocity
	if dash_timer <= 0:
		is_dashing = false
#================================================================
#FUNCAO DE MOVIMENTO NORMAL DO PLAYER (COMO ANDAR E PULAR)
#================================================================
func movimento_normal():
	#=============================
	# CODIGO DE PULO DO PLAYER
	#=============================
	if can_jump and Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_velocity
		#WallGrab - o lock impede que o input horizontal sobrescreva o empurrão no mesmo frame.
		#Só permite wall jump numa parede com normal diferente da última usada
		#(corredor com duas paredes funciona; escalar a mesma parede, não).
		elif is_on_wall() and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
			var normal := get_wall_normal()
			if not (pulou_de_parede and normal.is_equal_approx(ultimo_wall_normal)):
				velocity.y = jump_velocity
				velocity.x = -wall_jump_pushback if Input.is_action_pressed("ui_right") else wall_jump_pushback
				wall_jump_lock = WALL_JUMP_LOCK
				ultimo_wall_normal = normal
				pulou_de_parede = true
	#===========================================
	# CODIGO DE MOVIMENTO HORIZONTAL DO PLAYER
	#============================================
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and wall_jump_lock <= 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
	atualizar_animacao(direction)

#===========================================
#FUNCAO QUE ESCOLHE A ANIMACAO PELO ESTADO DO PLAYER
#(evita o movimento_normal sobrescrever "jumping" a cada frame)
#===========================================
func atualizar_animacao(direction):
	if not is_on_floor():
		_set_anim("jumping")
	elif direction != 0:
		_set_anim("running")
	else:
		_set_anim("default")

func _set_anim(nome: StringName):
	if sprite_2d.sprite_frames.has_animation(nome):
		sprite_2d.animation = nome

#=============================
#FUNCAO WALL SLIDE(COMP DE WALLGRAB)
#=============================
func wall_slide(delta):
	if is_on_wall() and !is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false
	
	if is_wall_sliding:
		velocity.y += (wall_slide_gravity * delta)
		velocity.y = min(velocity.y, wall_slide_gravity)
#======================================
#FUNCAO DE GRAVIDADE DO JOGO 
#======================================
func aplicar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
#============================================================
#FUNCAO PARA PEGAR A DIRECAO EM QUE ESTA REALIZANDO O DASH
#============================================================
func pegar_direcao_dash():
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	
	if input_dir.x == 0 and input_dir.y != 0:
		input_dir.x = -1 if sprite_2d.flip_h else 1
	
	if input_dir == Vector2.ZERO:
		input_dir = Vector2(-1, 0) if sprite_2d.flip_h else Vector2(1, 0)
	return input_dir.normalized()
#================================================
#FUNCAO PARA INICIAR O DASH, E O COOLDOWN. 
#================================================
func iniciar_dash():
	is_dashing = true
	dash_timer = DASH_TIME
	can_dash = false
	dash_cooldown_timer = DASH_COOLDOWN
	dash_direction = pegar_direcao_dash()

#====================================================================================================
#FUNCOES DE REGENERACAO DAVIDA ; MORTE ; RESPAWN ; TOMAR DANO ; PARA DANO ; QUEDA ; SETAR SPAWN
#======================================================================================================
	
#========================================
#FUNCAO DE REGENERAR VIDA COM O TEMPO
#========================================
func regenerarVida(delta):
	if hp < maxHp:
		hp = min(hp + delta, maxHp)
#========================================
#FUNCAO DE MORTE
#========================================
func morrer():
		hp = maxHp
		respawn()
#========================================
#FUNCAO DE RESPAWN
#========================================
func respawn():
	global_position = respawn_position
	velocity = Vector2.ZERO
	is_dashing = false
	taking_damage = false
	damage_generation += 1
#===============================================================
#FUNCAO DE TOMAR DANO CASO ESTEJA EM ALGUM LUGAR QUE DE DANO 
#(a geração garante que só um laço de dano rode por vez: sair e
#entrar rápido na área não cria um segundo laço em paralelo)
#===============================================================
func take_damage(damage):
	damage_generation += 1
	var geracao = damage_generation
	taking_damage = true
	while taking_damage and geracao == damage_generation:
		hp -= damage
		if hp <= 0 :
			morrer()
			break
		await get_tree().create_timer(0.5).timeout
	
#===================================================================================================================
#FUNCAO DE PARAR DE TOMAR DANO (COMO USAMOS WHILE PRA TOMAR DANO , PRECISAMOS DESSA FUNCAO PARA QUEBRAR O WHILE)
#==================================================================================================================== 
func stop_damage():
	taking_damage = false
	damage_generation += 1
#=================================================
#FUNCAO DE VERIFICAR QUEDA DO MAPA
#=================================================
func verificar_queda():
	if global_position.y > FALL_LIMIT:
		morrer()
#================================================================================================================
#FUNCAO PARA DEIXAR A POSICAO INICIAL DO PLAYER SETADA(ESSA FUNCAO RODA QUANDO CARREGA O JOGO PELA PRIMEIRA VEZ)
#=================================================================================================================
func _ready():
	respawn_position = global_position
