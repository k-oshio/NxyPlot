//
// PlotControl.h
// main controller object
//
// === plans / bugs ===
// "curve groups" ?? for trajectory plot etc
// add curve reordering (NSTableView ?)
// add curve color changing (NSColorWell)

#import <Cocoa/Cocoa.h>

@class PlotView, PlotRange, PlotData, PlotLineStyle, PlotState, PlotAxis, PlotLegend;

@interface PlotControl:NSObject
{
//  state
    PlotState               *plot;  // loaded object replaces old one
// sub controls
    IBOutlet PlotAxis       *axis;
    IBOutlet PlotLegend     *legend;
    IBOutlet PlotRange		*range;			// PlotRange object (sub-control)
	IBOutlet PlotLineStyle  *curves;		// PlotCurves object (sub-control)

// main win outlets
    IBOutlet PlotView       *canvas;			// main view
    IBOutlet NSWindow       *window;            // main window
    IBOutlet id				plotButton;

// local storage
    NSPoint					globaldatamin;  // xmin and ymin from the data
    NSPoint					globaldatamax;	// xmax and ymax from the data

// file removal panel
    IBOutlet id             fileRemovalPanel;       // file removal UI
    IBOutlet NSMatrix		*fileRemovalButtons;	// UI element

// error bars (not implemented yet)
    IBOutlet id errorBarBaseWidth;
    IBOutlet id errorBarMatrix;
}

- (id)init;

//===== PlotState ===
- (PlotState *)plot;
- (int)nFiles;
- (PlotData *)data:(int)index;
//- (void)updateState;				// set state object reference
- (void)setPlotStateToSubcontrols;
- (void)updatePanels;            // update UI according to state

//===== Control itself ===
- (void)windowDidResize:(NSNotification *)nt;
- (void)changeWindowSizeTo:(NSSize)sz;
- (IBAction)autoScale:(id)sender;
- (IBAction)drawPlot:(id)sender;

- (IBAction)plotFromFile:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)saveAs:(id)sender;

- (IBAction)plotFromPasteboard:(id)sender;
- (IBAction)removeFiles:(id)sender;
- (IBAction)previousView:(id)sender;

- (void)parseAndPlot:(NSString *)path name:(NSString *)fname;
- (void)plotService:pb userData:(NSString *)data;
- (void)updateFileRemovalMatrix;
- (void)findGlobalMinMax;
- (NSPoint)globalMin;
- (NSPoint)globalMax;

@end
