extends HSlider

@export var audio_bus_name: String

#===============================================
#ARMAZENA O ID DO CANAL DE ÁUDIO
#================================================
var audio_bus_id

#===============================================
#FUNÇÃO PARA OBTER CANAL DE ÁUDIO
#================================================
func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

#===============================================
#FUNÇÃO ATIVADA AO ALTERAR O VALOR DO SLIDER 
#================================================
func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
