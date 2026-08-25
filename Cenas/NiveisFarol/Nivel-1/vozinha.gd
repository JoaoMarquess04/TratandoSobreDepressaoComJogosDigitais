extends CharacterBody2D

#Player VARIAVEIS
const  SPEED = 100.0
const JUMP_VELOCITY = -300.0
#Dano VARIAVEIS
var taking_damage = false
#BarraDeVida VARIAVEIS 
var maxHp = 100
var hp = 100
#Respawn VARIAVEIS
const FALL_LIMIT = 1000.0
var respawn_position: Vector2

#===============================================
#CONFIGURACOES E VARIAVEIS RELACIONADAS AO DASH
#================================================
const DASH_SPEED = 700.0
const DASH_TIME = 0.2
const DASH_VERTICAL_MULTIPLIER = 0.6
const DASH_COOLDOWN = 1000.0
var is_dashing = false
var dash_timer = 1.0
var dash_direction = Vector2.ZERO
var can_dash = false
var dash_cooldown_timer = 100.0
#-------------------------------------------------------------#
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

#ESSA FUNCAO AQUI EH PRO PLAYER GERAL, CUIDADO COM O QUE COLOCA
func _physics_process(delta: float) -> void:
	can_dash = false 
	is_dashing = false
	aplicar_gravidade(delta)
	regenerarVida(delta)
	controlar_cooldown_dash(delta)
	resetarDash()
	verificar_input_dash()
	controlar_movimento_dash(delta)
	verificar_queda()
	move_and_slide()
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
	if Input.is_action_just_pressed("Dash") and can_dash:
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
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
	#===========================================
	# CODIGO DE MOVIMENTO HORIZONTAL DO PLAYER
	#============================================
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		sprite_2d.animation = "running"
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
		sprite_2d.animation = "default"
#======================================
#FUNCAO DE GRAVIDADE DO JOGO 
#======================================
func aplicar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite_2d.animation = "jumping"
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
#===============================================================
#FUNCAO DE TOMAR DANO CASO ESTEJA EM ALGUM LUGAR QUE DE DANO 
#===============================================================
func take_damage(damage):
	if taking_damage:
		return
	taking_damage = true
	while taking_damage:
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
