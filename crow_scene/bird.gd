extends Area2D

func _ready():
	$VisibleOnScreenNotifier2D.screen_entered.connect(kra)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x -= get_parent().speed / 3 #bývalo :2, ale to se nedalo :D :D
	
	#sauron phase
	var main_node = get_tree().get_root().get_node("Main")  
	if main_node.sauron_phase_active:
		$AnimatedSprite2D.play("sauron_flying")
	else:
		$AnimatedSprite2D.play("flying")
	
func kra():
	$kra.play()
