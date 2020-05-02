//
//	Ploturves.m
//

#import "PlotLineStyle.h"
#import "PlotView.h"	// structs / consts
#import "PlotControl.h"
#import "PlotState.h"

// ======= PlotCurve Class ======
@implementation PlotCurve

@synthesize     color;
@synthesize     color2;
@synthesize     lineStyle;
@synthesize     symbol;
@synthesize     legend;

+ (PlotCurve *)curveWithColor:(NSColor *)col style:(int)style symbol:(int)symbol
{
	PlotCurve   *curve;
    NSColor     *col2;
    float       hue;

    hue     = [col hueComponent];
    col2    = [NSColor colorWithCalibratedHue:hue
                                 saturation:1.0     // col: 0.8
                                 brightness:0.8     // col: 1.0
                                      alpha:1.0];   // col: 1.0
	curve = [[PlotCurve alloc] init];
	[curve setColor:col];
    [curve setColor2:col2];
	[curve setLineStyle:style];
	[curve setSymbol:symbol];

	return curve;
}

// archiving
- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:	color       forKey:@"CurveColor"];
	[coder encodeObject:	color2      forKey:@"CurveColor2"];
    [coder encodeInt:       lineStyle   forKey:@"CurveLineStyle"];
    [coder encodeInt:       symbol      forKey:@"CurveSymbol"];
    [coder encodeObject:    legend      forKey:@"CurveLegend"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];    // NSObject doesn't support NSCoding
    if (self == nil) return nil;
    color       = [coder decodeObjectForKey:	@"CurveColor"];
    color2      = [coder decodeObjectForKey:	@"CurveColor2"];
    lineStyle	= [coder decodeIntForKey:       @"CurveLineStyle"];
    symbol      = [coder decodeIntForKey:       @"CurveSymbol"];
    legend      = [coder decodeObjectForKey:	@"CurveLegend"];

	return self;
}

@end

// ======= Curve Array Class ======
@implementation PlotLineStyle

- init
{
	self = [super init];
    if (self == nil) return nil;

    return self;
}

- (void)setPlotState:(PlotState *)state
{
    plot = state;
}

- (void)awakeFromNib
{
	NSNumberFormatter	*formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormat:@"0.0#;0;-0.0#"];

	[symbolButtons		setMode:NSListModeMatrix];
	[lineStyleButtons	setMode:NSListModeMatrix];
 	[symbolSizeText     setFormatter:formatter];
	[lineThicknessText  setFormatter:formatter];

    [self updatePanel];
}

// update UI according to state
- (void)updatePanel
{
    [symbolSizeText         setFloatValue:[plot symbolSize]];
    [symbolSizeSlider       setFloatValue:[plot symbolSize]];
    [lineThicknessText      setFloatValue:[plot lineThickness]];
    [lineThicknessSlider    setFloatValue:[plot lineThickness]];
    [self updateSymbolLineMatrix];    // update line style matrix
}

- (PlotCurve *)curveAt:(int)index
{
    return [plot curveAtIndex:index];
}

- (int)linestyle:(int)aCurve
{
    int             row;

    for (row = 0; row < N_LINE_STYLES; row++) {
        if ([[lineStyleButtons cellAtRow:row column:aCurve] state] == NSOnState) {
            return row;
        }
    }
    return 0;		// for safety
}

- (int)symbolstyle:(int)index
{
    int             row;

    for (row = 0; row < N_SYMBOL_STYLES; row++) {
        if ([[symbolButtons cellAtRow:row column:index] state] == NSOnState) {
            return row;
        }
    }
    return 0;		// for safety
}

- (float)lineThickness
{
	return [plot lineThickness];
}

- (float)symbolSize
{
	return [plot symbolSize];
}

- (int)nCurves
{
    return [plot nCurves];
}

- (NSColor *)colorAt:(int)index
{
	NSColor		*color;
	float		hue;

	hue = (index + 1) * 0.215;	// red is not for first one...
//	hue = (index + 1) * 0.382;	// golden angle
	hue -= (int)hue;
	color = [NSColor colorWithCalibratedHue:hue
								 saturation:0.8
								 brightness:1.0
									  alpha:1.0];
	return color;
}

- (id)addCurves:(int)n
{
    int             i, ix, nCurves = [plot nCurves];
    NSColor         *color;
	PlotCurve		*curve;
	NSString		*legend;

	ix = nCurves;
	for (i = 0; i < n; i++, ix++) {
		color = [self colorAt:ix];
		curve = [PlotCurve curveWithColor:color style:SOLID symbol:NOSYMBOL];
		legend = [NSString stringWithFormat:@"Curve %d", ix + 1];
		[curve setLegend:legend];
        [plot addCurve:curve];
	}
    [self updateSymbolLineMatrix];


    return self;
}

- (void)updateSymbolLineMatrix
{
    NSInteger	sRows, lRows, numcols;
	int			nCurves = [plot nCurves];
    int			i, j;
    NSRect      bbox, fbox;
	PlotCurve	*curve;

// Symbol
    [symbolButtons getNumberOfRows:&sRows columns:&numcols];
    [symbolButtons renewRows:sRows columns:nCurves];
	[lineStyleButtons getNumberOfRows:&lRows columns:&numcols];
	[lineStyleButtons renewRows:lRows columns:nCurves];

// update cells
    for (i = 0; i < nCurves; i++) {
		curve = [self curveAt:i];
		// symbol
        for (j = 0; j < sRows; j++) {
            if (j == [curve symbol]) {
                [[symbolButtons cellAtRow:j column:i]
                        setState:1];
            } else {
                [[symbolButtons cellAtRow:j column:i]
                        setState:0];
            }
        }
		// lineStyle
		for (j = 0; j < lRows; j++) {
			if (j == [curve lineStyle]) {
				[[lineStyleButtons cellAtRow:j column:i]
                        setState:1];
			} else {
				[[lineStyleButtons cellAtRow:j column:i]
                        setState:0];
			}
		}
    }
    [symbolButtons sizeToCells];
	[lineStyleButtons sizeToCells];

// adjust clipView bounds
    bbox = [slView frame];
    fbox = [symbolButtons frame];
    bbox.size.width = fbox.origin.x + fbox.size.width + 1;
    [slView setFrame:bbox];
	[symbolLinePanel display];
}

- (void)radioButtonPressed:sender
{
    int	row = [sender selectedRow];
    int	col = [sender selectedColumn];

	if (sender == symbolButtons) {
		[[self curveAt:col] setSymbol:row];
	}
	if (sender == lineStyleButtons) {
		[[self curveAt:col] setLineStyle:row];
	}
	[self updateSymbolLineMatrix];
	[control drawPlot:self];
}

- (void)symbolSizeChanged:sender
{
	float	size = [sender floatValue];
	[symbolSizeText setFloatValue:size];
    [plot setSymbolSize:size];
	[control drawPlot:self];
}

- (void)lineThicknessChanged:sender
{
	float	size = [sender floatValue];
	[lineThicknessText setFloatValue:size];
    [plot setLineThickness:size];
	[control drawPlot:self];
}

@end