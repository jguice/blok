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
	
	NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor] requiringSecureCoding:NO error:nil];
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
	color = (NSColor *)[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:nil];
	
	dx = blokSpeed;
	dy = blokSpeed;
	
	at = [NSAffineTransform transform];
	[at translateXBy:dx yBy:dy];
	
	NSRect blokRect = NSMakeRect(blokSize,blokSize,blokSize,blokSize);
	blokRect.origin = SSRandomPointForSizeWithinRect( blokRect.size, [self bounds] );
	
	blok = [NSBezierPath bezierPathWithRect:blokRect];
	[self setNeedsDisplay:YES];
}

- (void)stopAnimation
{
    [super stopAnimation];
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
	NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
	[defaults setValue:colorData forKey:@"Color"];

	[defaults synchronize];

	// Modern sheet dismissal
	if (configSheet.sheetParent) {
		[configSheet.sheetParent endSheet:configSheet];
	}
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow *)createConfigureSheet
{
	// Create window
	NSRect contentRect = NSMakeRect(0, 0, 400, 240);
	configSheet = [[NSWindow alloc] initWithContentRect:contentRect
											   styleMask:NSWindowStyleMaskTitled
												 backing:NSBackingStoreBuffered
												   defer:NO];
	[configSheet setTitle:@"Blok Options"];

	NSView *contentView = [configSheet contentView];
	CGFloat y = contentRect.size.height - 40;

	// Size controls
	NSTextField *sizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 20)];
	[sizeLabel setStringValue:@"Size:"];
	[sizeLabel setBezeled:NO];
	[sizeLabel setDrawsBackground:NO];
	[sizeLabel setEditable:NO];
	[sizeLabel setSelectable:NO];
	[contentView addSubview:sizeLabel];

	sizeSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(100, y, 200, 20)];
	[sizeSlider setMinValue:5];
	[sizeSlider setMaxValue:100];
	[sizeSlider setIntValue:blokSize];
	[sizeSlider setTarget:self];
	[sizeSlider setAction:@selector(sliderChanged:)];
	[contentView addSubview:sizeSlider];

	sizeTextfield = [[NSTextField alloc] initWithFrame:NSMakeRect(310, y, 60, 20)];
	[sizeTextfield setIntValue:blokSize];
	[sizeTextfield setEditable:NO];
	[contentView addSubview:sizeTextfield];

	y -= 40;

	// Speed controls
	NSTextField *speedLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 20)];
	[speedLabel setStringValue:@"Speed:"];
	[speedLabel setBezeled:NO];
	[speedLabel setDrawsBackground:NO];
	[speedLabel setEditable:NO];
	[speedLabel setSelectable:NO];
	[contentView addSubview:speedLabel];

	speedSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(100, y, 200, 20)];
	[speedSlider setMinValue:1];
	[speedSlider setMaxValue:10];
	[speedSlider setIntValue:blokSpeed];
	[speedSlider setTarget:self];
	[speedSlider setAction:@selector(sliderChanged:)];
	[contentView addSubview:speedSlider];

	speedTextfield = [[NSTextField alloc] initWithFrame:NSMakeRect(310, y, 60, 20)];
	[speedTextfield setIntValue:blokSpeed];
	[speedTextfield setEditable:NO];
	[contentView addSubview:speedTextfield];

	y -= 40;

	// Color controls
	NSTextField *colorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 20)];
	[colorLabel setStringValue:@"Color:"];
	[colorLabel setBezeled:NO];
	[colorLabel setDrawsBackground:NO];
	[colorLabel setEditable:NO];
	[colorLabel setSelectable:NO];
	[contentView addSubview:colorLabel];

	colorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(100, y - 5, 60, 30)];
	[colorWell setColor:color];
	[contentView addSubview:colorWell];

	// OK button
	NSButton *okButton = [[NSButton alloc] initWithFrame:NSMakeRect(300, 20, 80, 32)];
	[okButton setTitle:@"OK"];
	[okButton setBezelStyle:NSBezelStyleRounded];
	[okButton setTarget:self];
	[okButton setAction:@selector(doneSheetAction:)];
	[okButton setKeyEquivalent:@"\r"];
	[contentView addSubview:okButton];

	return configSheet;
}

- (void)sliderChanged:(id)sender
{
	if (sender == sizeSlider) {
		[sizeTextfield setIntValue:[sizeSlider intValue]];
	} else if (sender == speedSlider) {
		[speedTextfield setIntValue:[speedSlider intValue]];
	}
}

- (NSWindow*)configureSheet
{
	// Load preferences if not already loaded
	if (!color) {
		ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:Blok];
		blokSize = [(NSNumber *)[defaults valueForKey:@"Size"] intValue];
		blokSpeed = [(NSNumber *)[defaults valueForKey:@"Speed"] intValue];
		NSData *colorData = (NSData *)[defaults dataForKey:@"Color"];
		color = (NSColor *)[NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:nil];

		// Fallback to white if color is still nil
		if (!color) {
			color = [NSColor whiteColor];
		}
	}

	if (!configSheet)
	{
		[self createConfigureSheet];
	}

	[sizeSlider setIntValue:blokSize];
	[sizeTextfield setIntValue:blokSize];
	[speedSlider setIntValue:blokSpeed];
	[speedTextfield setIntValue:blokSpeed];
	[colorWell setColor:color];

	return configSheet;
}

@end
