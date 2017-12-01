extends Node2D

var scene = preload("res://tennis.tscn")

func _ready():
	pass

func _on_quit_pressed():
	get_tree().quit()

func _on_1p_match_pressed():
	var node = scene.instance()
	node.one_player_game()
	get_parent().add_child(node)
	queue_free()

func _on_2p_match_pressed():
	var node = scene.instance()
	node.two_players_game()
	get_parent().add_child(node)
	queue_free()

func _on_tournament_pressed():
	get_node("todo").popup()

func _on_help_pressed():
	get_node("instructions").popup()

func _on_settings_pressed():
	get_node("todo").popup()
