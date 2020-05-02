//
//	PlotRange.h (Range Control Class)
//

#import <Cocoa/Cocoa.h>

@class PlotState, PlotView, PlotControl;

enum {
	LABEL_AXIS  = 1,
	LABEL_MAJOR = 2,
	LABEL_MINOR = 4,
    LABEL_FRAME = 8
};

typedef struct MinMax {
	double	min;
	double	max;
	double	inc;
} MinMax;

@interface PlotLabel:NSObject
{
}
@property double    value;
@property int       flag;

+ (PlotLabel *)label;

@end

@interface PlotRange:NSObject
{
// outlets
    IBOutlet PlotControl	*control;   // doesn't change
    PlotState               *plot;      // contents changes when loaded from archive
    IBOutlet PlotView       *canvas;

// UI on Range panel
    IBOutlet NSButton       *xLogButton;
    IBOutlet NSButton       *yLogButton;
    IBOutlet NSTextField    *xMinField;
    IBOutlet NSTextField    *xMaxField;
    IBOutlet NSTextField    *xIncField;
    IBOutlet NSTextField    *xNticField;
    IBOutlet NSTextField    *yMinField;
    IBOutlet NSTextField    *yMaxField;
    IBOutlet NSTextField    *yIncField;
    IBOutlet NSTextField    *yNticField;

    IBOutlet NSTextField    *mainTitleField;
    IBOutlet NSTextField    *xTitleField;
    IBOutlet NSTextField    *yTitleField;

    IBOutlet NSTextField	*fontSizeText;
	IBOutlet NSStepper		*fontSizeStepper;
	IBOutlet NSPopUpButton	*xAxisColumn;       // 0: index, 1: 1st, 2: 2nd
//	NSFont					*font;

    IBOutlet id             widthField;
    IBOutlet id             heightField;

// local strage
	MinMax					oldXRange;  // previous range
	MinMax					oldYRange;  // previous range
	NSArray					*xLabel;
	NSArray					*yLabel;
}

//=== update State object reference
- (void)setPlotState:(PlotState *)state;
- (void)updatePanel;    // state -> UI

- (BOOL)xAxisLog;
- (BOOL)yAxisLog;

// data range (log10 for log plot)
- (MinMax)xRange;
- (MinMax)yRange;
- (int)yntic;
- (int)xntic;
- (void)updateRange;
- (void)setXRange:(MinMax)mmx;
- (void)setYRange:(MinMax)mmx;
- (void)setXntic:(int)val;
- (void)setYntic:(int)val;
// title text
- (NSString *)mainTitle;
- (NSString *)xTitle;
- (NSString *)yTitle;
- (void)setMainTitle:(NSString *)str;
- (void)setXTitle:(NSString *)str;
- (void)setYTitle:(NSString *)str;
//- (NSFont *)font;
- (IBAction)fontSizeChanged:(id)sender;
- (int)xColumn;
- (void)setWindowSize:(NSSize)size;
- (IBAction)windowSizeChanged:(id)sender;

- (void)niceMinMaxInc:(NSPoint)dataMin :(NSPoint)dataMax incOnly:(BOOL)flag;

- (IBAction)rangeChanged:(id)sender;
- (IBAction)logChanged:(id)sender;

- (void)updateRange;    // range -> label etc
- (NSArray *)makeLinLabelWithRange:(MinMax)mmx ntic:(int)ntic;
- (NSArray *)makeLogLabelWithRange:(MinMax)mmx ntic:(int)ntic;
- (NSArray *)xLabel;	// array of PlotLabel
- (NSArray *)yLabel;	// array of PlotLabel

- (void)pushMinMax;
- (void)popMinMax;

@end
