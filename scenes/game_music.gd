extends AudioStreamPlayer

class_name GameMusic

@export var tracks_by_level: Array[AudioStream]

func initialize():
    stream = tracks_by_level[GlobalVariables.next_level_index]
    play()
