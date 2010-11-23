//
//  BlokView.m
//  Blok
//
//  Created by jguice on 10/24/08.
//  Copyright (c) 2008. All rights reserved.
//

#import "BlokView.h"

@implementation BlokView

static NSString * const Blok = @"net.jguice.Blok";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:Blok];
	
	// Set default prefs
	NSDictionary *defaultDict = [NSMutableDictionary dictionary];
	[defaultDict setValue:[NSNumber numberWithInt: 10] forKey:@"Size"];
	[defaultDict setValue:[NSNumber numberWithInt: 1] forKey:@"Speed"];		
	
	NSData *colorData = [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
	[defaultDict setValue:colorData forKey:@"Color"];
	
	// Register default prefs
	[defaults registerDefaults:defaultDict];
	
	[defaults synchronize];
	
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:Blok];
	
	// Read prefs (default or otherwise)
	blokSize = [(NSNumber *)[defaults valueForKey:@"Size"] intValue];
	blokSpeed = [(NSNumber *)[defaults valueForKey:@"Speed"] intValue];
	NSData *colorData = (NSData *)[defaults dataForKey:@"Color"];
	color = (NSColor *)[[NSUnarchiver unarchiveObjectWithData:colorData] retain];
	
	dx = blokSpeed;
	dy = blokSpeed;
	
	at = [[NSAffineTransform transform] retain];
	[at translateXBy:dx yBy:dy];
	
	NSRect blokRect = NSMakeRect(blokSize,blokSize,blokSize,blokSize);
	blokRect.origin = SSRandomPointForSizeWithinRect( blokRect.size, [self bounds] );
	
	blok = [[NSBezierPath bezierPathWithRect:blokRect] retain];
	[self setNeedsDisplay:YES];
}

- (void)stopAnimation
{
    [super stopAnimation];
	[at release];
	[blok release];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	if (NO) {
		NSString * debugString = 
		[@"ob: " stringByAppendingString:[NSString stringWithFormat:@"%x", &blok]];
		debugString = 
		[debugString stringByAppendingString:[NSString stringWithFormat:@", b: %x", blok]];
		debugString = 
		[debugString stringByAppendingString:[NSString stringWithFormat:@", at: %x", at]];
		NSMutableDictionary * attribs = [NSMutableDictionary dictionary];
		[attribs setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
		[debugString drawAtPoint:NSMakePoint(10,10) withAttributes:attribs];
	}
	[color set];
	[blok fill];
}

- (void)animateOneFrame
{	
	[self setNeedsDisplayInRect:[blok bounds]];
	[blok transformUsingAffineTransform:at];
	[self setNeedsDisplayInRect:[blok bounds]];
	[blok retain];
    [self checkCollision];
    return;
}

- (void)checkCollision
{
    NSRect blokRect = [blok bounds];
    NSRect viewRect = [self bounds];
	
    if (blokRect.origin.y < viewRect.origin.y || 
		(blokRect.origin.y + blokRect.size.height) > viewRect.size.height) {
		
		dy = -dy;
		[at translateXBy:0 yBy:2*dy];
    }
	
	if (blokRect.origin.x < viewRect.origin.x ||
		(blokRect.origin.x + blokRect.size.width) > viewRect.size.width) {
		
		dx = -dx;
		[at translateXBy:2*dx yBy:0];
    }
}

- (IBAction) doneSheetAction: (id) sender {
	ScreenSaverDefaults *defaults;
	
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:Blok];
	
	blokSize = [ sizeSlider intValue ];
	blokSpeed = [ speedSlider intValue ];
	color = [ colorWell color ];
	
	// Update defaults
	[defaults setValue:[NSNumber numberWithInt:blokSize] forKey:@"Size"];
	[defaults setValue:[NSNumber numberWithInt:blokSpeed] forKey:@"Speed"];
	NSData *colorData = [NSArchiver archivedDataWithRootObject:color];
	[defaults setValue:colorData forKey:@"Color"];
	
	[defaults synchronize];
	
	[NSApp endSheet: configSheet];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}
	}
	
	[sizeSlider setIntValue:blokSize];
	[sizeTextfield setIntValue:blokSize];
	[speedSlider setIntValue:blokSpeed];
	[speedTextfield setIntValue:blokSpeed];
	[colorWell setColor:color];
	
	return configSheet;
}

@end
