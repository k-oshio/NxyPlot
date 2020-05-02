//
// PlotState (for saving plot)
//

#import "PlotState.h"
#import "PlotData.h"
#import "PlotRange.h"

#define PLOTFLAG_COLORPLOT          0x0001
#define PLOTFLAG_BLACKBACKGROUND    0x0002
#define PLOTFLAG_MAJORTICKMARKON    0x0004
#define PLOTFLAG_MINORTICKMARKON    0x0008
#define PLOTFLAG_AXISON             0x0010
#define PLOTFLAG_GRIDON             0x0020
#define PLOTFLAG_GRIDDOTTED         0x0040
#define PLOTFLAG_MINORGRIDON        0x0080
#define PLOTFLAG_XLOG               0x0100
#define PLOTFLAG_YLOG               0x0200
#define PLOTFLAG_LEGENDON           0x0400
#define PLOTFLAG_LEGENDBOXON        0x0800
#define PLOTFLAG_LEGENDOPAQUEBACK   0x1000

@implementation PlotState

@synthesize savePath;
@synthesize windowSize;
@synthesize xRange;
@synthesize yRange;
@synthesize mainTitle;
@synthesize xTitle;
@synthesize yTitle;
@synthesize fontSize;
@synthesize font;
@synthesize xColumn;
@synthesize legendLineLen;
@synthesize legendPos;
@synthesize frameThickness;
@synthesize gridThickness;
@synthesize minorGridThickness;
@synthesize ticMarkLen;
@synthesize symbolSize;
@synthesize lineThickness;

- (void)changeFontSizeTo:(float)newSize
{
	fontSize	= newSize;
    font		= [NSFont fontWithName:@"Helvetica" size:fontSize];
}

- (id)init
{
    self = [super init];
    if (self == nil) return nil;

// initialize states here, then copy to UI
    dataArray           = [NSArray array];
    curveArray          = [NSArray array];

    xRange              = (MinMax){0, 1, 0.2};
    yRange              = (MinMax){0, 1, 0.2};

    savePath            = @"Untitled.nxy";
    mainTitle           = @"Main Title";
    xTitle              = @"X axis";
    yTitle              = @"Y axis";
    fontSize            = 12;
    font				= [NSFont fontWithName:@"Helvetica" size:fontSize];
    xColumn             = 1;
    legendLineLen       = 40;
	legendPos			= (NSPoint){0, 0};

    windowSize          = (NSSize){600, 430};

    frameThickness      = 1.0;
    gridThickness       = 0.6;
    minorGridThickness  = 0.3;
    ticMarkLen          = 4.0;

    symbolSize          = 4.0;
    lineThickness       = 1.0;

    flags =             PLOTFLAG_COLORPLOT |
                        PLOTFLAG_BLACKBACKGROUND |
                        PLOTFLAG_MAJORTICKMARKON |
                        PLOTFLAG_AXISON |
                        PLOTFLAG_GRIDON |
                        PLOTFLAG_GRIDDOTTED ;

    return self;
}

// archiving
- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:	dataArray       forKey:@"PlotData"];        // NSArray of RecAxis
	[coder encodeObject:	curveArray      forKey:@"PlotCurve"];        // NSArray of RecAxis
// range panel
    [coder encodeFloat:     xRange.min      forKey:@"PlotXRangeMin"];
    [coder encodeFloat:     xRange.max      forKey:@"PlotXRangeMax"];
    [coder encodeFloat:     xRange.inc      forKey:@"PlotXRangeInc"];
    [coder encodeFloat:     yRange.min      forKey:@"PlotYRangeMin"];
    [coder encodeFloat:     yRange.max      forKey:@"PlotYRangeMax"];
    [coder encodeFloat:     yRange.inc      forKey:@"PlotYRangeInc"];
    [coder encodeObject:    mainTitle       forKey:@"PlotMainTitle"];
    [coder encodeObject:    xTitle          forKey:@"PlotXTitle"];
    [coder encodeObject:    yTitle          forKey:@"PlotYTitle"];
    [coder encodeObject:	font			forKey:@"PlotFont"];
    [coder encodeFloat:     fontSize        forKey:@"PlotFontSize"];
    [coder encodeInt:       xColumn         forKey:@"PlotXColumn"];
    [coder encodeSize:      windowSize      forKey:@"PlotWinSize"];
