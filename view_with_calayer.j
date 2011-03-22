@implementation ViewWithCalayer : CPView
{
  CALayer     m_rootLayer;
  HighlightTE m_highlightElement;
}

- (id)initWithFrame:(CGRect)aFrame 
   highlightElement:(HighlightTE)aHighlightElement
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    m_rotationRadians  = 0.0;
    m_rootLayer        = [CALayer layer];
    m_highlightElement = aHighlightElement;
    [m_rootLayer setDelegate:self];
    [self setClipsToBounds:NO];
    [self setWantsLayer:YES];
    [self setLayer:m_rootLayer];
  }
  return self;
}

- (void)redisplay
{
  [m_rootLayer setNeedsDisplay];
}

- (void)updateRotation
{
  [self setRotationDegrees:[m_highlightElement rotation]];
}

- (void)setRotationDegrees:(int)aDegreeValue
{
  var radians = ( aDegreeValue * (Math.PI / 180) );
  if (m_rotationRadians === radians) return;
  m_rotationRadians = radians;
  CPLogConsole( "==> setRotationDegree Setting affine transform");
  [m_rootLayer setAffineTransform:CGAffineTransformMakeRotation(m_rotationRadians)];
  CPLogConsole( "AfTr: " + CPStringFromCGAffineTransform([m_rootLayer affineTransform]));
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
  CPLogConsole("[**[DrawLayer]**]");
  var bounds = [aLayer bounds];
  CGContextSetFillColor(aContext, [m_highlightElement getColor]);
  CGContextSetStrokeColor(aContext, [m_highlightElement getColor]);
  CPLogConsole( "About to fill ellipse" );
  CGContextFillEllipseInRect(aContext, bounds);
}

@end
