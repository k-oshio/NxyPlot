//
//	PlotView.m
//

#import "PlotView.h"
#import "PlotAxis.h"
#import "PlotLegend.h"
#import "PlotRange.h"
#import "PlotLineStyle.h"
#import "PlotControl.h"
#import "PlotData.h"
#import "PlotState.h"

@implementation PlotView

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
    if (self == nil) return nil;
    copying = NO;

    xmin = ymin = 0;
    xmax = ymax = 1.0;
    ppxunit = ppyunit = 1.0;
    selectRect = NSZeroRect;
    selectOn = NO;

	return self;
}

- (void)awakeFromNib
{
	NSRect	bbox = [self bounds];
	urCorner = NSMakePoint(bbox.size.width  - XMARGIN, bbox.size.height - YMARGIN);

	legendPos.x = legendPos.y = 0;	// relative to UR corner
	legendRect.size.width = legendRect.size.height = 10;	// empty
}

//
- (void)setPlotState:(PlotState *)state
{
    plot = state;
}

- (void)updatePanel
{
	legendPos = [plot legendPos];
}  

- (void)drawRect:(NSRect)rects
{
	NSAffineTransform	*trans = [NSAffineTransform transform];
	NSRect				bbox = [self bounds];

	printing = ![[NSGraphicsContext currentContext] isDrawingToScreen];
	// clear view even if there is nothing to plot
	[self clear];

	if (control == nil) return;		// not ready
//	if ([control nFiles] == 0) return; // no data -> just draw default frame

	llCorner = NSMakePoint(XOFFSET, YOFFSET);
	urCorner = NSMakePoint(bbox.size.width  - XMARGIN, bbox.size.height - YMARGIN);

// log / linear
	xlog = [range xAxisLog];
	ylog = [range yAxisLog];

// main title, x title, y title
// still in view cood
	[self drawTitles];

// graph coordinates
	[NSGraphicsContext saveGraphicsState];

// get range from PlotRange obj, and update view scale
	[self getRange];

	[trans translateXBy:(llCorner.x - xmin) yBy:(llCorner.y - ymin)];
	[trans concat];

// grid / tick mark / title
	[self drawGraphFrame];

// graph lines / symbols
	NSRectClip(NSMakeRect(xmin, ymin, xmax - xmin, ymax - ymin));
	[self drawLines];
	[self drawSymbols];

	[NSGraphicsContext restoreGraphicsState];

// cursor
    if (selectOn) {
        [[NSColor lightGrayColor] set];
        NSFrameRect(selectRect);    // draw box without anti-aliasing
    }

// legend
	if ([legend legendOn]) {
		[self drawLegends];
	}
}

// get plot range from PlotRange object, and convert it to view coord
- (void)getRange
{
	MinMax	mmx = [range xRange];
	xmin = mmx.min;
	xmax = mmx.max;
	mmx = [range yRange];
	ymin = mmx.min;
	ymax = mmx.max;

	if (xlog) {
		xmax = log10(xmax);
		if (xmin > 0) {
			xmin = log10(xmin);
		} else {
			xmin = xmax - 3.0;
		}
	}
	if (ylog) {
		ymax = log10(ymax);
		if (ymin > 0) {
			ymin = log10(ymin);
		} else {
			ymin = ymax - 3.0;
		}
	}

    if (xmax == xmin) {
        ppxunit = 1.0;
    } else {
        ppxunit = (urCorner.x - llCorner.x) / (xmax - xmin);
    }
    if (ymax == ymin) {
        ppyunit = 1.0;
    } else {
        ppyunit = (urCorner.y - llCorner.y) / (ymax - ymin);
    }

	xmin *= ppxunit; xmax *= ppxunit;
	ymin *= ppyunit; ymax *= ppyunit;
}

- (void)clear
{
	NSColor				*color;
	if ([self printing]) {
		color = [NSColor whiteColor];
	} else {
		color = [axis backgroundColor];
	}
    if (color) {
        [color set];
    //	if ([[NSGraphicsContext currentContext] isDrawingToScreen]) {
        if (![self printing]) {
            NSRectFill([self bounds]);
        }
    }
}

