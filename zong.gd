extends AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		pitch_scale = 0.75
