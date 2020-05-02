//
//	PlotLegend.m
//

#import "PlotLegend.h"
#import "PlotState.h"

@implementation PlotLegend

- (id)init
{
    self = [super init];
    if (self == nil) return nil;

    return self;
}

- (void)setPlotState:(PlotState *)state
{
    plot = state;
}

- (void)updatePanel
{
    [legendOn               setState:[plot legendOn]];
    [legendBoxOn            setState:[plot legendBoxOn]];
    [legendOpaqueBackground setState:[plot legendOpaqueBackground]];
    [legendLineLenText      setFloatValue:[plot legendLineLen]];
    [legendLineLenSlider    setFloatValue:[plot legendLineLen]];
    [self updateLegendForm];
}

- (BOOL)legendOn
{
    return [plot legendOn];
}

- (BOOL)legendBoxOn
{
    return [plot legendBoxOn];
}

- (BOOL)legendOpaqueBackground
{
    return [plot legendOpaqueBackground];
}

- (float)legendLineLen
{
    return [plot legendLineLen];
}

- (IBAction)legendLineLenSliderMoved:(id)sender
{
	float	len = [sender floatValue];
    [plot setLegendLineLen:len];
    [legendLineLenText      setFloatValue:len];
    [canvas display];
}

- (IBAction)legendOnChanged:(id)sender
{
    [plot setLegendOn:[sender state]];
    [canvas display];
}

- (IBAction)legendBoxOnChanged:(id)sender
{
    [plot setLegendBoxOn:[sender state]];
    [canvas display];
}

- (IBAction)legendOpaqueBackgroundChanged:(id)sender
{
    [plot setLegendOpaqueBackground:[sender state]];
    [canvas display];
}

- (void)updateLegendForm
{
	int			i, n, nCurves = [plot nCurves];
	NSCell		*cell;

// clear form
	n = [legendForm numberOfRows];
	for (i = n-1; i >= 0; i--) {
		[legendForm removeEntryAtIndex:i];
	}
// ### init should be done by plotCurve
//
	for (i = 0; i < nCurves; i++) {
	//	[legendForm addEntry:[NSString stringWithFormat:@"Curve %d", i + 1]];
        [legendForm addRow];
		cell = [legendForm cellAtIndex:i];
		[cell setStringValue:[[plot curveAtIndex:i] legend]];
	}
	[legendForm sizeToFit];
	[legendPanel display];
}

- (void)formValueChanged:sender
{
	NSCell	*cell;
	int		ix;

	cell = [legendForm selectedCell];
	ix = [legendForm selectedRow];
	[[plot curveAtIndex:ix] setLegend:[cell stringValue]];
    [canvas display];
}

// read legend string in form before return is pressed
- (NSString *)legendAtIndex:(int)ix
{
    NSString *legend = [[legendForm cellAtRow:ix column:0] stringValue];
    [[plot curveAtIndex:ix] setLegend:legend];
    return legend;
}

@end


