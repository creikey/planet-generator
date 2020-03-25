extends Spatial

var time := 0.0
var default_noise_settings: Array = [3, 64.0, 0.5, 2.0]
onready var settings: Dictionary = {
	"custom_planet_image": ["image", $PlanetViewport],
	"custom_clouds_image": ["image", $CloudsViewport],
	
	"planet_noise_seed": ["int", 0],
	"planet_noise_settings": ["noise_settings", default_noise_settings.duplicate()],
	"clouds_noise_seed": ["int", 0],
	"clouds_noise_settings": ["noise_settings", default_noise_settings.duplicate()],
	
	"grass": ["color", Color(0, 1, 0)],
	"shore": ["color", Color("7cd67c")],
	"ocean": ["color", Color(0.0, 0.0, 1.0)],
	"clouds": ["color", Color(1.0, 1.0, 1.0)],
	
	"grass_threshold": ["float", 0.562],
	"shore_threshold": ["float", 0.513],
	"clouds_threshold": ["float", 0.565],

	"has_clouds": ["bool", false],

	"grass_scale": ["vec2", Vector2(1, 1)],
	"clouds_scale": ["vec2", Vector2(1, 1)],
	
	"planet_rotate_speed": ["vec2", Vector2(1, 1)],
	"clouds_rotate_speed": ["vec2", Vector2(1, 1)],
}

var planet_rotate_speed: Vector3 = Vector3(1, 1, 0)
var clouds_rotate_speed: Vector3 = Vector3(1, 1, 0)

onready var planet_quad = $PlanetViewport/CanvasLayer/ColorRect
onready var clouds_quad = $CloudsViewport/CanvasLayer/ColorRect

func _ready():
	# make material unique
	var planet_material: ShaderMaterial = planet_quad.material.duplicate(true)
	planet_quad.material = planet_material
	var cloud_material: ShaderMaterial = clouds_quad.material.duplicate(true)
	clouds_quad.material = cloud_material
	
	apply_settings()

func _get_setting(setting_name: String):
	return settings[setting_name][1]

func create_image_texture_from_data_dict(data_dict: Dictionary) -> ImageTexture:
	var to_return: ImageTexture = ImageTexture.new()
	var img: Image = Image.new()
	img.data = data_dict
	to_return.create_from_image(img)
	to_return.flags = 2 # get rid of filter and mipmaps
	return to_return
	

func apply_settings():
	if _get_setting("custom_planet_image") is Dictionary:
		$PlanetMesh.material_override.albedo_texture = create_image_texture_from_data_dict(_get_setting("custom_planet_image"))
	else:
		if not _get_setting("custom_planet_image") is Viewport:
			settings["custom_planet_image"][1] = $PlanetViewport
		$PlanetMesh.material_override.albedo_texture = $PlanetViewport.get_texture()
	
	if _get_setting("custom_clouds_image") is Dictionary:
		$CloudsMesh.material_override.albedo_texture = create_image_texture_from_data_dict(_get_setting("custom_clouds_image"))
	else:
		if not _get_setting("custom_clouds_image") is Viewport:
			settings["custom_clouds_image"][1] = $CloudsViewport
		$CloudsMesh.material_override.albedo_texture = $CloudsViewport.get_texture()
	
	var planet_material: ShaderMaterial = planet_quad.material
	var cloud_material: ShaderMaterial = clouds_quad.material

	var grass_texture: NoiseTexture = planet_material.get_shader_param("grass")
	grass_texture.noise.seed = _get_setting("planet_noise_seed")
	_apply_noise_settings(grass_texture, _get_setting("planet_noise_settings"))

	var cloud_texture: NoiseTexture = cloud_material.get_shader_param("clouds")
	cloud_texture.noise.seed = _get_setting("clouds_noise_seed")
	_apply_noise_settings(cloud_texture, _get_setting("clouds_noise_settings"))

	planet_material.set_shader_param("grass_color", _get_setting("grass"))
	planet_material.set_shader_param("shore_color", _get_setting("shore"))
	planet_material.set_shader_param("ocean_color", _get_setting("ocean"))
	cloud_material.set_shader_param("clouds_color", _get_setting("clouds"))

	planet_material.set_shader_param("grass_threshold", _get_setting("grass_threshold"))
	planet_material.set_shader_param("shore_threshold", _get_setting("shore_threshold"))
	cloud_material.set_shader_param("clouds_threshold", _get_setting("clouds_threshold"))

	$CloudsMesh.visible = _get_setting("has_clouds")

	planet_material.set_shader_param("uv_scale", _get_setting("grass_scale"))
	cloud_material.set_shader_param("uv_scale", _get_setting("clouds_scale"))

	planet_rotate_speed = _uv2d_to_3d(_get_setting("planet_rotate_speed"))
	clouds_rotate_speed = _uv2d_to_3d(_get_setting("clouds_rotate_speed"))

func _uv2d_to_3d(in_uv: Vector2) -> Vector3:
	return Vector3(in_uv.x, in_uv.y, 0.0);

func _apply_noise_settings(noise_texture: NoiseTexture, settings: Array):
	noise_texture.noise.octaves = settings[0]
	noise_texture.noise.period = settings[1]
	noise_texture.noise.persistence = settings[2]
	noise_texture.noise.lacunarity = settings[3]

func _process(delta):
	time += delta/20.0
	$PlanetMesh.material_override.uv1_offset = planet_rotate_speed*time
	$CloudsMesh.material_override.uv1_offset = clouds_rotate_speed*time