- (void)drawTitles
{
	NSColor				*color;
	NSFont				*font;
	float				fontSize;
	NSString			*str;
	NSDictionary		*attr;
	float				xpos, ypos;
	NSAffineTransform	*trans;

// main title
	font = [plot font];
	fontSize = [font pointSize];
	str = [range mainTitle];
	if ([self printing]) {
		color = [NSColor blackColor];
	} else {
		color = [axis textColor];
	}
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		color,
		NSForegroundColorAttributeName,
		font,
		NSFontAttributeName,
		nil];
	xpos = (urCorner.x + llCorner.x) / 2 - [str sizeWithAttributes:attr].width / 2;
	ypos = urCorner.y + 10;
	[str drawAtPoint:NSMakePoint(xpos, ypos) withAttributes:attr];

// x title
	str = [range xTitle];
	xpos = (urCorner.x + llCorner.x) / 2 - [str sizeWithAttributes:attr].width / 2;
	ypos = llCorner.y - 30 - [str sizeWithAttributes:attr].height;
	[str drawAtPoint:NSMakePoint(xpos, ypos) withAttributes:attr];

// y title
	str = [range yTitle];
	xpos = llCorner.x - 50 - fontSize;
	ypos = (urCorner.y + llCorner.y) / 2 - [str sizeWithAttributes:attr].width / 2;
	// rotate 90
	[NSGraphicsContext saveGraphicsState];
	trans = [NSAffineTransform transform];
	[trans translateXBy:xpos yBy:ypos];	// cumulative for trans
	[trans rotateByDegrees:90.0];		// cumulative for trans
	[trans concat];						// add to context
	[str drawAtPoint:NSMakePoint(0, 0) withAttributes:attr];
	[NSGraphicsContext restoreGraphicsState];

}

- (float)xposForData:(float)d
{
	float	xpos;

	if (xlog) {
		d = fabs(d);
		if (d > 0) {
			xpos = log10(d) * ppxunit;
		} else {
			xpos = 0;
		}
	} else {
		xpos = d * ppxunit;
	}
	return xpos;
}

- (float)yposForData:(float)d
{
	float	ypos;

	if (ylog) {
		d = fabs(d);
		if (d > 0) {
			ypos = log10(d) * ppyunit;
		} else {
			ypos = 0;
		}
	} else {
		ypos = d * ppyunit;
	}
	return ypos;
}

- (void)setLineStyleForPath:(NSBezierPath *)path withCurve:(PlotCurve *)curve
{
	int			lineStyle;
	CGFloat		pattern0[] = {0.0};					// solid
	CGFloat		pattern1[] = {4.0, 4.0}; 			// dash
	CGFloat		pattern2[] = {1.0, 3.0}; 			// dot
	CGFloat		pattern3[] = {7.0, 3.0, 3.0, 3.0};	// chain dash
	CGFloat		pattern4[] = {7.0, 4.0, 1.0, 4.0};	// chain dot
	NSColor		*color;

	lineStyle = [curve lineStyle];

	if ([self printing]) {
		color = [NSColor blackColor];
	} else
    if ([axis colorPlot]) {
        if ([axis backgroundColor]) {
            color = [curve color];
        } else {
            color = [curve color2];
        }
	} else {
        color = [axis textColor];
    }
	[color set];

	switch(lineStyle) {
	case SOLID:
		[path setLineDash:pattern0 count:0 phase:0];
		break;
	case DASH:
		[path setLineDash:pattern1 count:2 phase:0];
		break;
	case DOT:
		[path setLineDash:pattern2 count:2 phase:0];
		break;
	case CHAINDASH:
		[path setLineDash:pattern3 count:4 phase:0];
		break;
	case CHAINDOT:
		[path setLineDash:pattern4 count:4 phase:0];
		break;
	}
}