// legend panel
    [coder encodeFloat:     legendLineLen   forKey:@"PlotLegendLineLen"];
    [coder encodeFloat:     legendPos.x		forKey:@"PlotLegendPosX"];
    [coder encodeFloat:     legendPos.y		forKey:@"PlotLegendPosY"];
// axis panel
    [coder encodeFloat:     frameThickness  forKey:@"PlotFrameThickness"];
    [coder encodeFloat:     gridThickness   forKey:@"PlotGridThickness"];
    [coder encodeFloat:     minorGridThickness  forKey:@"PlotMinorGridThickness"];
    [coder encodeFloat:     ticMarkLen      forKey:@"PlotTicMarkLen"];
// line style panel
    [coder encodeFloat:     symbolSize      forKey:@"PlotSymbolSize"];
    [coder encodeFloat:     lineThickness   forKey:@"PlotLineThickness"];
// flags
    [coder encodeInt:       flags           forKey:@"PlotFlags"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];    // NSObject doesn't support NSCoding
    if (self == nil) return nil;
    dataArray       = [coder decodeObjectForKey:	@"PlotData"];        // NSArray of RecAxis
    curveArray      = [coder decodeObjectForKey:    @"PlotCurve"];       // int
// range panel
    xRange.min      = [coder decodeFloatForKey:     @"PlotXRangeMin"];
    xRange.max      = [coder decodeFloatForKey:     @"PlotXRangeMax"];
    xRange.inc      = [coder decodeFloatForKey:     @"PlotXRangeInc"];
    yRange.min      = [coder decodeFloatForKey:     @"PlotYRangeMin"];
    yRange.max      = [coder decodeFloatForKey:     @"PlotYRangeMax"];
    yRange.inc      = [coder decodeFloatForKey:     @"PlotYRangeInc"];
    mainTitle       = [coder decodeObjectForKey:    @"PlotMainTitle"];
    xTitle          = [coder decodeObjectForKey:    @"PlotXTitle"];
    yTitle          = [coder decodeObjectForKey:    @"PlotYTitle"];
    font			= [coder decodeObjectForKey:	@"PlotFont"];
    fontSize        = [coder decodeFloatForKey:     @"PlotFontSize"];
	if (fontSize == 0) {
		fontSize = 12;
	}
	if (font == nil) {
		font = [NSFont fontWithName:@"Helvetica" size:fontSize];
	}
    xColumn         = [coder decodeIntForKey:       @"PlotXColumn"];
    windowSize      = [coder decodeSizeForKey:      @"PlotWinSize"];
// legend panel
    legendLineLen   = [coder decodeFloatForKey:     @"PlotLegendLineLen"];
    legendPos.x		= [coder decodeFloatForKey:     @"PlotLegendPosX"];
    legendPos.y		= [coder decodeFloatForKey:     @"PlotLegendPosY"];
// axis panel
    frameThickness  = [coder decodeFloatForKey:     @"PlotFrameThickness"];
    gridThickness   = [coder decodeFloatForKey:     @"PlotGridThickness"];
    minorGridThickness   = [coder decodeFloatForKey:    @"PlotMinorGridThickness"];
    ticMarkLen      = [coder decodeFloatForKey:     @"PlotTicMarkLen"];
// line style panel
    symbolSize      = [coder decodeFloatForKey:     @"PlotSymbolSize"];
    lineThickness   = [coder decodeFloatForKey:     @"PlotLineThickness"];
// flags
    flags           = [coder decodeIntForKey:       @"PlotFlags"];
	return self;
}


// plot data
- (int)nFiles
{
    return [dataArray count];
}

- (void)addData:(PlotData *)aData
{
    dataArray = [dataArray arrayByAddingObject:aData];
}

