Affine Transform and CALayer
----------------------------

Example of an issue I'm having with setAffineTransform on CALayer, specifically rotation. 
What is happening is that the rectangle moves down and disappears when the color is changed
AND the rotation is greater than zero. I.e. change the color when the rotation is set to 
zero and everything works perfectly. Set the rotation to anything > 0 and then change 
the color, the rectangle moves down.

Description
-----------

What is happening is that when the color is changed (triggering a drawLayer: call),
the rectangle moves down the view *but* only if the rotation is greater than zero. 
Rotating the rectangle further, after it has moved down the page, will cause it to 
reappear at the correct position.

What seems to be the problem is that the view, not the CALayer is moving. But I have
no idea why! It also appears that how far the rectangle moves down is directly related
to how much it's rotated by. The greater the rotation, the further the rectangle will
move per color change.

Reproducing
-----------

First click on "Change Color". Color of the rectangle switches between red and blue. 
Rectangle stays put. Now "Rotate" the rectangle (doesn't matter how much). Now change
the color. The rectangle should (at least for me) move down and disappear (disappear on
multiple color changes). Rotate the rectangle again, and it will reappear. Change the 
color and if the rotation is greater than zero, it will start to travel down again.

Click on "Rotate - Zero" to set rotation to zero. Change the color and the rectangle
will not move.

Example
-------

The effect can be seen here: http://2monki.es/affinetransform/index.html

Version
-------

Demo uses Cappuccino master branch at 
version e8210f7dde6ff8835531f792f11523fdb554fbb0

But same effect seen with release version 0.9.

Browsers tested: 
 - Safari 5.0.3
 - Firefox 3.6.15