- (void)drawLines
{
	int				i, j, jj, k;
	float			*x;
	float			**y;
	float			xpos, ypos;
	int				npoints, ncurves;
	int				firstInFile = 0;
	float			thick;
	NSBezierPath	*path;
	PlotData		*data;
	PlotCurve		*curve;

	path = [NSBezierPath bezierPath];
	[path removeAllPoints];
	thick = [curves lineThickness];
	[path setLineWidth:thick];

	// k: file index
	for (k = firstInFile = 0; k < [control nFiles]; k++, firstInFile += ncurves) {
		data = [control data:k];
		x  = [data xdata];
		y  = [data ydata];
		ncurves = [data nCurves];
		npoints = [data nPoints];
		// j: curve index for each file
		// jj: curve index for view
		for (j = 0; j < ncurves; j++) {
			jj = j + firstInFile;
			curve = [curves curveAt:jj];
			[self setLineStyleForPath:path withCurve:curve];

		// plot curves
			if ([curve lineStyle] != NOLINE) {
				[path removeAllPoints];
				xpos = [self xposForData:x[0]];
				ypos = [self yposForData:y[j][0]];
				[path moveToPoint:NSMakePoint(xpos, ypos)];
				for (i = 1; i < npoints; i++) {
					if ((i % 256) == 0) {
						xpos = [self xposForData:x[i-1]];
						ypos = [self yposForData:y[j][i-1]];
						[path stroke];
						[path removeAllPoints];
						[path moveToPoint:NSMakePoint(xpos, ypos)];
					}
					xpos = [self xposForData:x[i]];
					ypos = [self yposForData:y[j][i]];
					[path lineToPoint:NSMakePoint(xpos, ypos)];
				}
				[path stroke];
			}
		}
	}
}

- (void)drawASymbol:(int)symbol at:(NSPoint)pt withSize:(float)size_scale
{
	float			xtmp = pt.x;
	float			ytmp = pt.y;
	float			size;
	float			sqrt3 = sqrt(3.0);
	NSBezierPath	*path = [NSBezierPath bezierPath];

	[path setLineWidth:size_scale/3.0];

	switch(symbol) {
	case CIRCLE:
		size = size_scale * 0.8;
		[path removeAllPoints];
		[path appendBezierPathWithOvalInRect:
			NSMakeRect(xtmp - size, ytmp - size, size * 2, size * 2)];
		[path fill];
		break;
	case XMARK:
		// ref
		size = size_scale * 1.0;
		[path removeAllPoints];
		[path moveToPoint:
			NSMakePoint(xtmp - size, ytmp - size)];
		[path relativeLineToPoint:
			NSMakePoint(size * 2, size * 2)];
		[path moveToPoint:
			NSMakePoint(xtmp  - size, ytmp + size)];
		[path relativeLineToPoint:
			NSMakePoint(size * 2, -size * 2)];
		[path stroke];
		break;
	case UPTRIANGLE:
		size = size_scale * 1.0;
		[path removeAllPoints];
		[path moveToPoint:
			NSMakePoint(xtmp - size, ytmp - size/sqrt3)];
		[path relativeLineToPoint:
			NSMakePoint(size * 2.0, 0.0)];
		[path relativeLineToPoint:
			NSMakePoint(-size, size * sqrt3)];
		[path fill];
		break;
	case DOWNTRIANGLE:
		size = size_scale * 1.0;
		[path removeAllPoints];
		[path moveToPoint:
			NSMakePoint(xtmp - size, ytmp + size/sqrt3)];
		[path relativeLineToPoint:
			NSMakePoint(size * 2.0, 0.0)];
		[path relativeLineToPoint:
			NSMakePoint(-size, -size * sqrt3)];
		[path fill];
		break;
	case DIAMOND:
		size = size_scale * 1.2;
		[path removeAllPoints];
		[path moveToPoint:NSMakePoint(xtmp, ytmp - size)];
		[path relativeLineToPoint:
			NSMakePoint(3.0/4.0*size, size)];
		[path relativeLineToPoint:
			NSMakePoint(-3.0/4.0*size, size)];
		[path relativeLineToPoint:
			NSMakePoint(-3.0/4.0*size, -size)];
		[path closePath];
		[path fill];
		break;
	case SQUARE:
		size = size_scale * 0.8;
		[path removeAllPoints];
		[path appendBezierPathWithRect:
			NSMakeRect(xtmp - size, ytmp - size, 2.0 * size, 2.0 * size)];
		[path fill];
		break;
	case PLUS:
		size = size_scale * 1.2;
		[path removeAllPoints];
		[path moveToPoint:NSMakePoint(xtmp, ytmp - size)];
		[path relativeLineToPoint:NSMakePoint(0.0, 2.0 * size)];
		[path moveToPoint:NSMakePoint(xtmp - size, ytmp)];
		[path relativeLineToPoint:NSMakePoint(2.0 * size, 0.0)];
		[path stroke];
		break;
	}
}

