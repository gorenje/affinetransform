var CALayerFrameOriginUpdateMask                = 1,
    CALayerFrameSizeUpdateMask                  = 2,
    CALayerZPositionUpdateMask                  = 4,
    CALayerDisplayUpdateMask                    = 8,
    CALayerCompositeUpdateMask                  = 16,
    CALayerDOMUpdateMask                        = CALayerZPositionUpdateMask | CALayerFrameOriginUpdateMask | CALayerFrameSizeUpdateMask;

var CALayerGeometryBoundsMask                   = 1,
    CALayerGeometryPositionMask                 = 2,
    CALayerGeometryAnchorPointMask              = 4,
    CALayerGeometryAffineTransformMask          = 8,
    CALayerGeometryParentSublayerTransformMask  = 16;

function _CALayerRecalculateGeometry(aLayer, aGeometryChange)
{
  CPLogConsole( "Override of recalculate" );
    var bounds = aLayer._bounds,
        superlayer = aLayer._superlayer,
        width = CGRectGetWidth(bounds),
        height = CGRectGetHeight(bounds),
        position = aLayer._position,
        anchorPoint = aLayer._anchorPoint,
        affineTransform = aLayer._affineTransform,
        backingStoreFrameSize = CGSizeMakeCopy(aLayer._backingStoreFrame),
        hasCustomBackingStoreFrame = aLayer._hasCustomBackingStoreFrame;

    CPLogConsole("Anchorpoint: " + anchorPoint.x + ", " + anchorPoint.y);
    // Go to anchor, transform, go back to bounds.
    aLayer._transformFromLayer =  CGAffineTransformConcat(
        CGAffineTransformMakeTranslation(-width * anchorPoint.x - CGRectGetMinX(aLayer._bounds), -height * anchorPoint.y - CGRectGetMinY(aLayer._bounds)),
        CGAffineTransformConcat(affineTransform,
        CGAffineTransformMakeTranslation(position.x, position.y)));

    if (superlayer && superlayer._hasSublayerTransform)
    {
        // aLayer._transformFromLayer = CGAffineTransformConcat(aLayer._transformFromLayer, superlayer._sublayerTransformForSublayers);
        CGAffineTransformConcatTo(aLayer._transformFromLayer, superlayer._sublayerTransformForSublayers, aLayer._transformFromLayer);
    }

    aLayer._transformToLayer = CGAffineTransformInvert(aLayer._transformFromLayer);

    //aLayer._transformFromLayer.tx = ROUND(aLayer._transformFromLayer.tx);
    //aLayer._transformFromLayer.ty = ROUND(aLayer._transformFromLayer.ty);

    aLayer._frame = nil;
    aLayer._standardBackingStoreFrame = [aLayer convertRect:bounds toLayer:nil];

    if (superlayer)
    {
        var bounds = [superlayer bounds],
            frame = [superlayer convertRect:bounds toLayer:nil];

      CPLogConsole( "Super Layer has bounds: " + rectToString(bounds));
      CPLogConsole( "Super Layer has frame: " + rectToString(frame));

        aLayer._standardBackingStoreFrame.origin.x -= CGRectGetMinX(frame);
        aLayer._standardBackingStoreFrame.origin.y -= CGRectGetMinY(frame);
    }
    
    // We used to use CGRectIntegral here, but what we actually want, is the largest integral
    // rect that would ever contain this box, since for any width/height, there are 2 (4)
    // possible integral rects for it depending on it's position.  It's OK that this is sometimes
    // bigger than the "optimal" bounding integral rect since that doesn't change drawing.

    var origin = aLayer._standardBackingStoreFrame.origin,
        size = aLayer._standardBackingStoreFrame.size;

    origin.x = FLOOR(origin.x);
    origin.y = FLOOR(origin.y);
    size.width = CEIL(size.width) + 1.0;
    size.height = CEIL(size.height) + 1.0;

    // FIXME: This avoids the central issue that a position change is sometimes a display and sometimes
    // a div move, and sometimes both.

    // Only use this frame if we don't currently have a custom backing store frame.
    if (!hasCustomBackingStoreFrame)
    {
        var backingStoreFrame = CGRectMakeCopy(aLayer._standardBackingStoreFrame);

        // These values get rounded in the DOM, so don't both updating them if they're
        // not going to be different after rounding.
        if (ROUND(CGRectGetMinX(backingStoreFrame)) != ROUND(CGRectGetMinX(aLayer._backingStoreFrame)) ||
            ROUND(CGRectGetMinY(backingStoreFrame)) != ROUND(CGRectGetMinY(aLayer._backingStoreFrame)))
            [aLayer registerRunLoopUpdateWithMask:CALayerFrameOriginUpdateMask];

        // Any change in size due to a geometry change is purely due to rounding error.
        if ((CGRectGetWidth(backingStoreFrame) != ROUND(CGRectGetWidth(aLayer._backingStoreFrame)) ||
            CGRectGetHeight(backingStoreFrame) != ROUND(CGRectGetHeight(aLayer._backingStoreFrame))))
            [aLayer registerRunLoopUpdateWithMask:CALayerFrameSizeUpdateMask];

        aLayer._backingStoreFrame = backingStoreFrame;
    }

    if (aGeometryChange & CALayerGeometryBoundsMask && aLayer._needsDisplayOnBoundsChange) {
      CPLogConsole( "SETNEEDS DISPLAY" );
        [aLayer setNeedsDisplay];
    }
    // We need to recompose if we have a custom backing store frame, OR
    // If the change is not solely composed of position and anchor points changes.
    // Anchor point and position changes simply move the object, requiring
    // no re-rendering.
    else if (hasCustomBackingStoreFrame || (aGeometryChange & ~(CALayerGeometryPositionMask | CALayerGeometryAnchorPointMask))) {
      CPLogConsole( "SETNEEDS COMPOSITE" );
        [aLayer setNeedsComposite];
    }

    var sublayers = aLayer._sublayers,
        index = 0,
        count = sublayers.length;

    CPLogConsole( "SUblayer count: " + count );
    for (; index < count; ++index) {
      CPLogConsole( "SUblayer count: " + index );
        _CALayerRecalculateGeometry(sublayers[index], aGeometryChange);
    }
}

function rectToString(rect) {
  return ("[Origin.x: " + rect.origin.x + " y: " + rect.origin.y + " width: " + 
          rect.size.width + " height: " + rect.size.height + "]");
}

@implementation CALayer (Override)

- (void)setAffineTransform:(CGAffineTransform)anAffineTransform
{
  CPLogConsole( "AffineTransform override" );
    if (CGAffineTransformEqualToTransform(_affineTransform, anAffineTransform))
        return;

    _affineTransform = CGAffineTransformMakeCopy(anAffineTransform);

    _CALayerRecalculateGeometry(self, 8);
}

- (void)drawInContext:(CGContext)aContext
{   //if (!window.loop || window.nodisplay) CPLog.error("htiasd");
  CPLogConsole( "drawInContext override" );
    if (_backgroundColor)
    {
      CPLogConsole( "[DRAW IN CONTEXT] Drawing background color");
      CGContextSetFillColor(aContext, _backgroundColor);
        CGContextFillRect(aContext, _bounds);
    }

    if (_delegateRespondsToDrawLayerInContextSelector)
        [_delegate drawLayer:self inContext:aContext];

    CPLogConsole( "[OWNING VIEW] Bounds: " + rectToString( [_owningView bounds] ) );
    CPLogConsole( "[SELF] Bounds: " + rectToString( [self bounds] ) );
}

@end
