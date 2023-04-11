# FloodAnim

Example project responding to https://stackoverflow.com/questions/75937551/how-to-fill-colour-with-animation-in-uiimage-particular-portion

Uses Scanline Flood Fill code from https://github.com/Chintan-Dave/UIImageScanlineFloodfill

This is ***EXAMPLE CODE ONLY*** and should not be considered even close to Production Ready.

The basic idea:

- give the "top" image view an empty mask (so it's completely transparent)
- get a flood-filled image based on the "bottom" image
- set that new image as the `.image` of the "top" image view
- run a "reveal" mask animation on the "top" image view - giving the visual effect of "filling in" the new color
- replace the `.image` of the "bottom" image view with the new image
- reset the empty mask on the "top" image view

Lather, rinse, repeat.

