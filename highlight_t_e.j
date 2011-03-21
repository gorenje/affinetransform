@implementation HighlightTE : CPObject
{
  CPColor m_color           @accessors(property=color);
  int m_show_as_border      @accessors(property=showAsBorder);
  int m_border_width        @accessors(property=borderWidth);
  int m_rotation            @accessors(property=rotation);

  int m_corner_top_left     @accessors(property=cornerTopLeft);
  int m_corner_top_right    @accessors(property=cornerTopRight);
  int m_corner_bottom_left  @accessors(property=cornerBottomLeft);
  int m_corner_bottom_right @accessors(property=cornerBottomRight);
}

- (id)init
{
  self = [super init];
  if ( self ) {
    m_color = [CPColor redColor];
    m_show_as_border = 0;
    m_border_width = 30;
    m_rotation = 0;

    m_corner_bottom_right = 40;
    m_corner_top_right = 10;
    m_corner_top_left = 15;
    m_corner_bottom_left = 34;
  }
  return self;
}

- (CPColor)getColor
{
  return [self color];
}

@end
