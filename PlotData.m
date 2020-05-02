//
//	PlotData
//	10-14-2000	K. Oshio
//

#import <PlotData.h>

@implementation PlotData

@synthesize     colorOffset;

- init
{
	self = [super init];
    if (self == nil) return nil;
	path = nil;
    x = ex = (float *)NULL;
    y = ey = (float **)NULL;
    npoints = ncurves = 0;
	datamin = NSZeroPoint;
	datamax = NSZeroPoint;
    has_exbars = has_eybars = NO;
    colorOffset = 0;

    return self;
}

- (void)encodeDataWithCoder:(NSCoder *)coder
{
    float   *buf;
    int     i, j, ix, len;

    len = npoints * ncurves;
// x
    [coder encodeBytes:(const uint8_t *)x  length:npoints * sizeof(float) forKey:@"DataX"];
    [coder encodeBytes:(const uint8_t *)ex length:npoints * sizeof(float) forKey:@"DataEX"];
// y
    buf = (float *)malloc(sizeof(float) * len);
    for (i = ix = 0; i < ncurves; i++) {
        for (j = 0; j < npoints; j++, ix++) {
            buf[ix] = y[i][j];
        }
    }
    [coder encodeBytes:(const uint8_t *)buf length:len * sizeof(float) forKey:@"DataY"];
    for (i = ix = 0; i < ncurves; i++) {
        for (j = 0; j < npoints; j++, ix++) {
            buf[ix] = ey[i][j];
        }
    }
    [coder encodeBytes:(const uint8_t *)buf length:len * sizeof(float) forKey:@"DataEY"];
    free(buf);
}

- (void)decodeDataWithCoder:(NSCoder *)coder
{
    const float *buf;
    int         i, j, ix;
    NSUInteger  returnedLen;

    [self allocDataWithNPoints:npoints nCurves:ncurves];
    buf = (const float *)[coder decodeBytesForKey:@"DataX" returnedLength:&returnedLen];
    if (x == NULL) return;
    for (j = 0; j < npoints; j++) {
        x[j] = buf[j];
    }
    buf = (const float *)[coder decodeBytesForKey:@"DataEX" returnedLength:&returnedLen];
    if (ex == NULL) return;
    for (j = 0; j < npoints; j++) {
        ex[j] = buf[j];
    }
    buf = (const float *)[coder decodeBytesForKey:@"DataY" returnedLength:&returnedLen];
    for (i = ix = 0; i < ncurves; i++) {
        for (j = 0; j < npoints; j++, ix++) {
            if (ix >= returnedLen) break;
            y[i][j] = buf[ix];
        }
    }
    buf = (const float *)[coder decodeBytesForKey:@"DataEY" returnedLength:&returnedLen];
    for (i = ix = 0; i < ncurves; i++) {
        for (j = 0; j < npoints; j++, ix++) {
            if (ix >= returnedLen) break;
            ey[i][j] = buf[ix];
        }
    }
}

// archiving
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:    path        forKey:@"DataPath"];
    [coder encodeInt:       npoints     forKey:@"DataNP"];
    [coder encodeInt:       ncurves     forKey:@"DataNC"];
    [coder encodeBool:      has_exbars  forKey:@"DataHasEX"];
    [coder encodeBool:      has_eybars  forKey:@"DataHasEY"];
    [self encodeDataWithCoder:coder];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];    // NSObject doesn't support NSCoding
    if (self == nil) return nil;
    path        = [coder decodeObjectForKey:	@"DataPath"];
    npoints     = [coder decodeIntForKey:       @"DataNP"];
    ncurves     = [coder decodeIntForKey:       @"DataNC"];
    if (npoints * ncurves == 0) return nil;

    has_exbars  = [coder decodeBoolForKey:      @"DataHasEX"];
    has_eybars  = [coder decodeBoolForKey:      @"DataHasEY"];
    [self decodeDataWithCoder:coder];

    [self findMinMax];

	return self;
}

- (void)setPath:(NSString *)aPath
{
    path = [aPath copy];
}

- (void)allocDataWithNPoints:(int)np nCurves:(int)nc
{
    int		i;

    npoints = np;
    ncurves = nc;

    if (np * nc == 0) {
        x = ex = NULL;
        y = ey = (float **)NULL;
        return;
    }
    x = (float *)malloc(np * sizeof(float));
    ex = (float *)malloc(np * sizeof(float));
    y = (float **)malloc(nc * sizeof(float *));
    ey = (float **)malloc(nc * sizeof(float *));
    for (i = 0; i < nc; i++) {
        y[i] = (float *)malloc(np * sizeof(float));
        ey[i] = (float *)malloc(np * sizeof(float));
    }
}

- (void)deallocData
{
    int	i;

    if (x) {
        free(x);
    }
    if (ex) {
        free(ex);
    }
    if (y) {
        for (i = 0; i < ncurves; i++) {
            if (y[i]) {
                free(y[i]);
            }
        }
        free(y);
    }
    if (ey) {
        for (i = 0; i < ncurves; i++) {
            if (ey[i]) {
                free(ey[i]);
            }
        }
    }
}

- (void)dealloc
{
    [self deallocData];
}

