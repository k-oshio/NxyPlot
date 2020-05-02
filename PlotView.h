//
//	PlotView.h
//

#import <Cocoa/Cocoa.h>

@class PlotControl, PlotRange, PlotLineStyle, PlotCurve, PlotData, PlotAxis, PlotLegend, PlotState;

#define XOFFSET			102		// offsets (in pixels) of axis origin from
#define YOFFSET			60		// lower left hand corner of the window
#define XMARGIN			50
#define YMARGIN			40
#define DEFAULTFONTSIZE 12

enum symboltypes {
    NOSYMBOL = 0,
    CIRCLE,
    XMARK,
    UPTRIANGLE,
    DOWNTRIANGLE,
    DIAMOND,
    SQUARE,
    PLUS,
    N_SYMBOL_STYLES
};

enum linetypes {
    SOLID       = 0,
    DASH        = 1,
    DOT         = 2,
    CHAINDASH   = 3,
    CHAINDOT    = 4,
    NOLINE      = 5,
    N_LINE_STYLES
};

@interface PlotView:NSView
{
//  state
    PlotState               *plot;  // loaded object replaces old one
// outlets for control objects
    IBOutlet PlotControl	*control;
    IBOutlet PlotAxis       *axis;
    IBOutlet PlotLegend     *legend;
	IBOutlet PlotRange      *range;
    IBOutlet PlotLineStyle  *curves;

// local strage
	NSRect		legendRect;
	NSPoint		legendPos;	// position of LB's UR corner wrt UR corner of plot area
    // graph rect in view coodinate system
    NSPoint     llCorner;
    NSPoint     urCorner;
    // graph scale in graph view coordinates
    double		xmin;
    double		xmax;
    double		ymin;
    double		ymax;
	// scale factor
    double		ppxunit;        // pixels per x unit
    double		ppyunit;        // pixels per y unit
	// print / display flag
    BOOL        printing;
    BOOL        copying;
	// cache
	BOOL		xlog;
	BOOL		ylog;
    // selection cursor
    NSRect      selectRect;
    BOOL        selectOn;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)rects;
- (BOOL)printing;
- (void)getRange;
- (void)clear;
- (void)drawTitles;
- (void)drawGraphFrame;
- (void)drawLines;
- (void)drawSymbols;
- (void)drawLegends;
- (void)updatePanel;    

- (void)setPlotState:(PlotState *)state;

// event handling
- (void)mouseDown:(NSEvent *)e;

@end
