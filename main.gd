extends Node

#preload objects
var rock_scene = preload("res://rock/rock.tscn")
var stump_scene = preload("res://stump/stump.tscn")
var barrel_scene = preload("res://barrel/barrel.tscn")
var bird_scene = preload("res://crow_scene/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles : Array
var SB : Array
var rings : Array
var bird_heights := [200, 390]

var ring_scene = preload("res://ring_scene//ring.tscn")

var second_break : Array
var lembas_scene = preload("res://lembas_scene/lembas.tscn")
var apple_scene = preload("res://apple_scene/apple.tscn")
var which_one

#game variables
const HOBBIT_START_POS := Vector2i(150, 490)
const CAM_START_POS := Vector2i(0, 0)

var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 250
var high_score : int
var speed : float
const START_SPEED : float = 10  #used to be 10
@export var MAX_SPEED : int = 22  
const SPEED_MODIFIER : int = 13000  #(20000) is good - no its not
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs
var sauron_phase_active : bool    #collision off, sauron sprites

func _ready():
	screen_size = get_window().size
	ground_height = 110 #trust me on this one - $Ground.get_node("JungleTileset").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)   #annoying
	$RingSpawnTimer.timeout.connect(generate_one_ring)
	$SBTimer.timeout.connect(generate_second_breakfast)
	new_game()

func new_game():
	#reset variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#sauron phase bullshit reset
	$sauron_sees_you.visible = false
	sauron_phase_active = false
	$newBg.visible = true
	$hobbit.wears_ring = false
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#delete all apples and lembases and rings :3
	delete_items(SB)
	delete_items(rings)
	
	#reset the nodes
	$hobbit.position = HOBBIT_START_POS
	$hobbit.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#reset HUD and hide game Over
	$HUD.get_node("StartLabel").show()
	$PlusScoreLabel.hide()
	$GameOver.hide()
	
	$death_sound.stop()
	
#Called every frame. 'delta' is the elapsed time since the previous frame. 
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
	#moving the fricking obstacles
		generate_obs()

	#move hobbit and camera
		$hobbit.position.x += speed
		$Camera2D.position.x += speed
		
		#update score
		score += speed
		show_score() 
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x:
			$Ground.position.x += screen_size.x
			
		#remove obstacles that have gone off screen
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
		
		#remove items and rings as soon as they have gone offd screen
		remove_items_midgame(rings, $zing)
		remove_items_midgame(SB, $zong)

	else: 
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			reset_music()
			$RingSpawnTimer.start()
			$SBTimer.start()
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#generate only ground obstacles
	
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(200, 400):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + (i * 100) + randi_range(40, 80)
			var obs_y : int = screen_size.y - ground_height / 1.2
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
			
		#additionally random chance to spam a bird man!!!
		#if difficulty <= MAX_DIFFICULTY:
		if (randi() % 2) == 0:
			obs = bird_scene.instantiate()
			var obs_x : int = screen_size.x + score + 150 #dříve 100
			var obs_y : int = bird_heights[randi() % bird_heights.size()]
			add_obs(obs, obs_x, obs_y)

func generate_one_ring():
	var ring = ring_scene.instantiate()
	var ring_x = $Camera2D.position.x + screen_size.x + 100  
	var ring_y = randi_range(350, 500)
	ring.position = Vector2i(ring_x, ring_y)
	
	add_child(ring)
	rings.append(ring)
	
	ring.body_entered.connect(ring.ring_phase)

func generate_second_breakfast():
	var spawn_chance = randf()
	if spawn_chance < 0.8:
		which_one = apple_scene
	else:
		which_one = lembas_scene
	
	var SBA = which_one.instantiate()
	var SBA_x = $Camera2D.position.x + screen_size.x + 100  
	var SBA_y = randi_range(300, 600)
	SBA.position = Vector2i(SBA_x, SBA_y)
	
	add_child(SBA)
	SB.append(SBA)
	
	SBA.body_entered.connect(SBA.score_for_more)

func eat_before_aragorn_takes_it_away(is_lembas): 
	if is_lembas: 
		#lembas +30 score
		score += SCORE_MODIFIER * 20
		
	else:
		#apple +15 score
		score += SCORE_MODIFIER * 10

func sauron_phase():   
	sauron_phase_active = true       #important in game over
	$RingSpawnTimer.stop()                     #spawner of ring disabled  
	$sauron_sees_you.visible = true  #background
	$newBg.visible = false
	$hobbit.wears_ring = true
	
	await get_tree().create_timer(8).timeout  #the phase in ending
	for i in range(10):
		#sauron_sprites() změnit booleany, to bude funny no...
		$hobbit.wears_ring = !$hobbit.wears_ring
		$sauron_sees_you.visible = !$sauron_sees_you.visible
		$newBg.visible = !$newBg.visible
		await get_tree().create_timer(0.2).timeout  #right one is 0.1
	
	sauron_phase_active = false       #go back to normal
	$sauron_sees_you.visible = false 
	$newBg.visible = true
	$hobbit.wears_ring = false
	#timmy speed se změní podle difficulty
	#$RingSpawnTimer += 5????
	$RingSpawnTimer.start()

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func delete_items(array : Array):
	for item in array:
		item.queue_free()
	array.clear()

func remove_items_midgame(array : Array, sound : AudioStreamPlayer):  
	for item in array:
			if is_instance_valid(item) and item.position.x < ($Camera2D.position.x - screen_size.x):
				item.queue_free()
				array.erase(item)

			if !is_instance_valid(item): 
				sound.play()
				array.erase(item)

func hit_obs(body):
	if body.name == "hobbit" and !sauron_phase_active:
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

#deleting lembas, apples and rings at the start of the game
func delete_children(node):
	var children = node.get_children()
	for child in children:
		child.queue_free()
		print("Happened, lol")

func game_over():
	$main_soundtrack.stop()
	$RingSpawnTimer.stop()
	$SBTimer.stop()
	check_high_score()
	get_tree().paused = true
	$death_sound.play()
	game_running = false
	$GameOver.show()

func reset_music():
	#play some light jazz
	$main_soundtrack.play()
	$main_soundtrack.stream.loop = true