- (void)drawSymbols
{
	int			i, j, jj, k;
	float		size_scale = 4.0;
	float		*x;
	float		**y;
	int			npoints, ncurves;
	int			firstInFile = 0;
	int			symbol;
	float		xtmp, ytmp;
	PlotData	*data;
	PlotCurve	*curve;
	NSColor		*color;

	size_scale = [curves symbolSize];

	for (k = firstInFile = 0; k < [control nFiles]; k++, firstInFile += ncurves) {
		data = [control data:k];
		x = [data xdata];
		y = [data ydata];
		ncurves = [data nCurves];
		npoints = [data nPoints];
		for (j = 0; j < ncurves; j++) {
			jj = j + firstInFile;
			curve = [curves curveAt:jj];
			symbol = [curve symbol];
			if (symbol == NOSYMBOL) continue;
            if ([self printing]) {
                color = [NSColor blackColor];
            } else
            if ([axis colorPlot]) {
                if ([axis backgroundColor]) {
                    color = [curve color];
                } else {
                    color = [curve color2];
                }
            } else {
                color = [axis textColor];
            }
			[color set];
			for (i = 0; i < npoints; i++) {
				xtmp = [self xposForData:x[i]];
				if (xtmp < xmin - size_scale || xtmp > xmax + size_scale) continue;
				ytmp = [self yposForData:y[j][i]];
				if (ytmp < ymin - size_scale || ytmp > ymax + size_scale) continue;
				// draw symbol
				[self drawASymbol:symbol at:NSMakePoint(xtmp, ytmp) withSize:size_scale];
			}
		}
	}
}

- (void)drawVLineAt:(float)xpos width:(float)width dotted:(BOOL)flag
{
	NSPoint			src;
	NSPoint			dst;
	NSBezierPath	*path = [NSBezierPath bezierPath];

	src = NSMakePoint(xpos, ymin);
	dst = NSMakePoint(xpos, ymax);
	[path setLineWidth:width];
	[path setLineCapStyle:NSSquareLineCapStyle];
	if (flag == YES) {
		CGFloat	pattern[] = {1.0, 3.0};
		[path setLineDash:pattern count:2.0 phase:0.0];
	}
	[path moveToPoint:src];
	[path lineToPoint:dst];
	[path stroke];
}

- (void)drawHLineAt:(float)ypos width:(float)width dotted:(BOOL)flag
{
	NSPoint			src;
	NSPoint			dst;
	NSBezierPath	*path = [NSBezierPath bezierPath];

	src = NSMakePoint(xmin, ypos);
	dst = NSMakePoint(xmax, ypos);

	[path setLineWidth:width];
	[path setLineCapStyle:NSSquareLineCapStyle];
	if (flag == YES) {
		CGFloat	pattern[] = {1.0, 3.0};
		[path setLineDash:pattern count:2.0 phase:0.0];
	}
	[path moveToPoint:src];
	[path lineToPoint:dst];
	[path stroke];
}

- (void)drawXTicAt:(float)xpos width:(float)width length:(float)len
{
	NSPoint	src = NSMakePoint(xpos, ymin - len);
	NSPoint dst = NSMakePoint(xpos, ymin);
	[NSBezierPath setDefaultLineWidth:width];
	[NSBezierPath strokeLineFromPoint:src toPoint:dst];
}

- (void)drawYTicAt:(float)ypos width:(float)width length:(float)len
{
	NSPoint	src = NSMakePoint(xmin - len, ypos);
	NSPoint dst = NSMakePoint(xmin, ypos);
	[NSBezierPath setDefaultLineWidth:width];
	[NSBezierPath strokeLineFromPoint:src toPoint:dst];
}

- (void)drawGraphFrame
{
	double			xpos, ypos;
	float			width;
	float			len;
	int				i;
	NSFont			*font;
	float			fontSize;
	NSString		*str;
	NSDictionary	*attr;
	NSColor			*color;
	NSArray			*labelArray;
	PlotLabel		*label;
	float			value;
    int             flag;

	float			frameThickness;
	float			gridThickness;
	float			ticMarkLen;
	BOOL			axisOn;
	BOOL			majorTicMarksOn;
	BOOL			minorTicMarksOn;
	BOOL			gridOn;
	BOOL			gridDotted;
	BOOL			minorGridOn;

// color
	if ([self printing]) {
		color = [NSColor blackColor];
	} else {
		color = [axis textColor];
	}
	[color set];

// font
	font = [plot font];
	fontSize = [font pointSize];

// string attributes
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
			color,
			NSForegroundColorAttributeName,
			font,
			NSFontAttributeName,
			nil];

