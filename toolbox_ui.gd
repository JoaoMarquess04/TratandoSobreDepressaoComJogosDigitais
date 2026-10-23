extends CanvasLayer

# ============================================
# SINAIS
# ============================================

signal antenna_clicked
signal ui_closed


# ============================================
# REFERÊNCIAS
# ============================================

@onready var panel = $Panel
@onready var antenna_button = $Panel/AntennaButton
@onready var close_button = $Panel/CloseButton
@onready var toolbox_sprite = $Panel/ToolboxSprite
@onready var antenna_sprite = $Panel/AntennaSprite

# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready():
	# Conecta sinais dos botões
	antenna_button.pressed.connect(_on_antenna_clicked)
	close_button.pressed.connect(_on_close_clicked)
	antenna_button.grab_focus()


# ============================================
# EVENTOS DO MOUSE
# ============================================

# Cliques nos botões/painel são consumidos como gui_input;
# _unhandled_input só recebe cliques que caíram fora deles.
func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed:
		if not panel.get_global_rect().has_point(event.position):
			close_ui()

# teclado nao chega em _unhandled_input: Esc vem por aqui
func _unhandled_key_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()


# ============================================
# CLIQUES
# ============================================

func _on_antenna_clicked():
	print("ANTENNA CLICKED IN UI")
	antenna_clicked.emit()
	close_ui()


func _on_close_clicked():
	print("CLOSE CLICKED IN UI")
	close_ui()


# ============================================
# FECHAR UI
# ============================================

func close_ui():
	ui_closed.emit()
	queue_free()
