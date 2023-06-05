extends CharacterBody2D

@export var speed = 250 
@export var gravity = 20
@export var jump_force = 300

@onready var ap = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var crouch_raycast_1 = $crouch_raycast_1
@onready var crouch_raycast_2 = $crouch_raycast_2

var is_crouching = false
var stuck_under_object = false

var standing_cshape = preload("res://resourses/player_standing_collision_shape.tres")
var crouching_cshape = preload("res://resourses/player_crouching_collusion_shape.tres")



func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > 1000:
			velocity.y = 1000 
	
	if Input.is_action_just_pressed("jump"): #&& is_on_floor():
		velocity.y = -jump_force
	
	var horizontal_direction= Input.get_axis("move_left","move_right")
	velocity.x = speed *  horizontal_direction
	
	if horizontal_direction !=0:
		switch_direction(horizontal_direction)
	
	
	if Input.is_action_just_pressed("crouch"):
		crouch()
	elif Input.is_action_just_released("crouch"):
		if !is_head_colliding():
			stand()
		else:
			if stuck_under_object != true:
				stuck_under_object=true

	if stuck_under_object && !is_head_colliding():
		if !Input.is_action_pressed("crouch"):
			stand()
			stuck_under_object=false
	
	move_and_slide()
	
	update_animations(horizontal_direction)

func is_head_colliding() -> bool:
	var result = crouch_raycast_1.is_colliding() && crouch_raycast_2.is_colliding()
	
	return result

func update_animations(horizontal_direction):
	if is_on_floor():
		if horizontal_direction == 0:
			if is_crouching	:
				ap.play("crouch")
			else:
				ap.play("idle")
		elif horizontal_direction !=0:
			if is_crouching:
				ap.play("crouch_walk")
			else:
				ap.play("run")
	else:
		if is_crouching ==false:			
			if velocity.y < 0:
				ap.play("jump")
			elif velocity.y >0:
				ap.play("fall")
		else:
			ap.play("crouch")

func switch_direction(horizontal_direction):
	sprite.flip_h = (horizontal_direction == -1)

func crouch():
	if is_crouching:
		return
	is_crouching=true
	cshape.shape = crouching_cshape
	cshape.position.y = -24

func stand():
	if is_crouching == false:
		return 
	is_crouching=false
	cshape.shape = standing_cshape
	cshape.position.y = -28

