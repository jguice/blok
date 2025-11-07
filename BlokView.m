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
        // 60 FPS for smooth animation
        [self setAnimationTimeInterval:1/60.0];

        // Enable layer backing for hardware-accelerated, tear-free rendering
        [self setWantsLayer:YES];
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

	// Initialize velocity (pixels per frame at 60 FPS)
	// Speed scales linearly: speed of 10 = 600 pixels/sec
	CGFloat pixelsPerSecond = blokSpeed * 60.0;
	dx = pixelsPerSecond / 60.0;
	dy = pixelsPerSecond / 60.0;

	// Random starting position
	NSRect bounds = [self bounds];
	NSRect blokRect = NSMakeRect(0, 0, blokSize, blokSize);
	NSPoint startPoint = SSRandomPointForSizeWithinRect(blokRect.size, bounds);
	x = startPoint.x;
	y = startPoint.y;

	[self setNeedsDisplay:YES];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];

	// Draw the rectangle at current position
	NSRect blokRect = NSMakeRect(x, y, blokSize, blokSize);
	[color set];
	[NSBezierPath fillRect:blokRect];
}

- (void)animateOneFrame
{
	// Update position
	x += dx;
	y += dy;

	// Check for collisions and bounce
	[self checkCollision];

	// Redraw entire view for tear-free animation
	// Layer-backing ensures this is hardware accelerated
	[self setNeedsDisplay:YES];
}

- (void)checkCollision
{
    NSRect viewRect = [self bounds];

	// Check vertical bounds
    if (y < viewRect.origin.y) {
		y = viewRect.origin.y;
		dy = -dy;
    } else if (y + blokSize > NSMaxY(viewRect)) {
		y = NSMaxY(viewRect) - blokSize;
		dy = -dy;
    }

	// Check horizontal bounds
	if (x < viewRect.origin.x) {
		x = viewRect.origin.x;
		dx = -dx;
    } else if (x + blokSize > NSMaxX(viewRect)) {
		x = NSMaxX(viewRect) - blokSize;
		dx = -dx;
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
	// Create window with proper sheet style
	NSRect contentRect = NSMakeRect(0, 0, 450, 200);
	configSheet = [[NSWindow alloc] initWithContentRect:contentRect
											   styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable)
												 backing:NSBackingStoreBuffered
												   defer:NO];
	[configSheet setTitle:@"Blok Options"];
	[configSheet setLevel:NSModalPanelWindowLevel];

	NSView *contentView = [configSheet contentView];
	CGFloat y = 140;

	// Size controls
	NSTextField *sizeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 22)];
	[sizeLabel setStringValue:@"Size:"];
	[sizeLabel setBezeled:NO];
	[sizeLabel setDrawsBackground:NO];
	[sizeLabel setEditable:NO];
	[sizeLabel setSelectable:NO];
	[contentView addSubview:sizeLabel];

	sizeSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(110, y, 220, 22)];
	[sizeSlider setMinValue:5];
	[sizeSlider setMaxValue:100];
	[sizeSlider setIntValue:blokSize];
	[sizeSlider setTarget:self];
	[sizeSlider setAction:@selector(sliderChanged:)];
	[contentView addSubview:sizeSlider];

	sizeTextfield = [[NSTextField alloc] initWithFrame:NSMakeRect(340, y, 80, 22)];
	[sizeTextfield setIntValue:blokSize];
	[sizeTextfield setEditable:NO];
	[contentView addSubview:sizeTextfield];

	y -= 40;

	// Speed controls
	NSTextField *speedLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 22)];
	[speedLabel setStringValue:@"Speed:"];
	[speedLabel setBezeled:NO];
	[speedLabel setDrawsBackground:NO];
	[speedLabel setEditable:NO];
	[speedLabel setSelectable:NO];
	[contentView addSubview:speedLabel];

	speedSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(110, y, 220, 22)];
	[speedSlider setMinValue:1];
	[speedSlider setMaxValue:10];
	[speedSlider setIntValue:blokSpeed];
	[speedSlider setTarget:self];
	[speedSlider setAction:@selector(sliderChanged:)];
	[contentView addSubview:speedSlider];

	speedTextfield = [[NSTextField alloc] initWithFrame:NSMakeRect(340, y, 80, 22)];
	[speedTextfield setIntValue:blokSpeed];
	[speedTextfield setEditable:NO];
	[contentView addSubview:speedTextfield];

	y -= 40;

	// Color controls
	NSTextField *colorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(20, y, 80, 22)];
	[colorLabel setStringValue:@"Color:"];
	[colorLabel setBezeled:NO];
	[colorLabel setDrawsBackground:NO];
	[colorLabel setEditable:NO];
	[colorLabel setSelectable:NO];
	[contentView addSubview:colorLabel];

	colorWell = [[NSColorWell alloc] initWithFrame:NSMakeRect(110, y - 5, 50, 32)];
	[colorWell setColor:color];
	[contentView addSubview:colorWell];

	// OK button
	NSButton *okButton = [[NSButton alloc] initWithFrame:NSMakeRect(340, 20, 90, 32)];
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
	// Load preferences
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:Blok];

	// Always reload preferences to get current values
	NSNumber *sizeNum = [defaults valueForKey:@"Size"];
	NSNumber *speedNum = [defaults valueForKey:@"Speed"];
	NSData *colorData = [defaults dataForKey:@"Color"];

	// Set defaults if not found
	if (sizeNum) {
		blokSize = [sizeNum intValue];
	} else {
		blokSize = 10;
	}

	if (speedNum) {
		blokSpeed = [speedNum intValue];
	} else {
		blokSpeed = 1;
	}

	// Try to unarchive color, fallback to white if it fails
	if (colorData) {
		color = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:nil];
	}
	if (!color) {
		color = [NSColor whiteColor];
	}

	// Always create a fresh window to avoid "already in progress" errors
	configSheet = nil;
	[self createConfigureSheet];

	[sizeSlider setIntValue:blokSize];
	[sizeTextfield setIntValue:blokSize];
	[speedSlider setIntValue:blokSpeed];
	[speedTextfield setIntValue:blokSpeed];
	[colorWell setColor:color];

	return configSheet;
}

@end
