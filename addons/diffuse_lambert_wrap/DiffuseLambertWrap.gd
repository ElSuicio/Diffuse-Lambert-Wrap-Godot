@tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDiffuseLambertWrap

# CC0 1.0 Universal, ElSuicio, 2025.
# GODOT v4.4.1.stable.
# x.com/ElSuicio
# github.com/ElSuicio
# Contact email [interdreamsoft@gmail.com]

func _get_name() -> String:
	return "LambertWrap"

func _get_category() -> String:
	return "Lightning/Diffuse"

func _get_description() -> String:
	return "Lambert-Wrap Diffuse Reflectance Model."

func _get_return_icon_type() -> PortType:
	return VisualShaderNode.PORT_TYPE_VECTOR_3D

func _is_available(mode : Shader.Mode, type : VisualShader.Type) -> bool:
	if( mode == Shader.MODE_SPATIAL and type == VisualShader.TYPE_LIGHT ):
		return true
	else:
		return false

#region Input
func _get_input_port_count() -> int:
	return 5

func _get_input_port_name(port : int) -> String:
	match port:
		0:
			return "Normal"
		1:
			return "Light"
		2:
			return "Light Color"
		3:
			return "Attenuation"
		4:
			return "Roughness"
	
	return ""

func _get_input_port_type(port : int) -> PortType:
	match port:
		0:
			return PORT_TYPE_VECTOR_3D # Normal.
		1:
			return PORT_TYPE_VECTOR_3D # Light.
		2:
			return PORT_TYPE_VECTOR_3D # Light Color.
		3:
			return PORT_TYPE_SCALAR # Attenuation.
		4:
			return PORT_TYPE_SCALAR # Roughness.
	
	return PORT_TYPE_SCALAR

#endregion

#region Output
func _get_output_port_count() -> int:
	return 1

func _get_output_port_name(_port : int) -> String:
	return "Diffuse"

func _get_output_port_type(_port : int) -> PortType:
	return PORT_TYPE_VECTOR_3D

#endregion

func _get_code(input_vars : Array[String], output_vars : Array[String], _mode : Shader.Mode, _type : VisualShader.Type) -> String:
	var default_vars : Array[String] = [
		"NORMAL",
		"LIGHT",
		"LIGHT_COLOR",
		"ATTENUATION",
		"ROUGHNESS"
		]
	
	for i in range(0, input_vars.size(), 1):
		if(!input_vars[i]):
			input_vars[i] = default_vars[i]
	
	var shader : String = """
	const float INV_PI = 0.318309;
	
	vec3 n = normalize( {normal} );
	vec3 l = normalize( {light} );
	
	float NdotL = dot(n, l); // [-1.0, 1.0].
	
	// https://web.archive.org/web/20210228210901/http://blog.stevemcauley.com/2011/12/03/energy-conserving-wrapped-diffuse/
	
	float diffuse_lambert_wrap = max(0.0, (NdotL + {roughness}) / ( (1.0 + {roughness}) * (1.0 + {roughness}) ) );
	
	{output} = {light_color} * {attenuation} * diffuse_lambert_wrap * INV_PI;
	"""
	
	return shader.format({
		"normal" : input_vars[0],
		"light" : input_vars[1],
		"light_color" : input_vars[2],
		"attenuation" : input_vars[3],
		"roughness" : input_vars[4],
		"output" : output_vars[0]
		})
