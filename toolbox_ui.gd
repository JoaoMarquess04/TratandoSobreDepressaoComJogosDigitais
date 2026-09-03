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
	
	# Conecta ao clique do mouse fora do painel (opcional)
	panel.gui_input.connect(_on_gui_input)


# ============================================
# EVENTOS DO MOUSE
# ============================================

func _on_gui_input(event: InputEvent):
	# Fecha a UI se clicar fora do painel
	if event is InputEventMouseButton and event.pressed:
		if not panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
			close_ui()


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
