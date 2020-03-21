extends Node2D

func _ready():
	$Viewport.own_world = true
	$Sprite.texture = $Viewport.get_texture()
