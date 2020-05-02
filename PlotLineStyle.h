//
// PlotCurves.h
// curve color, style etc
//

#import <Cocoa/Cocoa.h>

@class PlotControl, PlotData, PlotState;

// ======= PlotCurve class ========
@interface PlotCurve:NSObject <NSCoding>
{
}

@property   NSColor     *color;     // color of curve
@property   NSColor     *color2;    // adjusted color for white background
@property   int         lineStyle;
@property   int         symbol;
@property   NSString    *legend;

+ (PlotCurve *)curveWithColor:(NSColor *)col style:(int)style symbol:(int)symbol;

@end

// ======== Line Style Control Class ========
@interface PlotLineStyle:NSObject
{
	IBOutlet PlotControl	*control;           // main control
    PlotState               *plot;              // state object

// line style panel
    IBOutlet id				symbolLinePanel;
    IBOutlet id				symbolButtons;
    IBOutlet id				lineStyleButtons;
	IBOutlet id				slView;             // content view of scroll view
    IBOutlet id				lineThicknessText;
    IBOutlet id             lineThicknessSlider;
    IBOutlet id				symbolSizeText;
    IBOutlet id             symbolSizeSlider;
}

// state
- (void)setPlotState:(PlotState *)state;
// update UI according to state
- (void)updatePanel;

// curves
- (IBAction)radioButtonPressed:sender;
- (IBAction)symbolSizeChanged:sender;
- (IBAction)lineThicknessChanged:sender;
- (PlotCurve *)curveAt:(int)index;
- (NSColor *)colorAt:(int)index;
- (id)addCurves:(int)ncurves;
- (int)nCurves;
- (void)updateSymbolLineMatrix;
- (float)lineThickness;
- (float)symbolSize;

@end