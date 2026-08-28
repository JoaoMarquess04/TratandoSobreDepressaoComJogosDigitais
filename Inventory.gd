extends Node


# ============================================
# SINAIS
# ============================================

signal inventory_changed


# ============================================
# CONFIGURAÇÕES
# ============================================

const MAX_SLOTS: int = 20
const MAX_STACK: int = 99


# ============================================
# INVENTÁRIO
# ============================================

var items: Array = []


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready() -> void:
	initialize_inventory()


func initialize_inventory() -> void:
	items.resize(MAX_SLOTS)


# ============================================
# ADICIONAR ITEM
# ============================================

func add_item(
	item_name: String,
	icon: Texture2D = null,
	amount: int = 1,
	description: String = ""
) -> bool:

	if amount <= 0:
		return false

	if not can_add_item(item_name, amount):
		print("Inventário cheio!")
		return false

	var remaining_amount: int = amount

	# Primeiro tenta empilhar em slots existentes
	remaining_amount = add_to_existing_stacks(
		item_name,
		remaining_amount
	)

	# Depois procura slots vazios
	if remaining_amount > 0:
		add_to_empty_slots(
			item_name,
			icon,
			remaining_amount,
			description
		)

	inventory_changed.emit()

	return true


# ============================================
# EMPILHAR ITENS
# ============================================

func add_to_existing_stacks(
	item_name: String,
	amount: int
) -> int:

	var remaining_amount: int = amount

	for item in items:

		if remaining_amount <= 0:
			break

		if item == null:
			continue

		if item["name"] != item_name:
			continue

		var current_amount: int = int(item["amount"])

		if current_amount >= MAX_STACK:
			continue

		var available_space: int = MAX_STACK - current_amount

		var amount_to_add: int = min(
			available_space,
			remaining_amount
		)

		item["amount"] = current_amount + amount_to_add
		remaining_amount -= amount_to_add

	return remaining_amount


# ============================================
# ADICIONAR EM SLOTS VAZIOS
# ============================================

func add_to_empty_slots(
	item_name: String,
	icon: Texture2D,
	amount: int,
	description: String
) -> void:

	var remaining_amount: int = amount

	for i in range(items.size()):

		if remaining_amount <= 0:
			break

		if items[i] != null:
			continue

		var amount_to_add: int = min(
			MAX_STACK,
			remaining_amount
		)

		items[i] = create_item(
			item_name,
			icon,
			amount_to_add,
			description
		)

		remaining_amount -= amount_to_add


# ============================================
# CRIAR ITEM
# ============================================

func create_item(
	item_name: String,
	icon: Texture2D,
	amount: int,
	description: String
) -> Dictionary:

	var item: Dictionary = {
		"name": item_name,
		"icon": icon,
		"amount": amount,
		"description": description
	}

	return item


# ============================================
# VERIFICAR SE EXISTE ESPAÇO
# ============================================

func can_add_item(
	item_name: String,
	amount: int
) -> bool:

	var available_space: int = 0

	for item in items:

		# Slot vazio
		if item == null:
			available_space += MAX_STACK

		# Mesmo item, então pode empilhar
		elif item["name"] == item_name:
			var current_amount: int = int(item["amount"])

			available_space += (
				MAX_STACK - current_amount
			)

		if available_space >= amount:
			return true

	return false


# ============================================
# REMOVER ITEM
# ============================================

func remove_item(
	slot_index: int,
	amount: int = 1
) -> void:

	if not is_valid_slot(slot_index):
		return

	var item = items[slot_index]

	if item == null:
		return

	var current_amount: int = int(item["amount"])

	current_amount -= amount

	if current_amount <= 0:
		items[slot_index] = null
	else:
		item["amount"] = current_amount

	inventory_changed.emit()


# ============================================
# PEGAR ITEM DO SLOT
# ============================================

func get_item(slot_index: int):

	if not is_valid_slot(slot_index):
		return null

	return items[slot_index]


# ============================================
# VERIFICAR SE POSSUI ITEM
# ============================================

func has_item(item_name: String) -> bool:

	for item in items:

		if item == null:
			continue

		if item["name"] == item_name:
			return true

	return false


# ============================================
# PEGAR QUANTIDADE DE UM ITEM
# ============================================

func get_item_amount(item_name: String) -> int:

	var total: int = 0

	for item in items:

		if item == null:
			continue

		if item["name"] == item_name:
			total += int(item["amount"])

	return total


# ============================================
# VALIDAÇÃO DE SLOT
# ============================================

func is_valid_slot(slot_index: int) -> bool:

	return (
		slot_index >= 0
		and slot_index < items.size()
	)
