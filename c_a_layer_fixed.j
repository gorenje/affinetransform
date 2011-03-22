@implementation CALayerFixed : CALayer

- (void)composite
{
  var originalTransform = CGAffineTransformCreateCopy(_transformFromLayer);
  [super composite];
  _transformFromLayer = originalTransform;
}

@end
