extends Node
class_name StateMachine

enum MovementStates {IDLE, MOVE}
enum ActionStates {NO_ACTION, ATTACK, WATER, INTERACT}

@export var movement_speed: float = 500.0

var player_body: CharacterBody2D
var animation_player: AnimationPlayer

var direction: Vector2 = Vector2(0, 0)
var movement_state = MovementStates.IDLE
var action_state = ActionStates.NO_ACTION

func _ready() -> void:
	await owner.ready
	player_body = owner as CharacterBody2D
	animation_player = owner.get_node("AnimationPlayer") as AnimationPlayer

func _input(event: InputEvent) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	movement_state = MovementStates.IDLE if direction == Vector2.ZERO else MovementStates.MOVE
	
	if event.is_action_pressed("attack"):
		action_state = ActionStates.ATTACK
	elif event.is_action_pressed("water"):
		action_state = ActionStates.WATER
	elif event.is_action_pressed("interact"):
		action_state = ActionStates.INTERACT
		movement_state = MovementStates.IDLE
	else:
		action_state = ActionStates.NO_ACTION

func _process(delta: float) -> void:
	#animation transitions
	pass

func _physics_process(delta: float) -> void:
	if movement_state == MovementStates.MOVE:
		player_body.velocity = direction * movement_speed
		player_body.move_and_slide()
		
	if action_state == ActionStates.INTERACT:
		animation_player.play("interact")
