class_name ColorConversion

const EQUAL_ENERGY_REF_XYZ = Vector3(100.0, 100.0, 100.0)
const EUROPEAN_NOON_REF_XYZ = Vector3(95.047, 100.00, 108.883)

## sRGB (Standard RGB) to XYZ
static func rgb_to_xyz(rgb: Color) -> Vector3:
	var r = rgb.r * 255.0
	var g = rgb.g * 255.0
	var b = rgb.b * 255.0
	
	if (r > 0.04045):
		r = pow((r + 0.055) / 1.055, 2.4)
	else:
		r = r / 12.92

	if g > 0.04045:
		g = pow((g + 0.055) / 1.055, 2.4)
	else:
		g = g / 12.92

	if b > 0.04045: 
		b = pow((b + 0.055) / 1.055, 2.4)
	else:
		b = b / 12.92
	
	r = r * 100.0
	g = g * 100.0
	b = b * 100.0
	
	var x = r * 0.4124 + g * 0.3576 + b * 0.1805
	var y = r * 0.2126 + g * 0.7152 + b * 0.0722
	var z = r * 0.0193 + g * 0.1192 + b * 0.9505
	
	var xyz = Vector3(x, y, z)
	return xyz

## XYZ to CIELAB
static func xyz_to_cielab(xyz: Vector3, xyz_ref: Vector3 = EUROPEAN_NOON_REF_XYZ) -> Vector3:
	var x = xyz.x / xyz_ref.x
	var y = xyz.y / xyz_ref.y
	var z = xyz.z / xyz_ref.z

	if x > 0.008856: 
		x = pow(x, 1.0 / 3.0)
	else:
		x = (7.787 * x) + (16.0 / 116.0)

	if y > 0.008856: 
		y = pow(y, 1.0 / 3.0)
	else:
		y = (7.787 * y) + (16.0 / 116.0)

	if z > 0.008856:
		z = pow(z, 1.0 / 3.0)
	else:
		z = (7.787 * z) + (16.0 / 116.0)

	var cie_l = (116.0 * y) - 16.0
	var cie_a = 500.0 * (x - y)
	var cie_b = 200.0 * (y - z)

	var cielab = Vector3(cie_l, cie_a, cie_b)
	return cielab

## sRGB to CIELAB via intermediate XYZ conversion
static func rgb_to_cielab(rgb: Color) -> Vector3:
	return xyz_to_cielab(rgb_to_xyz(rgb))
