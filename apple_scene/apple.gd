extends Area2D

func score_for_more(body):
	if body.name == "hobbit":
		label_for_SB() 
		self.queue_free()
		
		var main = get_node("/root/Main")
		main.eat_before_aragorn_takes_it_away(0)
		
func label_for_SB():
	var text = get_node("/root/Main/PlusScoreLabel") #this needs to be the plus_score_label thingy
	text.get_node("Label").text = "+10 pts!"
	text.set_position(self.position)   #shows instead of apple
	text.show()
	text.papope()
