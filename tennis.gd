extends Node

var score_l = 0
var score_r = 0
var last_slam_left = false
var last_slam_right = false
var last_slam_time = 0

var scene = preload("res://main_menu.tscn")

onready var score_label = get_node("hud").get_node("score")
onready var ball = get_node("ball")

func _ready():
	set_process_input(true)
	set_process(true)
	set_fixed_process(true)

func _fixed_process(delta):
	get_node("racket_r").ai_process_ball(ball.get_global_pos(), delta)
	get_node("racket_l").ai_process_ball(ball.get_global_pos(), delta)

func _input(event):
	if event.is_action_pressed("ui_cancel"): 
		get_tree().quit()

func _process(delta):
	if last_slam_left and (ball.get_pos().x > get_viewport().get_rect().size.x / 2 ):
		last_slam_left = false
	if last_slam_right and (ball.get_pos().x < get_viewport().get_rect().size.x / 2 ):
		last_slam_right = false

	# recovery from ball out of field
	if(ball.get_pos().x > get_viewport().get_rect().size.x ): on_score_r()
	if(ball.get_pos().x < 0): on_score_l()

func on_score_l():
	ball.set_pos(Vector2(120, 120))
	ball.set_linear_velocity(Vector2())
	score_l +=1
	on_score_common()

func on_score_r():
	ball.set_pos(Vector2(480, 120))
	ball.set_linear_velocity(Vector2())
	score_r +=1
	on_score_common()

func on_score_common():
	get_node("sounds").play("score")
	get_node("racket_r").randomize_ai_speeds()
	get_node("racket_l").randomize_ai_speeds()
	score_label.set_text(str(score_l) + " - " + str(score_r))
	_check_winner()

func _on_score_l_body_enter( body ):
	on_score_l()

func _on_score_r_body_enter( body ):
	on_score_r()

func _check_winner():
	if score_l > 10 or score_r > 10:
		if score_l > 10:
			score_label.set_text("Left Wins!")
		if score_r > 10:
			score_label.set_text("Right Wins!")
		score_label.set_align(HALIGN_CENTER | VALIGN_CENTER)
		get_node("hud/win_particle").set_emitting(true)
		get_node("hud/win_timer").start()
		get_tree().set_pause(true)

func _on_racket_l_slam():
	if(OS.get_ticks_msec() - last_slam_time > 200):
		if last_slam_left: on_score_r()
		last_slam_left = true
		last_slam_right = false
		last_slam_time = OS.get_ticks_msec()
		get_node("sounds").play("racket")

func _on_racket_r_slam():
	if(OS.get_ticks_msec() - last_slam_time > 200):
		if last_slam_right: on_score_l()
		last_slam_left = false
		last_slam_right = true
		last_slam_time = OS.get_ticks_msec()
		get_node("sounds").play("racket")

func one_player_game():
	score_l = -2
	score_r = -2
	get_node("hud/r_l").hide()
	get_node("hud/l_r").hide()
	get_node("hud/l_l").set_action("ui_left")
	get_node("hud/l_u").set_action("ui_up")
	get_node("racket_l").AI = true
	pass

func two_players_game():
	score_l = -2
	score_r = -2
	get_node("racket_l").AI = false
	pass

func _on_win_timer_timeout():
	var node = scene.instance()
	get_parent().add_child(node)
	queue_free()
	get_tree().set_pause(false)
