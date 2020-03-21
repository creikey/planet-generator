extends Spatial

var time := 0.0
var default_noise_settings: Array = [3, 64.0, 0.5, 2.0]
var settings: Dictionary = {
	"planet_noise_seed": ["int", 0],
	"planet_noise_settings": ["noise_settings", default_noise_settings.duplicate()],
	"clouds_noise_seed": ["int", 0],
	"clouds_noise_settings": ["noise_settings", default_noise_settings.duplicate()],
	
	"grass": ["color", Color()],
	"shore": ["color", Color()],
	"ocean": ["color", Color()],
	"clouds": ["color", Color()],
	
	"grass_threshold": ["float", 0.562],
	"shore_threshold": ["float", 0.513],
	"clouds_threshold": ["float", 0.565],
	
	"grass_scale": ["vec2", Vector2()],
	"clouds_scale": ["vec2", Vector2()],
	
	"planet_rotate_speed": ["vec2", Vector2()],
	"clouds_rotate_speed": ["vec2", Vector2()],
}

var planet_rotate_speed: Vector2 = Vector2()
var clouds_rotate_speed: Vector2 = Vector2()

func _ready():
	# make material unique
	var planet_material: ShaderMaterial = $Planet.material_override.duplicate(true)
	$Planet.material_override = planet_material
	var cloud_material: ShaderMaterial = $Clouds.material_override.duplicate(true)
	$Clouds.material_override = cloud_material
	
	apply_settings()

func _get_setting(setting_name: String):
	return settings[setting_name][1]

func apply_settings():
	var planet_material: ShaderMaterial = $Planet.material_override
	var cloud_material: ShaderMaterial = $Clouds.material_override
	
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

	planet_material.set_shader_param("uv_scale", _get_setting("grass_scale"))
	cloud_material.set_shader_param("uv_scale", _get_setting("clouds_scale"))
	
	planet_rotate_speed = _get_setting("planet_rotate_speed")
	clouds_rotate_speed = _get_setting("clouds_rotate_speed")

func _apply_noise_settings(noise_texture: NoiseTexture, settings: Array):
	noise_texture.noise.octaves = settings[0]
	noise_texture.noise.period = settings[1]
	noise_texture.noise.persistence = settings[2]
	noise_texture.noise.lacunarity = settings[3]

func _process(delta):
	time += delta/20.0
	$Planet.material_override.set_shader_param("uv_offset", Vector2(time, 0.0))
	$Clouds.material_override.set_shader_param("uv_offset", Vector2(time/2.0, time/4.0))
