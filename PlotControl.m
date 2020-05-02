//
//	PlotControl.m
//

#import "PlotControl.h"
#import "PlotData.h"
#import "PlotRange.h"
#import "PlotLineStyle.h"
#import "PlotState.h"
#import "PlotView.h"
#import "PlotAxis.h"
#import "PlotLegend.h"

#import <math.h>		/* for MAXFLOAT, etc. */

@implementation PlotControl

- init
{
	self = [super init];
    if (self == nil) return nil;
    plot = [[PlotState alloc] init];

    return self;
}

- (PlotState *)plot
{
    return plot;
}

- (void)awakeFromNib
{
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    [printInfo setOrientation:NSLandscapeOrientation];
    [self setPlotStateToSubcontrols]; // set state (not set by IB)
    [self updatePanels]; // update UI according to state
    [window makeKeyAndOrderFront:self];
//    [self windowDidResize:nil];
}

- (void)setPlotStateToSubcontrols    // set state object reference
{
    [axis   setPlotState:plot];
    [range  setPlotState:plot];
    [curves setPlotState:plot];
    [legend setPlotState:plot];
    [canvas setPlotState:plot];
}

- (void)updatePanels    // update UI according to state
{
    [axis   updatePanel];
    [range  updatePanel];
    [curves updatePanel];
    [legend updatePanel];
    [canvas updatePanel];
}

- (void)windowDidResize:(NSNotification *)nt
{
    NSSize  sz = [window frame].size;
    [range setWindowSize:sz];
}

- (void)changeWindowSizeTo:(NSSize)sz
{
    NSRect  fr = [window frame];
    fr.size = sz;
    [window setFrame:fr display:YES];
}

- (void)updateFileRemovalMatrix
{
    int			i, nFiles = [plot nFiles];
	NSString	*str;
    NSInteger	numrows, numcols;

    // Fix up the filename matrix
    [fileRemovalButtons getNumberOfRows:&numrows columns:&numcols];
    [fileRemovalButtons renewRows:nFiles columns:1];
    for (i = 0; i < nFiles; i++) {
		str = [[self data:i] path];
        if (![str isEqualToString:@"pasteboard"]) {
			str = [str lastPathComponent];
        }
        [[fileRemovalButtons cellAtRow:i column:0] setTitle:str];
        [[fileRemovalButtons cellAtRow:i column:0] setState:0];
    }
    [fileRemovalButtons sizeToCells];
}

- (void)removeFiles:(id)sender
{
    int				i, ix;
	int				nFiles = [plot nFiles];
	int				nCurvesInFile;
 
    if (nFiles == 0) {
        return;
    }

// remove line style (Curve obj)
	for (i = ix = 0; i < nFiles; i++) {
        nCurvesInFile = [[plot dataAtIndex:i] nCurves];
        if ([[fileRemovalButtons cellAtRow:i column:0] state] == NSOnState) {
			[plot removeCurvesInRange:NSMakeRange(ix, nCurvesInFile)];
		} else {
			ix += nCurvesInFile;
		}
	}
	[curves updateSymbolLineMatrix];
	[legend updateLegendForm];

// remove data
    for (i = nFiles - 1; i >= 0; i--) {
        if ([[fileRemovalButtons cellAtRow:i column:0] state] == NSOnState) {
            [plot removeDataAtIndex:i];
        }
    }
// file removal panel
    [self updateFileRemovalMatrix];
    [fileRemovalPanel display];

// update global min/max
    [self findGlobalMinMax];

// display
    [canvas display];
}

- (PlotData *)data:(int)index
{
	return [plot dataAtIndex:index];
}

- (PlotLineStyle *)curves
{
	return curves;
}

- (int)nFiles
{
	return [plot nFiles];
}

- (void)findGlobalMinMax
{
	int			i, nFiles = [plot nFiles];
	PlotData	*data;
	NSPoint     datamin, datamax;

    globaldatamin = NSMakePoint(MAXFLOAT, MAXFLOAT);
    globaldatamax = NSMakePoint(-MAXFLOAT, -MAXFLOAT);

    for (i = 0; i < nFiles; i++) {
        data = [plot dataAtIndex:i];
        datamin = [data datamin];
        datamax = [data datamax];
        globaldatamin.x = MIN(globaldatamin.x, datamin.x);
        globaldatamax.x = MAX(globaldatamax.x, datamax.x);
        globaldatamin.y = MIN(globaldatamin.y, datamin.y);
        globaldatamax.y = MAX(globaldatamax.y, datamax.y);
    }
}

- (NSPoint)globalMin
{
    return globaldatamin;
}

- (NSPoint)globalMax
{
    return globaldatamax;
}

- (void)autoScale:(id)sender
{
	[range pushMinMax];
    [range niceMinMaxInc:[self globalMin] :[self globalMax] incOnly:NO];
	[range updateRange];
    [canvas display];
}

- (void)drawPlot:(id)sender
{
    [canvas display];
}

