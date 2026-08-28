extends Control


# ============================================
# REFERÊNCIAS
# ============================================

@onready var inventory_panel = %InventoryPanel
@onready var grid = %GridContainer

@onready var tooltip_panel = %TooltipPanel
@onready var tooltip_icon = %TooltipIcon
@onready var tooltip_name = %TooltipName
@onready var tooltip_description = %TooltipDescription

@onready var pickup_toast = %PickupToast
@onready var toast_icon = %ToastIcon
@onready var toast_item_name = %ToastItemName

# ============================================
# CORES
# ============================================

const PANEL_BG := Color("#281E1B")
const PANEL_BORDER := Color("#A8753D")

const SLOT_BG := Color("#181719")
const SLOT_BORDER := Color("#604735")

const SLOT_HOVER_BG := Color("#29231F")
const SLOT_HOVER_BORDER := Color("#D6A14C")

const SLOT_PRESSED_BG := Color("#382E24")
const SLOT_PRESSED_BORDER := Color("#F2C467")

const TEXT_COLOR := Color("#F5E4BA")

const TOOLTIP_BG := Color("#211918")
const TOAST_BG := Color("#211918")


# ============================================
# CONFIGURAÇÕES
# ============================================

const SLOT_SIZE := Vector2(56, 56)
const TOAST_DURATION := 2.0
const TOOLTIP_OFFSET := Vector2(20, 20)


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready():
	add_to_group("inventory_ui")

	Inventory.inventory_changed.connect(update_inventory)

	setup_interface()
	create_slots()
	update_inventory()

	inventory_panel.visible = false
	tooltip_panel.visible = false
	pickup_toast.visible = false


# ============================================
# INPUT
# ============================================

func _input(event):
	if event.is_action_pressed("Inventory"):
		toggle_inventory()


func toggle_inventory():
	inventory_panel.visible = !inventory_panel.visible

	if not inventory_panel.visible:
		hide_tooltip()


# ============================================
# CONFIGURAÇÃO VISUAL
# ============================================

func setup_interface():
	setup_inventory_panel()
	setup_tooltip()
	setup_pickup_toast()


func setup_inventory_panel():
	var style = StyleBoxFlat.new()

	style.bg_color = Color("#241A18")
	style.border_color = Color("#A86F3D")

	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4

	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4

	style.shadow_color = Color(0, 0, 0, 0.65)
	style.shadow_size = 8
	style.shadow_offset = Vector2(4, 4)

	inventory_panel.add_theme_stylebox_override("panel", style)


func setup_tooltip():
	var style = create_panel_style(
		TOOLTIP_BG,
		PANEL_BORDER,
		3
	)

	tooltip_panel.add_theme_stylebox_override(
		"panel",
		style
	)

	tooltip_name.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)


func setup_pickup_toast():
	var style = create_panel_style(
		TOAST_BG,
		SLOT_HOVER_BORDER,
		3,
		5
	)

	pickup_toast.add_theme_stylebox_override(
		"panel",
		style
	)


func create_panel_style(
	background_color: Color,
	border_color: Color,
	border_width: int,
	shadow_size: int = 0
) -> StyleBoxFlat:

	var style = StyleBoxFlat.new()

	style.bg_color = background_color
	style.border_color = border_color

	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width

	if shadow_size > 0:
		style.shadow_color = Color(0, 0, 0, 0.5)
		style.shadow_size = shadow_size

	return style


# ============================================
# CRIAÇÃO DOS SLOTS
# ============================================

func create_slots():
	for i in range(Inventory.MAX_SLOTS):
		var slot = create_slot(i)
		grid.add_child(slot)


