# Pixel perfect

By Felix Liu

This is a reusable "library" which consists of code I have written to enforce a pixel perfect grid style. Includes:

- Integer scaling from native resolution
- Pixelation
- Palette enforcement shader

### Setup

1. Instantiate `addons/pixel_perfect/pixel_perfect.tscn` into your high-level "game/UI" scene
2. Create a new SubViewport and set any main game scenes or pixel UIs as children
3. Assign the new SubViewport to the PixelPerfect node via the `Src Sub Viewport` property
4. Adjust resolution, palette, offset, etc. on the PixelPerfect node
5. Enjoy!

### Recommendations

- Remember to enable the addon!
- Create a separate 2D scene for everything pixelated/gameplay related. Since you can't really see the SubViewport in the editor, it helps to be able to see in a separate scene before running to see the pixelated version.

### Current Limitations

- `get_global_mouse_position()` does not return the correct mouse coordinates INSIDE of the SubViewport!

**Workaround:** If your mouse logic only updates when the position changes, wire your logic up to Godot's `_input(event: InputEvent)` handler. `event.position` and `event.global_position` will have correctly transformed values for within the viewport space.
If you really need to ask the inner world's mouse location in `_process`, call `PixelPerfect.get_mouse_world_pixel_position()` or `PixelPerfect.get_mouse_pixel_position()` from the `PixelPerfect` autoload (Or, you could always save the position from the input event).

- Functionality has only been tested in a 2D environment. Some features may not work or may work oddly in 3D. Use at your own risk. May be expanded in the future to include 3D. 

- Running individual scenes will bypass pixel perfect. The pixel perfect wrapper only applies to any scene with the PixelPerfect node and SubViewport.
