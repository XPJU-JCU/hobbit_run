extends Area2D

const normal = preload("res://barrel/3.png")
const sauron = preload("res://barrel/sauron_barrel_better.png")

func _process(delta):
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		$Sprite2D.texture = sauron
	else:
		$Sprite2D.texture = normal
