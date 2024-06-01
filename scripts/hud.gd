extends CanvasLayer

func _process(delta):
	$ProgressStamina.value = Global.act_stamina
