/*
 * AppController.j
 * affinetransform
 *
 * Created by You on March 18, 2011.
 * Copyright 2011, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "highlight_t_e.j"
@import "view_with_calayer.j"

var highlightElement = nil;
var affineExampleView = nil;

@implementation AppController : CPObject
{
  CPView contentView;
  CPTextField rotateValue;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
  contentView = [theWindow contentView];

  highlightElement = [[HighlightTE alloc] init];

  var rect = CGRectInset([contentView bounds], 200, 200 );
  affineExampleView = [[ViewWithCalayer alloc] initWithFrame:rect
                                              highlightElement:highlightElement];
  [affineExampleView setFrameOrigin:CGPointMake( 100,100 )];
  [affineExampleView redisplay];
  [affineExampleView setNeedsDisplay:YES];
  [affineExampleView setRotationDegrees:[highlightElement rotation]];
  [contentView addSubview:affineExampleView];
  
  rotateValue = [CPTextField labelWithTitle:"0"];
  [rotateValue setFrameOrigin:CGPointMake(200, 50)];
  [contentView addSubview:rotateValue];

  [self addButton:"Rotate" 
         position:CGPointMake( 20, 20 ) 
         selector:@selector(rotateAction:)];

  [self addButton:"Change Color" 
         position:CGPointMake( 20, 50 ) 
         selector:@selector(changeColor:)];

  [self addButton:"Rotate - Zero" 
         position:CGPointMake( 150, 20 ) 
         selector:@selector(rotateToZero:)];
  [theWindow orderFront:self];
}

- (void)addButton:(CPString)aTitle 
         position:(Point)aPoint 
         selector:(SEL)actionToTake
{
  var button = [CPButton buttonWithTitle:aTitle];
  [button setTarget:self];
  [button setAction:actionToTake];
  [button setFrameOrigin:aPoint];
  [contentView addSubview:button];
  return button;
}

-(void)rotateToZero:(id)sender
{
  [highlightElement setRotation:0];
  [affineExampleView updateRotation];
  [affineExampleView redisplay];
  [rotateValue setStringValue:[CPString stringWithFormat:"Rotate: %d degs",
                                        [highlightElement rotation]]];
  [rotateValue sizeToFit];
}

-(void)rotateAction:(id)sender
{
  [highlightElement setRotation:[highlightElement rotation] + 1];
  [rotateValue setStringValue:[CPString stringWithFormat:"Rotate: %d degs",
                                        [highlightElement rotation]]];
  [rotateValue sizeToFit];
  [affineExampleView updateRotation];
  [affineExampleView redisplay];
}

-(void)changeColor:(id)sender
{
  if ( [highlightElement color] === [CPColor redColor] ) {
    [highlightElement setColor:[CPColor blueColor]];
  } else {
    [highlightElement setColor:[CPColor redColor]];
  }
  [affineExampleView redisplay];
}

@end
