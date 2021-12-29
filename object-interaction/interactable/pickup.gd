extends Interactable

func get_interaction_text():
	return "Pick up"
	
func interact():
	queue_free()
