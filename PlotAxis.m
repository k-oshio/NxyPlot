//
//	PlotAxis.m
//

#import "PlotAxis.h"
#import "PlotState.h"
#import "PlotView.h"

@implementation PlotAxis

- (id)init
{
    self = [super init];
    if (self == nil) return nil;

    return self;
}

- (void)awakeFromNib
{
	NSNumberFormatter	*formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormat:@"0.##;0;-0.##"];

    [ticMarkLenText             setFormatter:formatter];
    [gridThicknessText          setFormatter:formatter];
    [minorGridThicknessText     setFormatter:formatter];
    [frameThicknessText         setFormatter:formatter];
}

//
- (void)setPlotState:(PlotState *)state
{
    plot = state;
}

// state -> UI
- (void)updatePanel
{
// flags
    [axisOnButton               setState:[plot axisOn]];
    [gridOnButton               setState:[plot gridOn]];
    [gridDottedButton           setState:[plot gridDotted]];
    [minorGridOnButton          setState:[plot minorGridOn]];
    [majorTicMarksOnButton      setState:[plot majorTicMarksOn]];
    [minorTicMarksOnButton      setState:[plot minorTicMarksOn]];
    [blackBackgroundButton      setState:[plot blackBackground]];
    [colorCurvesButton          setState:[plot colorPlot]];
    [self setColors];

    [frameThicknessText         setFloatValue:[plot frameThickness]];
    [frameThicknessSlider       setFloatValue:[plot frameThickness]];
    [gridThicknessText          setFloatValue:[plot gridThickness]];
    [gridThicknessSlider        setFloatValue:[plot gridThickness]];
    [minorGridThicknessText     setFloatValue:[plot minorGridThickness]];
    [minorGridThicknessSlider   setFloatValue:[plot minorGridThickness]];
    [ticMarkLenText             setFloatValue:[plot ticMarkLen]];
    [ticMarkLenSlider           setFloatValue:[plot ticMarkLen]];
}


- (BOOL)colorPlot
{
    return [plot colorPlot];
}

- (NSColor *)textColor
{
    return textColor;
}

- (NSColor *)backgroundColor
{
    return backgroundColor;
}

- (void)setColors
{
    if ([plot blackBackground]) {
        textColor = [NSColor whiteColor];
        backgroundColor = [NSColor blackColor];
    } else {
        textColor = [NSColor blackColor];
        backgroundColor = nil;
    }
}

- (float)ticMarkLen
{
	return [plot ticMarkLen];
}

- (float)gridThickness
{
	return [plot gridThickness];
}

- (float)minorGridThickness
{
	return [plot minorGridThickness];
}

- (float)frameThickness
{
	return [plot frameThickness];
}

- (BOOL)majorTicMarksOn
{
	return [plot majorTicMarksOn];
}

- (BOOL)minorTicMarksOn
{
	return [plot minorTicMarksOn];
}

- (BOOL)axisOn
{
    return [plot axisOn];
}

- (BOOL)gridOn
{
	return ([plot gridOn]);
}

- (BOOL)gridDotted
{
	return [plot gridDotted];
}

- (BOOL)minorGridOn
{
	return [plot minorGridOn];
}

- (IBAction)axisOnChanged:(id)sender
{
    [plot setAxisOn:[sender state]];
    [canvas display];
}

- (IBAction)gridOnChanged:(id)sender
{
    [plot setGridOn:[sender state]];
    [canvas display];
}

- (IBAction)gridDottedChanged:(id)sender
{
    [plot setGridDotted:[sender state]];
    [canvas display];
}

- (IBAction)minorGridOnChanged:(id)sender
{
    [plot setMinorGridOn:[sender state]];
    [canvas display];
}

- (IBAction)majorTicMarksOnChanged:(id)sender
{
    [plot setMajorTicMarksOn:[sender state]];
    [canvas display];
}

- (IBAction)minorTicMarksOnChanged:(id)sender
{
    [plot setMinorTicMarksOn:[sender state]];
    [canvas display];
}

- (IBAction)frameThicknessChanged:(id)sender
{
    float   thk = [sender floatValue];
	[frameThicknessText setFloatValue:thk];
    [plot setFrameThickness:thk];
    [canvas display];
}

- (IBAction)gridThicknessChanged:(id)sender
{
	float   thk = [sender floatValue];
    [gridThicknessText setFloatValue:thk];
    [plot setGridThickness:thk];
    [canvas display];
}

- (IBAction)minorGridThicknessChanged:(id)sender
{
	float   thk = [sender floatValue];
    [minorGridThicknessText setFloatValue:thk];
    [plot setMinorGridThickness:thk];
    [canvas display];
}

- (IBAction)ticMarkLenChanged:(id)sender
{
    float   len = [sender floatValue];
	[ticMarkLenText   setFloatValue:len];
    [plot setTicMarkLen:len];
    [canvas display];
}

- (IBAction)blackBackgroundChanged:(id)sender
{
// set states
    [plot setBlackBackground:([sender state] == NSOnState)];
// set actual colors according to button states
    [self setColors];
    [canvas display];
}

- (IBAction)colorPlotChanged:(id)sender
{
// set states
    [plot setColorPlot:([sender state] == NSOnState)];
// set actual colors according to button states
    [self setColors];
    [canvas display];
}

- (IBAction)resetColor:(id)sender
{
	int		i;
	int		n = [plot nCurves];
	
	for (i = 0; i < n; i++) {
		[[plot curveAtIndex:i] setColor:[curves colorAt:i]];
	}
    [canvas display];
}

@end
