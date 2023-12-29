class_name PixelPerfectNode extends CanvasLayer

# ----------------------------------------------------------------------------------
# PIXEL PERFECT NODE
# Coordinates texture and rendering, as well as the native resolution from inspector.
# ----------------------------------------------------------------------------------

# EXPORTS
@export_group("Required")
@export var native_pixel_res : Vector2i = Vector2i(512, 288) # Native size (editable from inspector)
@export var src_sub_viewport : SubViewport

@export_group("Palette")
@export var src_palette_texture : Texture2D # Image reference for the palette source
@export var accuracy_scale : int = 256 # Total value for one property (r,g,b)

# Onready values
@onready var pixel_texture : PixelPerfectRect = $PixelTexture # Texture to draw pixel to
@onready var pixel_palette : PixelPerfectPalette = $PixelPalette # Palette info script
@onready var bg = $Bg

@onready var scale_factor = 1 # Current runtime scale factor

# Other values
var pixel_offset : Vector2i = Vector2i.ZERO

# On ready, set texture rect information and call update to get accurate info
func _ready():
	# SETUP AT START
	bg.show()
	pixel_texture.show()
	
	setup_sub_viewport()
	setup_pixel_texture()
	setup_palette()

func setup_sub_viewport():
	src_sub_viewport.size = native_pixel_res # Set the viewport to the pixel size (native size)
	
	src_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS # ALWAYS UPDATE RENDER
	src_sub_viewport.handle_input_locally = false # USE GLOBAL INPUT
	src_sub_viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST # PIXEL NEAREST FILTER
	
	src_sub_viewport.audio_listener_enable_2d = true # ENABLE AUDIO
	src_sub_viewport.audio_listener_enable_3d = true

func setup_pixel_texture():
	# Set texture info to match viewport and info
	pixel_texture.native_size = native_pixel_res
	pixel_texture.scale_factor = scale_factor
	
	pixel_texture.texture = src_sub_viewport.get_texture() # Assign viewport texture to render from
	pixel_texture.resize() # Resize at the start to get accurate starting dimensions

func setup_palette():
	pixel_palette.accuracy_scale = accuracy_scale
	pixel_palette.palette_image = src_palette_texture
	
	pixel_palette.init()

func _process(_delta):
	pixel_texture.pixel_offset = pixel_offset

# On scale factor changed, make sure to update to a new one in case of references
func _on_pixel_texture_scale_factor_changed(new_factor):
	scale_factor = new_factor