// flags etc
	axisOn = [axis axisOn];
	frameThickness = [axis frameThickness];
	gridThickness = [axis gridThickness];
	majorTicMarksOn = [axis majorTicMarksOn];
	minorTicMarksOn = [axis minorTicMarksOn];
	ticMarkLen = [axis ticMarkLen];
	gridOn = [axis gridOn];
	minorGridOn = [axis minorGridOn];
	gridDotted = [axis gridDotted];

// frame
	[self drawVLineAt:xmin width:frameThickness dotted:NO];
	[self drawVLineAt:xmax width:frameThickness dotted:NO];
	[self drawHLineAt:ymin width:frameThickness dotted:NO];
	[self drawHLineAt:ymax width:frameThickness dotted:NO];
	
// x axis
	labelArray = [range xLabel];
	for (i = 0; i < [labelArray count]; i++) {
		label = [labelArray objectAtIndex:i];
		value = [label value];
        flag = [label flag];
		if (flag & LABEL_MAJOR) {
			// grid
			if (gridOn && !(axisOn && (flag & LABEL_AXIS)) && !(flag & LABEL_FRAME)) {
				width = [axis gridThickness];
				[self drawVLineAt:[self xposForData:value] width:width dotted:gridDotted];
			}
			// major tick mark
			if (majorTicMarksOn) {
				width = [axis frameThickness];
				[self drawXTicAt:[self xposForData:value] width:width length:ticMarkLen];
			}
			// label
			str = [NSString stringWithFormat:@"%-5g", value];
			xpos = [self xposForData:value] - [str sizeWithAttributes:attr].width / 2 + 7;
			ypos = ymin - fontSize - ticMarkLen - 4;
			[str drawAtPoint:NSMakePoint(xpos, ypos) withAttributes:attr];
		}
		if (flag & LABEL_MINOR) {
			// minor tick mark
			if (majorTicMarksOn && minorTicMarksOn) {
				len = ticMarkLen / 2;
				[self drawXTicAt:[self xposForData:value] width:frameThickness length:len];
			}
            // minor grid
			if (gridOn && minorGridOn && !(flag & LABEL_FRAME)) {
				width = [axis minorGridThickness];
				[self drawVLineAt:[self xposForData:value] width:width dotted:gridDotted];
			}
		}
		// axis
		if (axisOn) {
			if (flag & LABEL_AXIS) {
				[self drawVLineAt:value width:frameThickness dotted:NO];
			}
		}
	}

// y axis
	labelArray = [range yLabel];
	for (i = 0; i < [labelArray count]; i++) {
		label = [labelArray objectAtIndex:i];
		value = [label value];
        flag = [label flag];
		if ((flag & LABEL_MAJOR)) {
			// grid
			if (gridOn && !(axisOn && (flag & LABEL_AXIS)) && !(flag & LABEL_FRAME)) {
				[self drawHLineAt:[self yposForData:value] width:gridThickness dotted:gridDotted];
			}
			// major tick mark
			if (majorTicMarksOn) {
				[self drawYTicAt:[self yposForData:value] width:frameThickness length:ticMarkLen];
			}
			// label
			str = [NSString stringWithFormat:@"%-5g", value];
			ypos = [self yposForData:value] - fontSize / 2 - 1;
			xpos = xmin - [str sizeWithAttributes:attr].width
				- ticMarkLen - 4;
			[str drawAtPoint:NSMakePoint(xpos, ypos) withAttributes:attr];
		}
		if (flag & LABEL_MINOR) {
			// minor tick mark
			if (majorTicMarksOn && minorTicMarksOn) {
				[self drawYTicAt:[self yposForData:value] width:frameThickness length:ticMarkLen / 2];
			}
            // minor grid
			if (gridOn && minorGridOn && !(flag & LABEL_FRAME)) {
				width = [axis minorGridThickness];
				[self drawHLineAt:[self yposForData:value] width:width dotted:gridDotted];
			}
		}
		// axis
		if (axisOn) {
			if (flag & LABEL_AXIS) {
				[self drawHLineAt:value width:frameThickness dotted:NO];
			}
		}
	}
}

