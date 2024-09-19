extends Area2D
class_name Flower

var water: Water
var animated_sprite: AnimatedSprite2D

signal watered

func _ready() -> void:
	water = $Water as Water
	animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
	
	animated_sprite.play("idle")
	animated_sprite.set_frame_and_progress(randi_range(0, 3), randf())

func _on_area_entered(area: Area2D) -> void:
	if area is not DropletSplash:
		return
	
	water.add_water(5)
	watered.emit()
