extends Area2D


# ============================================
# DADOS DO ITEM
# ============================================

@export var item_name: String = "Antena"
@export var description: String = "Uma antena antiga. Pode ser útil em algum lugar."
@export var amount: int = 1
@export var icon: Texture2D


# ============================================
# VARIÁVEIS
# ============================================

var player_near: bool = false


# ============================================
# REFERÊNCIAS
# ============================================

@onready var pickup_prompt = $PickupPrompt


# ============================================
# INICIALIZAÇÃO
# ============================================

func _ready():
	pickup_prompt.visible = false

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# ============================================
# INPUT
# ============================================

func _process(_delta):
	if player_near and Input.is_action_just_pressed("interagir"):
		pick_item()


# ============================================
# DETECÇÃO DO PLAYER
# ============================================

func _on_body_entered(body):
	if body.name != "CharacterBody2D2":
		return

	player_near = true
	pickup_prompt.visible = true


func _on_body_exited(body):
	if body.name != "CharacterBody2D2":
		return

	player_near = false
	pickup_prompt.visible = false


# ============================================
# COLETA DO ITEM
# ============================================

func pick_item():
	var added = Inventory.add_item(
		item_name,
		icon,
		amount,
		description
	)

	if not added:
		print("Inventário cheio.")
		return

	print(item_name, " adicionada ao inventário.")

	queue_free()
