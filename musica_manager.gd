extends AudioStreamPlayer

#Trilha sonora global: toca continuo entre as cenas no bus "Musica"
func _ready():
	bus = "Musica"
	volume_db = -6.0

func trocar(stream_novo: AudioStream):
	if stream == stream_novo and playing:
		return
	stream = stream_novo
	play()
