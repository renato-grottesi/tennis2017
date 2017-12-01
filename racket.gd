extends KinematicBody2D

export var lefthanded = false
export var AI = false
signal slam

var pos = Vector2(0, 0)
var min_x = 0
var max_x = 0
var orig_y = 0
var ai_speed_x = 0
var ai_speed_y = 0

func _ready():
	set_fixed_process(true)

	pos = get_viewport_rect().size / 4
	pos.y*=3
	orig_y = pos.y
	pos.x = pos.x + (2*(!lefthanded)*pos.x)

	min_x = pos.x - get_viewport_rect().size.x / 4 + get_node("sprite").get_texture().get_width() / 2 + 1
	max_x = pos.x + get_viewport_rect().size.x / 4 - get_node("sprite").get_texture().get_width() / 2 - 1

	randomize_ai_speeds()

func randomize_ai_speeds():
	randomize()
	ai_speed_x = rand_range(300, 400)
	ai_speed_y = rand_range(100, 175)

func ai_process_ball(ball_pos, delta):
	if AI:
		var target = ball_pos
		var current = get_node("CollisionShape2D").get_global_pos()
	
		if(lefthanded):
			target.x -= 16
		else:
			target.x += 16
	
		var move = -sign(pos.x - target.x)

		if(ball_pos.distance_to(current) < 80):
			pos.x += delta * 150 * move
		elif(abs(pos.x - target.x)>10):
			pos.x += delta * ai_speed_x * move

		if ball_pos.distance_to(current) < 45:
			pos.y -= delta * ai_speed_y
		else:
			pos.y = orig_y

		move_to_pos()

func _fixed_process(delta):
	if !AI:
		var l_move = Input.is_action_pressed("lp_right") - Input.is_action_pressed("lp_left")
		var r_move = Input.is_action_pressed("ui_right") - Input.is_action_pressed("ui_left")

		if( (!lefthanded and Input.is_action_pressed("ui_up")) or (lefthanded and Input.is_action_pressed("lp_up"))):
			pos.y -= delta * 200
		else:
			pos.y = orig_y

		if(lefthanded):
			pos.x += delta * 150 * l_move
		else:
			pos.x += delta * 150 * r_move
		
		move_to_pos()

func move_to_pos():
		if(pos.x<min_x): pos.x = min_x
		if(pos.x>max_x): pos.x = max_x
		if(pos.y < orig_y - 16): pos.y = orig_y - 16

		# try to move
		move_to(pos)
		# detect collision and fire event
		if is_colliding():
			emit_signal("slam")
	
		# finish the movement
		set_pos(pos)
