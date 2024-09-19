extends Area2D
class_name DropletSplash

var animated_sprite: AnimatedSprite2D

signal spawned(spawn_position: Vector2)

func _ready() -> void:
	animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
	
	hide()
	set_physics_process(true)

func _process(delta: float) -> void:
	await animated_sprite.animation_looped
	
	hide()
	set_physics_process(false)

func _on_spawned(spawn_position: Vector2) -> void:
	show()
	
	animated_sprite.play("idle")
	animated_sprite.set_frame(0)
	
	position = spawn_position