// Use the OpenPanel object to get a filename
- (void)plotFromFile:(id)sender
{
    NSOpenPanel     *openPanel = [NSOpenPanel openPanel];
    NSString        *path;
    NSString        *inString;
	NSArray			*subStrings;
    NSError         *err;
	int				i, n;
    int				sts;

    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAccessoryView:nil]; /* may have to clean out an accessory view */
    if ([plot nFiles] == 0) {
        [openPanel setTitle:@"Open"];	/* make sure title is OK */
    } else {
        [openPanel setTitle:@"Open Additional File"];
    }

    sts = [openPanel runModal];
    if (sts != NSOKButton) return;
    path = [[openPanel URL] path];
	if ([[path pathExtension] isEqualToString:@"nxy"]) {	// check image type
		return;
	}
    inString = [NSString stringWithContentsOfFile:path
				encoding:NSASCIIStringEncoding error:&err];
	// break into sub-curves
    subStrings = [inString componentsSeparatedByString:@"!eoc\n"];

	// plot all sub-curves
	n = [subStrings count];
	for (i = 0; i < n; i++) {
		[self parseAndPlot:[subStrings objectAtIndex:i] name:path];
	}
	[window setTitleWithRepresentedFilename:path];
    [window makeKeyAndOrderFront:self];

    [canvas display];
}

- (BOOL)application:(id)sender openFileWithoutUI:(NSString *)filename
{
    [self openFile:filename];
    return YES;
}

// open binary plot file
- (IBAction)open:(id)sender
{
    NSOpenPanel     *openPanel = [NSOpenPanel openPanel];
    NSString        *path;
    int				sts;

    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAccessoryView:nil];

    sts = [openPanel runModal];
    if (sts != NSOKButton) return;
    path = [[openPanel URL] path];

	if (![[path pathExtension] isEqualToString:@"nxy"]) {	// check image type
		return;
	}
    [self openFile:path];
}

- (void)openFile:(NSString *)path
{
// PlotState
	plot = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    [plot setSavePath:path];
    [self setPlotStateToSubcontrols];

    [self updatePanels];            // UI update
//	[legend updateLegendForm];      // update legend strings

    [self findGlobalMinMax];
    [self updateFileRemovalMatrix];

    [self changeWindowSizeTo:[plot windowSize]]; // doesn't work in PlotAxis (???)
    [window setTitle:path];
    [window makeKeyAndOrderFront:self];

    [canvas display];
}

- (IBAction)save:(id)sender
{
    NSString    *path = [plot savePath];
	[NSKeyedArchiver archiveRootObject:plot toFile:path];
}

// save plot to binary file
- (IBAction)saveAs:(id)sender
{
	NSSavePanel	*savePanel = [NSSavePanel savePanel];
	NSString	*path;
	int			sts;
	
	if (!savePanel) savePanel = [NSSavePanel savePanel];
    sts = [savePanel runModal];
	if (sts != NSOKButton) {
		return;
	} else {
		path = [[savePanel URL] path];
	}

// save to path
	if (![[path pathExtension] isEqualToString:@"nxy"]) {	// force "nxy" extention
		path = [path stringByAppendingPathExtension:@"nxy"];
	}
    [plot setSavePath:path];
    [window setTitle:path];
	[NSKeyedArchiver archiveRootObject:plot toFile:path];
}

// this is necessary as a common method
// between plot_from_file & plot_from_pasteboard
- (void)parseAndPlot:(NSString *)str name:(NSString *)path
{
	PlotData	*data;
	int			col = [range xColumn];

// read (parse) data
	data = [[PlotData alloc] init];
	if (![data readString:str name:path xColumn:col]) return;
    [data findMinMax];
    [plot addData:data];

// ### this should be done once per curve group ###
	[curves addCurves:[data nCurves]];
	[legend updateLegendForm];
    [self findGlobalMinMax];
    [self updateFileRemovalMatrix];

// nice min-max for first file
    if ([plot nFiles] == 1) {
        [range niceMinMaxInc:[self globalMin] :[self globalMax] incOnly:NO];
		[range updateRange];
    }

}

- (void)plotFromPasteboard:(id)sender
{
	NSPasteboard	*pb = [NSPasteboard generalPasteboard];
    NSString        *data = nil;

	[self plotService:pb userData:data];
}

// takes string data from pasteboard
- (void)plotService:pb
	userData:(NSString *)data
{
	NSString        *tmpstr;

    if ([[pb types] containsObject:NSStringPboardType]) {
    	tmpstr = [pb stringForType:NSStringPboardType];
        if (tmpstr == nil) {
			NSRunAlertPanel(@"Read", @"Couldn't read any data from %s", @"OK",
				nil, nil, "pasteboard");
        } else {
            [self parseAndPlot:tmpstr name:@"pasteboard"];
			[canvas display];
        }
    }
}

- (void)previousView:(id)sender
{
    [range popMinMax];
	[range updatePanel];
    [canvas display];
}


@end
