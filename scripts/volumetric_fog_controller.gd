extends Node3D

@export var fog_material: ShaderMaterial
@export var max_lights: int = 8
@export var _lights: Array[OmniLight3D] = []
@export var _maxFogDensity: float = 5.0
@export var _fogSpread: float = 0.0
@export var _fogVolume: FogVolume 

var _lightArray: Array[Vector3]
var _lightRadiuses: Array[float]
var _lightColors: Array[Vector3]

func _ready() -> void:
    if fog_material == null:
        return
    initialize()

func _process(delta: float) -> void:
    update_fog()

func add_omni_light(light: OmniLight3D) -> void:
    if _lights.size() < max_lights:
        _lights.append(light)
    else:
        push_warning("Cannot add more lights, maximum amount reached")

func remove_omni_light(light: OmniLight3D) -> void:
    if _lights.has(light):
        _lights.erase(light)

func initialize() -> void:
    _lightArray = []
    _lightRadiuses = []
    _lightColors = []

    for i in range(max_lights):
        _lightArray.append(Vector3.ZERO)
        _lightRadiuses.append(0.0)
        _lightColors.append(Vector3.ZERO)

    fog_material.set_shader_parameter("spread_progress", 0.0)

    update_fog_shader_lights()

func update_fog() -> void:
    if fog_material == null:
        return

    update_fog_shader_lights()
    fog_material.set_shader_parameter("spread_progress", _fogSpread)

func update_fog_shader_lights() -> void:
    for i in range(_lights.size()):
        var light = _lights[i]
        var color = light.light_color
        _lightArray[i] = light.global_position
        _lightRadiuses[i] = light.omni_range * 4.0
        _lightColors[i] = Vector3(color.r, color.g, color.b)

    fog_material.set_shader_parameter("light_positions", _lightArray)
    fog_material.set_shader_parameter("light_count", _lights.size())
    fog_material.set_shader_parameter("light_radiuses", _lightRadiuses)
    fog_material.set_shader_parameter("light_colors", _lightColors)
    fog_material.set_shader_parameter("fog_size", get_volume_longest_side())

func get_volume_longest_side() -> float:
    var size = _fogVolume.size
    if size.x > size.y:
        return size.x if size.x > size.z else size.z
    else:
        return size.y if size.y > size.z else size.z
