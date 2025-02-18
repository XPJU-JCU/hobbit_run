extends StaticBody2D


const normal = preload("res://ground/ground (2).png")
const sauron = preload("res://ground/sauron_ground.png")

func _process(delta):
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		$Grass.texture = sauron
		$Grass2.texture = sauron
	else:
		$Grass.texture = normal
		$Grass2.texture = normal
