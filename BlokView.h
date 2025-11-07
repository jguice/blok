//
//  BlokView.h
//  Blok
//
//  Created by jguice on 10/24/08.
//  Copyright (c) 2010. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>


@interface BlokView : ScreenSaverView
{
	NSWindow *configSheet;
	NSSlider *sizeSlider;
	NSSlider *speedSlider;
	NSTextField *sizeTextfield;
	NSTextField *speedTextfield;
	NSColorWell *colorWell;

	NSColor *color;

	CGFloat blokSize, blokSpeed;
	CGFloat x, y;  // Current position
	CGFloat dx, dy;  // Velocity
}
- (void)checkCollision;
- (IBAction)doneSheetAction:(id)sender;
- (void)sliderChanged:(id)sender;
- (NSWindow *)createConfigureSheet;
@end
