extends CharacterBody3D

@onready var animation = $visuals/model/AnimationPlayer
@onready var ray = $visuals/RayCast3D

enum States {
	AIR = 1,
	FLOOR
}

const SPEED = 1.45
const MAX_SPEED = 3.6
const JUMP_VELOCITY = 6
const STAMINA_DRAIN = 0.2
const STAMINA_GAIN = 0.1
const SPEED_DECREASE = 0.1
const SPEED_INCREASE = 0.1

var state = States.AIR
var stamina = 100
var speed = SPEED
var is_boosting = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 1.8 #1.6

func _physics_process(delta):
	
	speed = clamp(speed, SPEED, MAX_SPEED)
	stamina = clamp(stamina, 0, 100)
	Global.act_stamina = stamina
	#print(stamina)
	#print(speed)
	#print(state)
	#print(is_boosting)
	#print(animation.current_animation)
	
	match state:
		States.AIR:
			if is_on_floor():
				state = States.FLOOR
				animation.play("land")
			
			# Add the gravity.
			velocity.y -= gravity * delta
			
			if is_boosting:
				stamina -= STAMINA_DRAIN
				if stamina > 1:
					speed = min(speed + SPEED_INCREASE, MAX_SPEED)
			else:
				stamina = min(stamina + STAMINA_GAIN, 100)
		
		States.FLOOR:
			if not is_on_floor():
				state = States.AIR
			
			# Handle jump.
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				animation.stop()
				animation.play("jump")
			
			door()
			run()
			
	movament()

func door():
	if ray.is_colliding():
		var hit = ray.get_collider()
		if hit.has_method("interact") && Input.is_action_just_pressed("interact"):
			hit.interact()


func movament():
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if is_on_floor():
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
		if direction:
			if is_boosting:
				if animation.current_animation != "run" and animation.current_animation != "jump":
					animation.play("run")
			else:
				if animation.current_animation != "walk" and animation.current_animation != "jump":
					animation.play("walk")
			
			#За допомогою мишки змінюємо напрямок персонажа
			$visuals.look_at(position + direction)
			
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			if animation.current_animation != "idle" and animation.current_animation != "jump" and animation.current_animation != "land":
				animation.play("idle")
				
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func run():
	var is_moving = Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")
	
	if Input.is_action_just_pressed("shift"):
		is_boosting = !is_boosting
	
	if is_boosting and is_moving:
		stamina -= STAMINA_DRAIN
		if stamina > 0:
			speed = min(speed + SPEED_INCREASE, MAX_SPEED)
		else:
			is_boosting = false
	else:
		if is_boosting:
			is_boosting = false
		stamina = min(stamina + STAMINA_GAIN, 100)
		speed = max(speed - SPEED_DECREASE, SPEED)
