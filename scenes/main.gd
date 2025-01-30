extends Node

var stumpscene = preload("res://scenes/stump.tscn")
var birdscene = preload("res://scenes/bird.tscn") 
var obstacles_type := [stumpscene]
var obstacles : Array
var bird_heights := [200, 390]


const START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var speed: float
const START_SPEED : float = 500
const MAX_SPEED : int = 1000
var screen_size : Vector2i
var ground_height : int

var score : int
var high_score : int
var game_running : bool

var last_obs 

var difficulty
const MAX_DIFFICULTY : int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$Gameover.get_node("Button").pressed.connect(new_game)
	new_game()
	

func new_game():
	score = 0
	get_tree().paused = false
	difficulty = 0
	show_score()
	$Player.position = START_POS
	$Player.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()	
	$AudioStreamPlayer.play()
	$HUD.get_node("StartLabel").show()
	$Gameover.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / 10000
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		generate_obs()
		
		$Player.position.x += speed * delta
		$Camera2D.position.x += speed * delta
		
		score += speed
		
		show_score()
		
		
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x  - screen_size.x):
				remove_obs(obs)
		
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true	
			$HUD.get_node("StartLabel").hide()
		
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(100, 500):
		var obstype = stumpscene
		var obs
		var max_obs = difficulty + 1 
		for i in range(randi() % max_obs + 1):
			obs = obstype.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)	
		if difficulty == MAX_DIFFICULTY:
			if randf() > 0.75:
				obs = birdscene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)
		
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)	
	add_child(obs)
	obstacles.append(obs)	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
func hit_obs(body):
	$Player/AnimatedSprite2D.play("death")
	if body.name == "Player":
		game_over()
	  	
func show_score():
	$HUD.get_node("ScoreLabel").text = 'SCORE: ' + str(score / 1000)
	$HUD.get_node('HighScoreLabel').text = 'HIGHSCORE: ' + str(high_score)
func check_highscore():
	if score / 1000 > high_score:
		high_score = score	/ 1000
	
func adjust_difficulty():
	difficulty = score / 10000
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY	
func game_over():
	check_highscore()
	get_tree().paused = true
	game_running = false
	$Gameover.show()
	
	
	
	
	
	
	
	
	
