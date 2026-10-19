extends Node

#Musica de fundo da cena: avisa o MusicaManager ao carregar
@export var musica: AudioStream

func _ready():
	if musica:
		musica.loop = true
	MusicaManager.trocar(musica)
