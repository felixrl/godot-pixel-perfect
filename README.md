# Pixel perfect

By Felix Liu

This is a reusable "library" which consists of code I have written to enforce a pixel perfect grid style. Includes:

- Integer scaling from native resolution
- Pixelation
- Palette enforcement shader

### Setup

1. Instantiate `pixel_perfect.tscn`
2. Create a new SubViewport, with any main game scenes or pixel UIs as children
3. Assign new SubViewport to the PixelPerfect node on the `Src Sub Viewport` property
4. Adjust resolution, palette, offset, etc. on the PixelPerfect node
5. Enjoy!

### Current Limitations

- `get_global_mouse_position()` does not return the correct mouse coordinates INSIDE of the SubViewport!

**Workaround:** If your mouse logic only updates when the position changes, wire your logic up to Godot's `_input(event: InputEvent)` handler. `event.position` and `event.global_position` will have correctly transformed values for within the viewport space.
If you really need to ask the inner world's mouse location in `_process`, call `PixelPerfect.get_world_mouse_position()` or related from the `PixelPerfect` autoload. (???)

- Functionality has only been tested in a 2D environment. Some features may not work or may work oddly in 3D. Use at your own risk. May be expanded in the future to include 3D. 