- (void)removeDataAtIndex:(int)ix
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:dataArray];
    [tmpArray removeObjectAtIndex:ix];
    dataArray = [NSArray arrayWithArray:tmpArray];
}

- (PlotData *)dataAtIndex:(int)ix
{
    return [dataArray objectAtIndex:ix];
}

// plot curve
- (int)nCurves
{
    return [curveArray count];
}

- (void)addCurve:(PlotCurve *)aCurve
{
    curveArray = [curveArray arrayByAddingObject:aCurve];
}

- (PlotCurve *)curveAtIndex:(int)ix
{
    return [curveArray objectAtIndex:ix];
}

- (void)removeCurvesInRange:(NSRange)range
{
    NSMutableArray  *tmpArray = [NSMutableArray arrayWithArray:curveArray];
    [tmpArray removeObjectsInRange:range];
    curveArray = [NSArray arrayWithArray:tmpArray];
}

// flags
- (BOOL)getBit:(int)bitmap
{
    return ((flags & bitmap) != 0);
}

- (void)setBit:(int)bitmap flag:(BOOL)flg
{
    if (flg) {
        flags |= bitmap;
    } else {
        flags &= ~bitmap;
    }
}

- (BOOL)colorPlot
{
    return [self getBit:PLOTFLAG_COLORPLOT];
}

- (void)setColorPlot:(BOOL)flg
{
    [self setBit:PLOTFLAG_COLORPLOT flag:flg];
}

- (BOOL)blackBackground
{
    return [self getBit:PLOTFLAG_BLACKBACKGROUND];
}

- (void)setBlackBackground:(BOOL)flg
{
    [self setBit:PLOTFLAG_BLACKBACKGROUND flag:flg];
}

- (BOOL)majorTicMarksOn
{
    return [self getBit:PLOTFLAG_MAJORTICKMARKON];
}

- (void)setMajorTicMarksOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_MAJORTICKMARKON flag:flg];
}

- (BOOL)minorTicMarksOn
{
    return [self getBit:PLOTFLAG_MINORTICKMARKON];
}

- (void)setMinorTicMarksOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_MINORTICKMARKON flag:flg];
}

- (BOOL)axisOn
{
    return [self getBit:PLOTFLAG_AXISON];
}

- (void)setAxisOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_AXISON flag:flg];
}

- (BOOL)gridOn
{
    return [self getBit:PLOTFLAG_GRIDON];
}

- (void)setGridOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_GRIDON flag:flg];
}

- (BOOL)gridDotted
{
    return [self getBit:PLOTFLAG_GRIDDOTTED];
}

- (void)setGridDotted:(BOOL)flg
{
    [self setBit:PLOTFLAG_GRIDDOTTED flag:flg];
}

- (BOOL)minorGridOn
{
    return [self getBit:PLOTFLAG_MINORGRIDON];
}

- (void)setMinorGridOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_MINORGRIDON flag:flg];
}

- (BOOL)xLog
{
    return [self getBit:PLOTFLAG_XLOG];
}

- (void)setXLog:(BOOL)flg
{
    [self setBit:PLOTFLAG_XLOG flag:flg];
}

- (BOOL)yLog
{
    return [self getBit:PLOTFLAG_YLOG];
}

- (void)setYLog:(BOOL)flg
{
    [self setBit:PLOTFLAG_YLOG flag:flg];
}

- (BOOL)legendOn
{
    return [self getBit:PLOTFLAG_LEGENDON];
}

- (void)setLegendOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_LEGENDON flag:flg];
}

- (BOOL)legendBoxOn
{
    return [self getBit:PLOTFLAG_LEGENDBOXON];
}

- (void)setLegendBoxOn:(BOOL)flg
{
    [self setBit:PLOTFLAG_LEGENDBOXON flag:flg];
}

- (BOOL)legendOpaqueBackground
{
    return [self getBit:PLOTFLAG_LEGENDOPAQUEBACK];
}

- (void)setLegendOpaqueBackground:(BOOL)flg
{
    [self setBit:PLOTFLAG_LEGENDOPAQUEBACK flag:flg];
}


@end

