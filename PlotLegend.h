//
// PlotLegend.h
// controller object for legend panel
//

#import <Cocoa/Cocoa.h>

@class PlotView, PlotState;

@interface PlotLegend:NSObject
{
// reference
    IBOutlet id             canvas;
    PlotState               *plot;
// legend panel
    IBOutlet id				legendPanel;
    IBOutlet id             legendForm;         // NSMatrix
    IBOutlet id             legendOn;
    IBOutlet id             legendBoxOn;
    IBOutlet id             legendOpaqueBackground;
    IBOutlet id             legendLineLenText;
    IBOutlet id             legendLineLenSlider;

}

- (void)setPlotState:(PlotState *)state;
- (void)updatePanel;
- (BOOL)legendOn;
- (BOOL)legendBoxOn;
- (BOOL)legendOpaqueBackground;
- (float)legendLineLen;

- (IBAction)legendLineLenSliderMoved:(id)sender;
- (IBAction)legendOnChanged:(id)sender;
- (IBAction)legendBoxOnChanged:(id)sender;
- (IBAction)legendOpaqueBackgroundChanged:(id)sender;
- (void)updateLegendForm;
- (IBAction)formValueChanged:sender;
- (NSString *)legendAtIndex:(int)ix;    // read string in form before return is hit

@end