// from the original code ...
/*
 * This code makes the following assumptions:
 * 1. Any data on a line following the character "!" is to be discarded.
 * 2. We can determine the number of curves by looking at the first
 * line of data, which should be of the form
 *  x  y1  y2    ...    yn
 * (possibly separated by commas, with possible trailing comment).
 * 3. Other lines of the file may contain arbitrary text, but contain no
 * numerals or periods (these get interpreted as floating point numbers
 * when the file is scanned); also, anything after a "!" is discarded.
 *
 * It is not easy to make a completely general and bullet-proof scanning
 * routine.  This code is fairly robust and was easy to write.
 */

- (BOOL)readString:(NSString *)inString name:(NSString *)fname xColumn:(int)col
{
    NSString    *str;
	NSArray		*lines;
	NSScanner	*scanner;
	int			i, j;

	BOOL		firstLineFound = NO;
	BOOL		noXData = YES;
	int			ix;
	int			ncolumns = 0;	// nCurves is final number
	float		*xdata, **ydata;
	float		*buf;

    lines = [inString componentsSeparatedByString:@"\n"];
	// Exel puts @"\r" !!!! 
    if ([lines count] < 2) {
		lines = [inString componentsSeparatedByString:@"\r"];
	}

// first pass (find data dim)
	npoints = 0;
	for (i = 0; i < [lines count]; i++) {
		scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
		if (![scanner scanUpToString:@"!" intoString:&str]) continue;
		scanner = [NSScanner scannerWithString:str];

		// look for first line, and count number of curves
		if (!firstLineFound) {
			for (j = 0; ; j++) {
				if (![scanner scanFloat:nil]) break;
			}
			ncolumns = j;
			if (ncolumns == 0) {
				continue;
			} else {
				if (ncolumns == 1) {
					noXData = YES;
					ncurves = 1;
				} else {
					switch (col) {
					case 0 :	// index is x
						ncurves = ncolumns;
						noXData = YES;
						break;
					case 1 :	// 1st column is x
					default :
						ncurves = ncolumns - 1;
						noXData = NO;
						break;
					case 2 :	// 2nd column is x (1st is index)
						ncurves = ncolumns - 2;
						noXData = NO;
						break;
					}
				}
				firstLineFound = YES;
				npoints++;	// line count
			}
		}
		// count lines with valid data points
		for (j = 0; ; j++) {
			if (![scanner scanFloat:nil]) break;
		}
		if (j == ncolumns) {
			npoints++;
		}
	}

// alloc data
	[self allocDataWithNPoints:npoints nCurves:ncurves];
	[self setPath:fname];

// second pass (read data)
	xdata = [self xdata];
	ydata = [self ydata];
    if (ncolumns == 0) return NO;

	buf = (float *)malloc(sizeof(float) * ncolumns);

	ix = 0;
	for (i = 0; i < [lines count]; i++) {
		scanner = [NSScanner scannerWithString:[lines objectAtIndex:i]];
		if (![scanner scanUpToString:@"!" intoString:&str]) continue;
		scanner = [NSScanner scannerWithString:str];
		for (j = 0; ; j++) {
			if (![scanner scanFloat:buf + j]) break;
		}
		if (j != ncolumns) continue;
		if (!noXData) {
			if (col == 1) {
				xdata[ix] = buf[0];
				for (j = 0; j < ncurves; j++) {
					ydata[j][ix] = buf[j+1];
				}
			} else {
				xdata[ix] = buf[1];
				for (j = 0; j < ncurves; j++) {
					ydata[j][ix] = buf[j+2];
				}
			}
		} else {
			xdata[ix] = ix;
			for (j = 0; j < ncurves; j++) {
				ydata[j][ix] = buf[j];
			}
		}
		ix++;
	}
	free(buf);

    return YES;
}

// accessors
- (void)has_exbars:(BOOL)flag
{
    has_exbars = flag;
}

- (void)has_eybars:(BOOL)flag
{
    has_eybars = flag;
}

- (float *)xdata
{
    return x;
}

- (float *)exdata
{
    return ex;
}

- (float **)ydata
{
    return y;
}

- (float **)eydata
{
    return ey;
}

- (NSPoint)datamin
{
    return datamin;
}

- (NSPoint)datamax
{
    return datamax;
}

- (BOOL)has_exbars
{
    return has_exbars;
}
- (BOOL)has_eybars
{
    return has_eybars;
}

- (int)nPoints
{
    return npoints;
}
- (int)nCurves
{
    return ncurves;
}

- (NSString *)path
{
	return path;
}

- (void)findMinMax
{
    int	i, j;

	datamin = NSMakePoint(MAXFLOAT, MAXFLOAT);
	datamax = NSMakePoint(-MAXFLOAT, -MAXFLOAT);

    for (i = 0; i < npoints; i++) {
        datamin.x = MIN(datamin.x, x[i]);
        datamax.x = MAX(datamax.x, x[i]);
    }
    for (i = 0; i < ncurves; i++) {
        for (j = 0; j < npoints; j++) {
            datamin.y = MIN(datamin.y, y[i][j]);
            datamax.y = MAX(datamax.y, y[i][j]);
        }
    }
}

@end
