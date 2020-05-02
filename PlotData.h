//
//	PlotData
//

#import <Cocoa/Cocoa.h>

@interface PlotData:NSObject <NSCoding>
{
	NSString	*path;
    // make NSData
    float		*x;				// x data
    float		**y;			// y data
    BOOL		has_exbars;		// error bar
    BOOL		has_eybars;		// error bar
    float		*ex;			// x error bar
    float		**ey;			// y error bar
    //============
    int			npoints;
    int			ncurves;        // n curves in data
    NSPoint 	datamin;
    NSPoint 	datamax;
}

@property   int colorOffset;

// instance methods
- init;
- (void)allocDataWithNPoints:(int)np nCurves:(int)nc;
- (void)deallocData;
- (BOOL)readString:(NSString *)inString name:(NSString *)fname xColumn:(int)col;
- (void)setPath:(NSString *)path;
- (void)dealloc;

- (void)has_exbars:(BOOL)flag;
- (void)has_eybars:(BOOL)flag;

- (NSString *)path;
- (float *)xdata;
- (float *)exdata;
- (float **)ydata;
- (float **)eydata;
- (NSPoint)datamin;
- (NSPoint)datamax;
- (BOOL)has_exbars;
- (BOOL)has_eybars;
- (int) nPoints;
- (int) nCurves;

- (void)findMinMax;

@end
