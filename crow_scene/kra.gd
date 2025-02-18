extends AudioStreamPlayer2D


func _process(delta: float) -> void:
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		pitch_scale = 0.85
