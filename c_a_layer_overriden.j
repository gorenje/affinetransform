@implementation CALayer (Override)

- (void)composite
{
    CGContextClearRect(_context, CGRectMake(0.0, 0.0, CGRectGetWidth(_backingStoreFrame), CGRectGetHeight(_backingStoreFrame)));

    // Recomposite
    var transform = CGAffineTransformCreateCopy(_transformFromLayer);

    if (_superlayer)
    {
        var superlayerTransform = _CALayerGetTransform(_superlayer, nil),
            superlayerOrigin = CGPointApplyAffineTransform(_superlayer._bounds.origin, superlayerTransform);

        transform = CGAffineTransformConcat(transform, superlayerTransform);

        transform.tx -= superlayerOrigin.x;
        transform.ty -= superlayerOrigin.y;
    }

    transform.tx -= CGRectGetMinX(_backingStoreFrame);
    transform.ty -= CGRectGetMinY(_backingStoreFrame);

    CGContextSaveGState(_context);
    CGContextConcatCTM(_context, transform);//_transformFromView);
    [self drawInContext:_context];
    CGContextRestoreGState(_context);
}

@end