- (void)drawLegends
{
	PlotCurve		*curve;
	NSColor			*fColor, *bColor;
	float			thick;
	NSBezierPath	*path = [NSBezierPath bezierPath];
	NSFont			*font = [plot font];
	float			frameThickness = [axis frameThickness];
	float			width;
	float			size_scale;
    float           legendLineLen = [legend legendLineLen];
    float           legendFontHeight = [font boundingRectForFont].size.height;
	double			xpos, ypos;
	int				i, nCurves;
	NSDictionary	*attr;

// legendBox range check
	if (legendPos.x > 0) {
		legendPos.x = 0;
	}
	if (legendPos.y > 0) {
		legendPos.y = 0;
	}
	if (legendPos.x < llCorner.x + legendRect.size.width - urCorner.x) {
		legendPos.x = llCorner.x + legendRect.size.width - urCorner.x;
	}
	if (legendPos.y < llCorner.y + legendRect.size.height - urCorner.y) {
		legendPos.y = llCorner.y + legendRect.size.height - urCorner.y;
	}
// calc legendBox size
	nCurves = [curves nCurves]; 
	attr = [NSDictionary dictionaryWithObjectsAndKeys:
		font, NSFontAttributeName, nil];
	width = 0;
	for (i = 0; i < nCurves; i++) {
		width = MAX(width, [[[curves curveAt:i] legend] sizeWithAttributes:attr].width);
	}
	legendRect.size.width  = width + legendLineLen + 15;
	legendRect.size.height = legendFontHeight * nCurves;

	legendRect.origin.x = urCorner.x + legendPos.x - legendRect.size.width - 10;
	legendRect.origin.y = urCorner.y + legendPos.y - legendRect.size.height - 5;
	
// box
	[path removeAllPoints];
	if ([legend legendBoxOn]) {
		[path setLineWidth:frameThickness];
		if ([self printing]) {
			fColor = [NSColor blackColor];
			bColor = [NSColor whiteColor];
		} else {
			fColor = [axis textColor];
			bColor = [axis backgroundColor];
		}
        [path appendBezierPathWithRect:legendRect];
        if (bColor) {
            if ([legend legendOpaqueBackground]) {
                [bColor set];
                [path fill];
            }
        }
		[fColor set];
		[path stroke];
	}
// legends
	thick = [curves lineThickness];
	[path setLineWidth:thick];
	for (i = 0; i < nCurves; i++) {
		curve = [curves curveAt:i];
        if ([self printing]) {
            fColor = [NSColor blackColor];
        } else
        if ([axis colorPlot]) {
            if ([axis backgroundColor]) {
                fColor = [curve color];
            } else {
                fColor = [curve color2];
            }
        } else {
            fColor = [axis textColor];
        }
		[fColor set];
	// line
		if ([curve lineStyle] != NOLINE) {
			xpos = legendRect.origin.x + 5;
			ypos = legendRect.origin.y + legendRect.size.height - (i + 0.5) * legendFontHeight;
			[path removeAllPoints];
			[path moveToPoint:NSMakePoint(xpos, ypos)];
			xpos = legendRect.origin.x + 2 + legendLineLen;
			[path lineToPoint:NSMakePoint(xpos, ypos)];
			[self setLineStyleForPath:path withCurve:curve];
			[path stroke];
		}
	// symbol
		size_scale = [curves symbolSize];
		xpos = legendRect.origin.x + 5 + legendLineLen / 2.0;
		ypos = legendRect.origin.y + legendRect.size.height - (i + 0.5) * legendFontHeight;
		[self drawASymbol:[curve symbol] at:NSMakePoint(xpos, ypos) withSize:size_scale];
	// legend title
		xpos = legendRect.origin.x + 5 + legendLineLen + 4;
		ypos = legendRect.origin.y + legendRect.size.height - (i + 0.8) * legendFontHeight;
		if ([self printing]) {
			fColor = [NSColor blackColor];
		} else {
			fColor = [axis textColor];
		}
		attr = [NSDictionary dictionaryWithObjectsAndKeys:
			fColor,	NSForegroundColorAttributeName,
			font,	NSFontAttributeName, nil];
		[[legend legendAtIndex:i] drawAtPoint:NSMakePoint(xpos, ypos) withAttributes:attr];
	}
}

