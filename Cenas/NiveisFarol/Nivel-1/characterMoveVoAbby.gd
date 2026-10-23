extends CharacterBody2D

#Player VARIAVEIS (configuráveis por cena)
@export var speed := 50.0
#Dano VARIAVEIS
var taking_damage = false
var damage_generation := 0
#BarraDeVida VARIAVEIS 
var maxHp = 100
var hp = 100
#Respawn VARIAVEIS
const FALL_LIMIT = 1000.0
var respawn_position: Vector2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

#ESSA FUNCAO AQUI EH PRO PLAYER GERAL, CUIDADO COM O QUE COLOCA
func _physics_process(delta: float) -> void:
	aplicar_gravidade(delta)
	regenerarVida(delta)
	movimento_normal()
	verificar_queda()
	move_and_slide()
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

#================================================================
#FUNCAO DE MOVIMENTO NORMAL DO PLAYER (COMO ANDAR)
#================================================================
func movimento_normal():
	#===========================================
	# CODIGO DE MOVIMENTO HORIZONTAL DO PLAYER
	#============================================
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 20)
	atualizar_animacao(direction)

#===========================================
#FUNCAO QUE ESCOLHE A ANIMACAO PELO ESTADO DO PLAYER
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

#======================================
#FUNCAO DE GRAVIDADE DO JOGO 
#======================================
func aplicar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

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
