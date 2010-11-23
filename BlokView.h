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
	IBOutlet id configSheet;
	IBOutlet id sizeSlider;
	IBOutlet id speedSlider;
	IBOutlet id sizeTextfield;
	IBOutlet id speedTextfield;
	IBOutlet id colorWell;
	
    NSAffineTransform *at;
	NSBezierPath *oldBlok,*blok;
	NSColor *color;
	
	float blokSize,blokSpeed,dx,dy;
}
- (void)checkCollision;
- (IBAction) doneSheetAction: (id) sender;
@end
