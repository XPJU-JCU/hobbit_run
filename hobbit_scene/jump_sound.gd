extends AudioStreamPlayer2D
	
func _process(delta):
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		pitch_scale = 0.8


func pitch_shifting():
	pitch_scale = randf_range(1.0, 1.2)
	play() 
