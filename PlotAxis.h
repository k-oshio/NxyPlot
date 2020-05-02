//
// PlotAxis.h
// controller object for axis panel
// handles graphic aspect of "axis"
// axis itself is handled by PlotRange
//

#import <Cocoa/Cocoa.h>

@class PlotView, PlotRange, PlotData, PlotLineStyle, PlotState, PlotControl;

@interface PlotAxis:NSObject
{
// outlets
    PlotState               *plot;      // contents changes when loaded from archive
    IBOutlet PlotView       *canvas;
	IBOutlet PlotLineStyle	*curves;

    IBOutlet id             ticMarkLenText;
    IBOutlet id             ticMarkLenSlider;
    IBOutlet id             gridThicknessText;
    IBOutlet id             gridThicknessSlider;
    IBOutlet id             minorGridThicknessText;
    IBOutlet id             minorGridThicknessSlider;
    IBOutlet id             frameThicknessText;
    IBOutlet id             frameThicknessSlider;
    IBOutlet id             majorTicMarksOnButton;
    IBOutlet id             minorTicMarksOnButton;
    IBOutlet id             axisOnButton;
    IBOutlet id             gridOnButton;
    IBOutlet id             gridDottedButton;
    IBOutlet id             minorGridOnButton;
    IBOutlet id             blackBackgroundButton;
    IBOutlet id             colorCurvesButton;
    IBOutlet id             resetColorButton;
    NSColor                 *backgroundColor;
    NSColor                 *textColor;
}

- (void)setPlotState:(PlotState *)state;
- (void)updatePanel;
- (NSColor *)textColor;
- (NSColor *)backgroundColor;
- (void)setColors;
- (BOOL)colorPlot;
- (float)ticMarkLen;
- (float)gridThickness;
- (float)minorGridThickness;
- (float)frameThickness;
- (BOOL)majorTicMarksOn;
- (BOOL)minorTicMarksOn;
- (BOOL)axisOn;
- (BOOL)gridOn;
- (BOOL)gridDotted;
- (BOOL)minorGridOn;

- (IBAction)axisOnChanged:(id)sender;
- (IBAction)gridOnChanged:(id)sender;
- (IBAction)gridDottedChanged:(id)sender;
- (IBAction)minorGridOnChanged:(id)sender;
- (IBAction)majorTicMarksOnChanged:(id)sender;
- (IBAction)minorTicMarksOnChanged:(id)sender;
- (IBAction)frameThicknessChanged:(id)sender;
- (IBAction)gridThicknessChanged:(id)sender;
- (IBAction)minorGridThicknessChanged:(id)sender;
- (IBAction)ticMarkLenChanged:(id)sender;
- (IBAction)blackBackgroundChanged:(id)sender;
- (IBAction)colorPlotChanged:(id)sender;
- (IBAction)resetColor:(id)sender;

@end