func create_slot(index: int) -> Button:
	var slot = Button.new()

	slot.custom_minimum_size = SLOT_SIZE
	slot.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Label separado para mostrar a quantidade
	var amount_label = Label.new()
	amount_label.name = "AmountLabel"

	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Prende no canto inferior direito
	amount_label.anchor_left = 1.0
	amount_label.anchor_top = 1.0
	amount_label.anchor_right = 1.0
	amount_label.anchor_bottom = 1.0

	amount_label.offset_left = -22
	amount_label.offset_top = -20
	amount_label.offset_right = -4
	amount_label.offset_bottom = -2

	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	# Visual do número
	amount_label.add_theme_font_size_override("font_size", 12)
	amount_label.add_theme_color_override("font_color", Color.WHITE)
	amount_label.add_theme_color_override("font_outline_color", Color.BLACK)
	amount_label.add_theme_constant_override("outline_size", 3)

	slot.add_child(amount_label)

	setup_slot_style(slot)
	setup_slot_signals(slot, index)

	return slot


func setup_slot_style(slot: Button):
	slot.add_theme_stylebox_override(
		"normal",
		create_slot_style(
			SLOT_BG,
			SLOT_BORDER
		)
	)

	slot.add_theme_stylebox_override(
		"hover",
		create_slot_style(
			SLOT_HOVER_BG,
			SLOT_HOVER_BORDER
		)
	)

	slot.add_theme_stylebox_override(
		"pressed",
		create_slot_style(
			SLOT_PRESSED_BG,
			SLOT_PRESSED_BORDER
		)
	)

	slot.add_theme_color_override(
		"font_color",
		TEXT_COLOR
	)

	slot.add_theme_color_override(
		"font_hover_color",
		Color.WHITE
	)


func setup_slot_signals(
	slot: Button,
	index: int
):
	slot.pressed.connect(
		slot_pressed.bind(index)
	)

	slot.mouse_entered.connect(
		show_tooltip.bind(index)
	)

	slot.mouse_exited.connect(
		hide_tooltip
	)


func create_slot_style(
	background_color: Color,
	border_color: Color
) -> StyleBoxFlat:

	var style = StyleBoxFlat.new()

	style.bg_color = background_color
	style.border_color = border_color

	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3

	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3

	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 5

	return style



# ============================================
# ATUALIZAÇÃO DO INVENTÁRIO
# ============================================

func update_inventory():
	for i in range(grid.get_child_count()):
		var slot_button: Button = grid.get_child(i)
		var item = Inventory.get_item(i)

		update_slot(slot_button, item)


func update_slot(
	slot_button: Button,
	item
):
	var amount_label: Label = slot_button.get_node("AmountLabel")

	if item == null:
		slot_button.icon = null
		slot_button.text = ""
		amount_label.text = ""
		return

	slot_button.icon = item["icon"]

	# Não usamos mais o texto do botão para quantidade
	slot_button.text = ""

	var amount: int = int(item["amount"])

	if amount > 1:
		amount_label.text = str(amount)
	else:
		amount_label.text = ""


# ============================================
# INTERAÇÃO COM O SLOT
# ============================================

func slot_pressed(index: int):
	var item = Inventory.get_item(index)

	if item == null:
		return

	print("Item: ", item["name"])
	print("Quantidade: ", item["amount"])


# ============================================
# TOOLTIP
# ============================================

func show_tooltip(index: int):
	var item = Inventory.get_item(index)

	if item == null:
		return

	tooltip_name.text = item["name"]

	tooltip_description.text = item.get(
		"description",
		""
	)

	tooltip_icon.texture = item["icon"]

	var mouse_position = get_viewport().get_mouse_position()

	tooltip_panel.position = (
		mouse_position
		+ TOOLTIP_OFFSET
	)

	tooltip_panel.visible = true


func hide_tooltip():
	tooltip_panel.visible = false


# ============================================
# AVISO DE ITEM COLETADO
# ============================================

func show_item_collected(
	item_name: String,
	item_icon: Texture2D,
	amount: int
):
	toast_icon.texture = item_icon

	toast_item_name.text = (
		item_name
		+ " x"
		+ str(amount)
	)

	pickup_toast.visible = true

	await get_tree().create_timer(
		TOAST_DURATION
	).timeout

	pickup_toast.visible = false
