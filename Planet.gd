extends Node2D

onready var generator = get_node("Viewport/PlanetGenerator3D")

func _ready():
	$Viewport.own_world = true
	$Sprite.texture = $Viewport.get_texture()
