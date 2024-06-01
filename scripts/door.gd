extends StaticBody3D

@onready var animation = $"../../../AnimationDoor"

var toggle = false
var access = true 

func interact():
	if access == true:
		access = false
		toggle = !toggle
		if toggle:
			animation.play("open")
		else:
			animation.play("close")
		await get_tree().create_timer(1.0, false).timeout
		access = true
