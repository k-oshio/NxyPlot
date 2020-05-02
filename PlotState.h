//
// "state" of the plot. only info within this is saved / loaded
// this object is created and kept by PlotControl
//

#import <Cocoa/Cocoa.h>
#import "PlotRange.h"
#import "PlotLineStyle.h"

@class PlotData;

// object for archiving
@interface PlotState:NSObject <NSCoding>
{
    NSArray     *dataArray;     // data
	NSArray     *curveArray;    // line style
    int         flags;
// === axis
// colorPlot                1
// blackBackground          2
// majorTicMarksOn          4
// minorTicMarksOn          8
// axisOn                   10
// gridOn                   20
// gridDotted               40
// minorGridOn              80
// === range
// xLog                     100
// yLog                     200
// == legend
// legendOn                 400
// legendBoxOn              800
// legendOpaqueBackground   1000


}
// main control
@property NSString  *savePath;
@property NSSize    windowSize;
// range
@property MinMax    xRange;
@property MinMax    yRange;
@property NSString  *mainTitle;
@property NSString  *xTitle;
@property NSString  *yTitle;
@property NSFont	*font;
@property float     fontSize;
@property int       xColumn;
// legend
@property float     legendLineLen;
@property NSPoint   legendPos;
//@property NSRect	legendRect;
// axis
@property float     frameThickness;
@property float     gridThickness;
@property float     minorGridThickness;
@property float     ticMarkLen;
// line style
@property float     symbolSize;
@property float     lineThickness;

- (void)changeFontSizeTo:(float)newSize;

// plot data
- (int)nFiles;
- (void)addData:(PlotData *)aData;
- (void)removeDataAtIndex:(int)ix;
- (PlotData *)dataAtIndex:(int)ix;
// plot curve
- (int)nCurves;
- (void)addCurve:(PlotCurve *)aCurve;
- (PlotCurve *)curveAtIndex:(int)ix;
- (void)removeCurvesInRange:(NSRange)range;
// flags
- (BOOL)colorPlot;
- (void)setColorPlot:(BOOL)flg;
- (BOOL)blackBackground;
- (void)setBlackBackground:(BOOL)flg;
- (BOOL)majorTicMarksOn;
- (void)setMajorTicMarksOn:(BOOL)flg;
- (BOOL)minorTicMarksOn;
- (void)setMinorTicMarksOn:(BOOL)flg;
- (BOOL)axisOn;
- (void)setAxisOn:(BOOL)flg;
- (BOOL)gridOn;
- (void)setGridOn:(BOOL)flg;
- (BOOL)gridDotted;
- (void)setGridDotted:(BOOL)flg;
- (BOOL)minorGridOn;
- (void)setMinorGridOn:(BOOL)flg;
- (BOOL)xLog;
- (void)setXLog:(BOOL)flg;
- (BOOL)yLog;
- (void)setYLog:(BOOL)flg;
- (BOOL)legendOn;
- (void)setLegendOn:(BOOL)flg;
- (BOOL)legendBoxOn;
- (void)setLegendBoxOn:(BOOL)flg;
- (BOOL)legendOpaqueBackground;
- (void)setLegendOpaqueBackground:(BOOL)flg;

@end