// replace for (;;) loop with separate mouseDragged: method
- (void)mouseDown:(NSEvent *)e
{
	NSRect  rect;   // result
	//BOOL	cache_valid = NO;
	BOOL	isInside = YES;
	NSPoint startPoint, currPoint, ofs;
	double	xmin_tmp, xmax_tmp;
	double	ymin_tmp, ymax_tmp;

	// drag select rect
	startPoint = [e locationInWindow];
	startPoint = [self convertPoint:startPoint fromView:nil];

	// if within legend rect, move it
	if (([legend legendOn]) && ([self mouse:startPoint inRect:legendRect])) {
		// move legend box
//		currPoint = startPoint;
		ofs.x = urCorner.x + legendPos.x - startPoint.x;
		ofs.y = urCorner.y + legendPos.y - startPoint.y;
		for (;;) {
			e = [[self window] nextEventMatchingMask:
				NSLeftMouseUpMask | NSLeftMouseDraggedMask];
			if ([e type] == NSLeftMouseUp) break;
			currPoint = [self convertPoint:[e locationInWindow] fromView:nil];
			isInside = [self mouse:currPoint inRect:[self bounds]];
			if (!isInside) continue;
			legendPos.x = currPoint.x + ofs.x - urCorner.x;
			legendPos.y = currPoint.y + ofs.y - urCorner.y;
            [plot setLegendPos:legendPos];    // save to state
			// lockFocus is necessary if outside of drawRect:
			[self lockFocus];
			[self drawLegends];
			[self unlockFocus];
			[self display];
		}
	} else {
		// otherwise, process zoom rect
//		currPoint = startPoint;
		rect = NSMakeRect(startPoint.x, startPoint.y, 0.0, 0.0);
//		[self lockFocus];
//		[[NSColor lightGrayColor] set];

		for (;;) {
			e = [[self window] nextEventMatchingMask:
				NSLeftMouseUpMask | NSLeftMouseDraggedMask];
			if ([e type] == NSLeftMouseUp) break;
			currPoint = [self convertPoint:[e locationInWindow] fromView:nil];

			rect.size.width = fabs(currPoint.x - startPoint.x);
			rect.size.height = fabs(currPoint.y - startPoint.y);
			rect.origin.x = MIN(currPoint.x, startPoint.x);
			rect.origin.y = MIN(currPoint.y, startPoint.y);
			if (rect.size.height == 0 || rect.size.width == 0) continue;

		//	if (cache_valid) {
		//		[[self window] restoreCachedImage];
		//	}
		//	[[self window] cacheImageInRect:[self convertRect:rect toView:nil]];
		//	cache_valid = YES;
		//	NSFrameRect(rect);	// draw box without anti-aliasing
		//	[[self window] flushWindowIfNeeded];
        
            selectOn = YES;
            selectRect = rect;
            [self display];

		}
		// rect selected
//		[self unlockFocus];

        selectOn = NO;
		if ((rect.size.width > 0) && (rect.size.height > 0)) {
			[range pushMinMax];
			[self getRange];

			xmin_tmp = xmin + (rect.origin.x - llCorner.x);
			xmax_tmp = xmin_tmp + rect.size.width;
			ymin_tmp = ymin + (rect.origin.y - llCorner.y);
			ymax_tmp = ymin_tmp + rect.size.height;

			xmin_tmp /= ppxunit; xmax_tmp /= ppxunit;
			ymin_tmp /= ppyunit; ymax_tmp /= ppyunit;

			if (xlog) {
				xmin_tmp = pow(10, xmin_tmp); xmax_tmp = pow(10, xmax_tmp);
			}
			if (ylog) {
				ymin_tmp = pow(10, ymin_tmp); ymax_tmp = pow(10, ymax_tmp);
			}

		// save old min/max -- must adjust if log axis
			[range	niceMinMaxInc:NSMakePoint(xmin_tmp, ymin_tmp) :NSMakePoint(xmax_tmp, ymax_tmp) incOnly:YES];
			[range updateRange];

			[self display];
		}
	}
}

- (BOOL)printing
{
	return (printing && !copying);
}

// first responder
- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)copy:(id)sender
{
	NSPasteboard	*pb;

    copying = YES;
	pb = [NSPasteboard generalPasteboard];	// existing pb is returned
	[pb declareTypes:[NSArray arrayWithObjects:NSPasteboardTypePNG, NSPasteboardTypePDF, nil] owner:self];

	[self writePDFInsideRect:[self bounds] toPasteboard:pb];
    copying = NO;
}

- (void)paste:(id)sender
{
	[control plotFromPasteboard:sender];
}

@end
