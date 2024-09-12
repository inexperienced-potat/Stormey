extends Node
class_name StateMachine

enum MovementStates {IDLE, MOVE, SHIFT}
enum ActionStates {WATER, ATTACK, INTERACT, NO_ACTION}

@export var movement_speed: float = 400
@export var watering_movement_speed_multiplier: float = 0.4
@export var shifting_movement_speed_multiplier: float = 1.6
@export var water_duration: float = 0.1
@export var interact_duration: float = 0.8
@export var attack_duration: float = 0.33

var current_state_duration: float = 0
var current_state_maximum: float = 0
var direction: Vector2 = Vector2(0, 0)
var movement_state: MovementStates = MovementStates.IDLE
var action_state: ActionStates = ActionStates.NO_ACTION

var player_body: CharacterBody2D
var animation_player: AnimationPlayer
var state_inputs: Array = [action_state, movement_state]

func _ready() -> void:
	await owner.ready
	player_body = owner as CharacterBody2D
	animation_player = owner.get_node("AnimationPlayer") as AnimationPlayer

func get_input() -> void:
	var new_movement_state: MovementStates = MovementStates.IDLE
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if direction != Vector2.ZERO:
		new_movement_state = MovementStates.MOVE
		if Input.is_action_pressed("shift"):
			new_movement_state = MovementStates.SHIFT
	
	var new_action_state: ActionStates = ActionStates.NO_ACTION
	
	if Input.is_action_pressed("water"):
		new_action_state = ActionStates.WATER
	if Input.is_action_pressed("attack"):
		new_action_state = ActionStates.ATTACK
		new_movement_state = MovementStates.IDLE
	if Input.is_action_pressed("interact"):
		new_action_state = ActionStates.INTERACT
		new_movement_state = MovementStates.IDLE

	state_inputs = [new_action_state, new_movement_state]

func decide_state() -> void:
	if action_state != ActionStates.NO_ACTION:
		return
	
	match state_inputs[0]:
		ActionStates.WATER:
			current_state_maximum = water_duration
		ActionStates.ATTACK:
			current_state_maximum = attack_duration
		ActionStates.INTERACT:
			current_state_maximum = interact_duration
			
	action_state = state_inputs[0]
	movement_state = state_inputs[1]
	
func process_state() -> void:
	if current_state_duration >= current_state_maximum:
		if state_inputs[0] != action_state:
			action_state = ActionStates.NO_ACTION
			current_state_maximum = 0
			
		current_state_duration = 0
		
	match action_state:
		ActionStates.ATTACK:
			attack()
		ActionStates.WATER:
			water()
		ActionStates.INTERACT:
			interact()
		ActionStates.NO_ACTION:
			no_action()
			
	if movement_state != MovementStates.IDLE:
		if action_state == ActionStates.WATER:
			move(movement_speed * watering_movement_speed_multiplier)
		else:
			if movement_state == MovementStates.SHIFT:
				move(movement_speed * shifting_movement_speed_multiplier)
			else:
				move()

func move(new_movement_speed: float = movement_speed):
	player_body.velocity = direction * new_movement_speed
	player_body.move_and_slide()
	
func attack() -> void:
	pass

func water() -> void:
	pass

func interact() -> void:
	pass

func no_action() -> void:
	pass

func _process(delta: float) -> void:
	get_input()
	
	match action_state:
		ActionStates.ATTACK:
			if animation_player.current_animation != "attack":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("attack")
			else:
				await animation_player.animation_finished
		ActionStates.WATER:
			if animation_player.current_animation != "water":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("water")
			else:
				await animation_player.animation_finished
		ActionStates.INTERACT:
			if animation_player.current_animation != "interact":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("interact")
			else:
				await animation_player.animation_finished
		ActionStates.NO_ACTION:
			if animation_player.current_animation != "idle":
				animation_player.play(&"RESET")
				animation_player.advance(0)
				animation_player.play("idle")
			else:
				await animation_player.animation_finished

func _physics_process(delta: float) -> void:
	current_state_duration += delta
	
	decide_state()
	process_state()
