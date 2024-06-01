extends Node3D

@onready var player = $".."
@onready var visuals = $"../visuals"

#export value to inspector
@export var sensitivity = 1.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	#Rotation
	if event is InputEventMouseMotion:
		#Блокуємо поворот моделі коли персонаж не рухається
		visuals.rotate_y(deg_to_rad(event.relative.x * 0.1 * sensitivity))
		
		player.rotate_y(deg_to_rad(-event.relative.x * 0.1 * sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * 0.1 * sensitivity))
		
		rotation_degrees.x = clamp(rotation_degrees.x, -45, 60)
		
	#Zoom
	if event is InputEventMouseButton:
		if event.button_index == 4:
			if get_node("Zoom").spring_length > 0.5:
				get_node("Zoom").spring_length -= 0.1
		if event.button_index == 5:
			if get_node("Zoom").spring_length < 2:
				get_node("Zoom").spring_length += 0.1
