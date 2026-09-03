extends Area2D


# ============================================
# CONFIGURAÇÕES DO RÁDIO
# ============================================

# Agora você coloca a frequência normalmente.
# Exemplo: 87.5
@export var correct_frequency: float = 87.5

# Limites do rádio
@export var min_frequency: float = 80.0
@export var max_frequency: float = 110.0

# Frequência inicial
@export var starting_frequency: float = 90.0

# Quanto muda a cada clique
@export var frequency_step: float = 0.1


# ============================================
# VARIÁVEIS
# ============================================

var current_frequency: float = 90.0

var player_near: bool = false
var radio_open: bool = false
var puzzle_solved: bool = false

var paused_by_radio: bool = false
var showing_error: bool = false


# ============================================
# REFERÊNCIAS
# ============================================

@onready var interaction_label = %InteractionLabel

@onready var radio_ui = %RadioUI
@onready var frequency_label = %FreqLabel

@onready var decrease_button = %DecreaseButton
@onready var increase_button = %IncreaseButton
@onready var confirm_button = %ConfirmButton

@onready var music_player = %MusicPlayer


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready() -> void:

	# Faz o rádio continuar funcionando
	# enquanto o resto do jogo está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

	current_frequency = starting_frequency

	interaction_label.visible = false
	radio_ui.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	decrease_button.pressed.connect(decrease_frequency)
	increase_button.pressed.connect(increase_frequency)
	confirm_button.pressed.connect(confirm_frequency)

	update_frequency_display()


# ============================================
# INPUT
# ============================================

func _process(_delta: float) -> void:

	# Depois de resolver, o rádio não aceita
	# mais nenhuma interação
	if puzzle_solved:
		return

	# F abre ou fecha o rádio
	if player_near and Input.is_action_just_pressed("interagir"):
		toggle_radio()

	if not radio_open:
		return

	# Também permite usar as setas
	if Input.is_action_just_pressed("ui_left"):
		decrease_frequency()

	if Input.is_action_just_pressed("ui_right"):
		increase_frequency()


# ============================================
# DETECÇÃO DO PLAYER
# ============================================

func _on_body_entered(body) -> void:

	if puzzle_solved:
		return

	if body.name != "CharacterBody2D2":
		return

	player_near = true

	if not radio_open:
		interaction_label.visible = true


func _on_body_exited(body) -> void:

	if body.name != "CharacterBody2D2":
		return

	player_near = false
	interaction_label.visible = false

	if radio_open:
		close_radio()


# ============================================
# ABRIR / FECHAR O RÁDIO
# ============================================

func toggle_radio() -> void:

	if puzzle_solved:
		return

	if radio_open:
		close_radio()
	else:
		open_radio()


func open_radio() -> void:

	if puzzle_solved:
		return

	if radio_open:
		return

	radio_open = true

	radio_ui.visible = true
	interaction_label.visible = false

	update_frequency_display()

	# Pausa o jogo
	if not get_tree().paused:
		get_tree().paused = true
		paused_by_radio = true


func close_radio() -> void:

	if not radio_open:
		return

	radio_open = false
	radio_ui.visible = false

	resume_game()

	if player_near and not puzzle_solved:
		interaction_label.visible = true


# ============================================
# AUMENTAR FREQUÊNCIA
# ============================================

func increase_frequency() -> void:

	if puzzle_solved or showing_error:
		return

	current_frequency += frequency_step

	if current_frequency > max_frequency:
		current_frequency = max_frequency

	fix_frequency_decimal()
	update_frequency_display()


# ============================================
# DIMINUIR FREQUÊNCIA
# ============================================

func decrease_frequency() -> void:

	if puzzle_solved or showing_error:
		return

	current_frequency -= frequency_step

	if current_frequency < min_frequency:
		current_frequency = min_frequency

	fix_frequency_decimal()
	update_frequency_display()


# ============================================
# CORRIGIR CASAS DECIMAIS
# ============================================

func fix_frequency_decimal() -> void:

	# Evita números estranhos como:
	# 87.499999999
	#
	# Mantém apenas uma casa decimal.
	current_frequency = round(
		current_frequency * 10.0
	) / 10.0


# ============================================
# MOSTRAR FREQUÊNCIA
# ============================================

func update_frequency_display() -> void:

	frequency_label.text = "%.1f MHz" % current_frequency


# ============================================
# CONFIRMAR FREQUÊNCIA
# ============================================

func confirm_frequency() -> void:

	if puzzle_solved:
		return

	if showing_error:
		return

	var difference: float = abs(
		current_frequency - correct_frequency
	)

	if difference < 0.01:
		solve_radio()
	else:
		wrong_frequency()


# ============================================
# FREQUÊNCIA ERRADA
# ============================================

func wrong_frequency() -> void:

	showing_error = true

	confirm_button.disabled = true
	decrease_button.disabled = true
	increase_button.disabled = true

	frequency_label.text = "SINAL NÃO ENCONTRADO"

	# Continua contando mesmo com o jogo pausado
	await get_tree().create_timer(
		1.0,
		true
	).timeout

	if puzzle_solved:
		return

	update_frequency_display()

	confirm_button.disabled = false
	decrease_button.disabled = false
	increase_button.disabled = false

	showing_error = false


# ============================================
# PUZZLE RESOLVIDO
# ============================================

func solve_radio() -> void:

	if puzzle_solved:
		return

	puzzle_solved = true

	print("Frequência correta!")
	print("Puzzle do rádio resolvido!")

	# Mostra rapidamente a frequência correta
	frequency_label.text = "%.1f MHz ✓" % current_frequency

	# Bloqueia os botões
	decrease_button.disabled = true
	increase_button.disabled = true
	confirm_button.disabled = true

	# Começa a música
	if not music_player.playing:
		music_player.play()

	# Espera um pouquinho para o jogador
	# perceber que acertou
	await get_tree().create_timer(
		0.7,
		true
	).timeout

	# Fecha a interface
	radio_open = false
	radio_ui.visible = false

	# O texto "F - Interagir" não aparece mais
	interaction_label.visible = false

	# Volta o jogo
	resume_game()

	# Desativa a detecção do rádio
	# porque o puzzle já terminou
	set_deferred("monitoring", false)


# ============================================
# VOLTAR O JOGO
# ============================================

func resume_game() -> void:

	if paused_by_radio:
		get_tree().paused = false
		paused_by_radio = false


# ============================================
# SEGURANÇA
# ============================================

func _exit_tree() -> void:

	# Evita o jogo ficar pausado caso
	# a cena seja fechada inesperadamente
	if paused_by_radio:
		get_tree().paused = false
		paused_by_radio = false
