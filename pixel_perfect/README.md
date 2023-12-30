# Pixel perfect

By Felix Liu

This is a reusable "library" which consists of code I have written to enforce a pixel perfect grid style. Includes:

- Integer scaling from native resolution
- Pixelation
- Palette enforcement shader

### Setup

1. Instantiate pixel_perfect.tscn
2. Create a new SubViewport with any main game scenes or pixel UIs as children
3. Assign SubViewport to PixelPerfect
4. Adjust resolution, palette, offset, etc. on the PixelPerfect node
5. Add pixel_perfect.gd to autoload as PixelPerfect
