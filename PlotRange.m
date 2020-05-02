//
//	PlotRange.m
//

#import "PlotRange.h"
#import "PlotControl.h"
#import "PlotView.h"
#import "PlotNumberFormatter.h"
#import "PlotState.h"

int
topDigit(double val)
{
	float	a;
	int		ia, top;

	a = log10(val);
	ia = floor(a);
	a -= ia;
	top = pow(10, a);

	return top;
}

int
orderOfMag(double val)
{
	int		mag;
	double	a;

	a = log10(val);
	mag = floor(a);
	return mag;
}

//
// Compute nice increment for linear plotting, given min and max
//
void
computeNiceLinInc(double *pmin, double *pmax, double *pinc, int *ntic)
{
    float   fmin = *pmin, fmax = *pmax, finc = (fmax - fmin) / 6.0, x;
	int		iinc, base;
    int     n;

    if (finc <= 0.0) {
        fmin = (fmin > 0.0 ? 0.9 * fmin : 1.1 * fmin);
        fmax = (fmax > 0.0 ? 1.1 * fmax : 0.9 * fmax);
        finc = (fmax - fmin) / 5.0;
        if (finc < 0.0) {
            *pmin = 0.0;
            *pmax = 1.0;
            *pinc = 0.2;
			*ntic = 5;
            return;
        }
    }

	// base 2 & 360
	base = 0;
	if (fmin >= 0 && fmin < 10) {
		iinc = ceil((fmax - fmin) / 4);
		switch (iinc) {
		// 2^n
		case 16 :
		case 32 :
		case 64 :
		case 128 :
		case 256 :
			base = 2;
			*ntic = 4;
			break;
		// 360
		case 87 :
		case 88 :
		case 89 :
		case 90 :
			base = 90;
			iinc = 90;
			*ntic = 6;	// 15deg increment
			break;
		default :
			break;
		}
	}
	if (base > 0) {
		*pmin = 0;
		*pmax = iinc * 4;
		*pinc = iinc;
		return;
	}

	// base 10
	n = orderOfMag(finc);
	x = finc * pow(10, -n);
	iinc = 1;
	if (x > 1) iinc = 2;
	if (x > 2) iinc = 5;
	if (x > 5) iinc = 10;
	switch (iinc) {
	case 1 :
	case 5 :
	default :
		*ntic = 5;
		break;
	case 2 :
		*ntic = 4;
		break;
	}
	finc = iinc * pow(10, n);

	fmin = ((int)(fmin / finc - 1)) * finc;
//	fmin = ((int)(fmin / finc)) * finc;
	fmax = ((int)(fmax / finc + 1)) * finc;

    *pmin = fmin;
    *pmax = fmax;
    *pinc = finc;
}

//
// Compute a nice min and max for logarithmic plotting(pow 10 only)
//
void
computeNiceLogInc(double *pmin, double *pmax, double *pinc, int *ntic)
{
    double	fmin, fmax, finc;
	int		range, nt;

    fmax = log10(*pmax);
	fmin = log10(*pmin);

    fmax = ceil(fmax);
    fmin = floor(fmin);

    if (fmin == fmax) {
        fmax = fmax + 1.0;
//		finc = 1.0;
    }
	finc = 1.0;
	range = fmax - fmin;
	nt = 20;
	if (range > 1) {
		nt = 10;
	}
	if (range > 6) {
		nt = 5;
	}
	if (range > 8) {
		nt = 2;
	}
	if (range > 12) {
		nt = 1;
	}
	*pmin = pow(10, fmin);
	*pmax = pow(10, fmax);
	*pinc = pow(10, finc);
	*ntic = nt;
}

// ==================================================
@implementation PlotLabel

@synthesize flag;
@synthesize value;

+ (PlotLabel *)label
{
	PlotLabel *label;
	label = [[PlotLabel alloc] init];
	return label;
}

- (id)init
{
    self = [super init];
    if (self == nil) return nil;
    value = 0;
    flag = 0;
    return self;
}

@end

// ==================================================
@implementation PlotRange

- init
{
	self = [super init];
    if (self == nil) return nil;
	oldXRange = (MinMax){0, 1, 0.2};
	oldYRange = (MinMax){0, 1, 0.2};

	xLabel = nil;
	yLabel = nil;

    return self;
}

- (void)setPlotState:(PlotState *)state
{
    plot = state;
}

- (void)awakeFromNib
{
	PlotNumberFormatter *formatter = [[PlotNumberFormatter alloc] init];
	[formatter setFormatString:@"%-5g"];

	[xMinField setFormatter:formatter];
	[xMaxField setFormatter:formatter];
	[xIncField setFormatter:formatter];
	[yMinField setFormatter:formatter];
	[yMaxField setFormatter:formatter];
	[yIncField setFormatter:formatter];

	[xNticField setFormatter:formatter];
	[yNticField setFormatter:formatter];

	[fontSizeStepper setMinValue:8];
	[fontSizeStepper setMaxValue:24];
	[fontSizeStepper setIncrement:1];

    [self updateRange];
}

- (void)updateRange
{
	if ([self xAxisLog]) {
		xLabel = [self makeLogLabelWithRange:[self xRange] ntic:[self xntic]];
	} else {
		xLabel = [self makeLinLabelWithRange:[self xRange] ntic:[self xntic]];
	}
	if ([self yAxisLog]) {
		yLabel = [self makeLogLabelWithRange:[self yRange] ntic:[self yntic]];
	} else {
		yLabel = [self makeLinLabelWithRange:[self yRange] ntic:[self yntic]];
	}
}

// update UI according to state
- (void)updatePanel
{
    [xLogButton setState:[plot xLog]];
    [yLogButton setState:[plot yLog]];
    [self setXRange:[plot xRange]];
    [self setYRange:[plot yRange]];
    [mainTitleField setStringValue:[plot mainTitle]];
    [self updateRange];

    [xTitleField    setStringValue:[plot xTitle]];
    [yTitleField    setStringValue:[plot yTitle]];
    [fontSizeText       setFloatValue:[plot fontSize]];
    [fontSizeStepper    setFloatValue:[plot fontSize]];
//    [self setFont];
    [xAxisColumn selectItemAtIndex:[plot xColumn]];

    [widthField         setFloatValue:[plot windowSize].width];
    [heightField        setFloatValue:[plot windowSize].height];
//    [control changeWindowSizeTo:[plot windowSize]];
}

- (BOOL)xAxisLog
{
    return ([xLogButton state] == NSOnState);
}

- (BOOL)yAxisLog
{
    return ([yLogButton state] == NSOnState);
}

- (MinMax)xRange
{
    return [plot xRange];
}

- (int)xntic
{
	return [xNticField intValue];
}

- (MinMax)yRange
{
    return [plot yRange];
}

- (int)yntic
{
	return [yNticField intValue];
}

- (void)setXRange:(MinMax)mmx
{
    [xMinField setDoubleValue:mmx.min];
    [xMaxField setDoubleValue:mmx.max];
    [xIncField setDoubleValue:mmx.inc];
    [plot setXRange:mmx];
}

- (void)setXntic:(int)val
{
	[xNticField setIntValue:val];
}

- (void)setYRange:(MinMax)mmx
{
    [yMinField setDoubleValue:mmx.min];
    [yMaxField setDoubleValue:mmx.max];
    [yIncField setDoubleValue:mmx.inc];
    [plot setYRange:mmx];
}

- (void)setYntic:(int)val
{
	[yNticField setIntValue:val];
}

- (void)rangeChanged:(id)sender
{
	MinMax		mmx;
	mmx.min = [xMinField doubleValue];
	mmx.max = [xMaxField doubleValue];
	mmx.inc = [xIncField doubleValue];
    [plot setXRange:mmx];

	mmx.min = [yMinField doubleValue];
	mmx.max = [yMaxField doubleValue];
	mmx.inc = [yIncField doubleValue];
    [plot setYRange:mmx];

	[self updateRange];
	[canvas display];
}

- (IBAction)logChanged:(id)sender
{
    [plot setXLog:[self xAxisLog]];
    [plot setYLog:[self yAxisLog]];
	[control autoScale:self];
}

// get pleasing values for the min, max, and increments
// if incOnly is YES, only inc is changed
// otherwise, min/max/inc values are changed
- (void)niceMinMaxInc:(NSPoint)dataMin :(NSPoint)dataMax incOnly:(BOOL)incOnly
{
    double	fmin, fmax, finc;
	MinMax	mmx;
	int		ntic;

// x
    fmin = dataMin.x;
    fmax = dataMax.x;
	if ([self xAxisLog]) {
		fmin = fabs(fmin);
	}

    if ([self xAxisLog] ) {
        computeNiceLogInc(&fmin, &fmax, &finc, &ntic);
    } else {
        computeNiceLinInc(&fmin, &fmax, &finc, &ntic);
    }
	if (incOnly) {
		mmx.min = dataMin.x;
		mmx.max = dataMax.x;
	} else {
		mmx.min = fmin;
		mmx.max = fmax;
	}
	mmx.inc = finc;
	[self setXRange:mmx];
	[self setXntic:ntic];

// y
    fmin = dataMin.y;
    fmax = dataMax.y;
	if ([self yAxisLog]) {
		fmin = fabs(fmin);
	}

    if ([self yAxisLog] ) {
        computeNiceLogInc(&fmin, &fmax, &finc, &ntic);
    }
    else {
        computeNiceLinInc(&fmin, &fmax, &finc, &ntic);
    }
	if (incOnly) {
		mmx.min = dataMin.y;
		mmx.max = dataMax.y;
	} else {
		mmx.min = fmin;
		mmx.max = fmax;
	}
	mmx.inc = finc;
	[self setYRange:mmx];
	[self setYntic:ntic];
}

- (void)pushMinMax
{
    oldXRange = [plot xRange];
    oldYRange = [plot yRange];
}

- (void)popMinMax       // swap current and stack
{
    MinMax		tmp;

    tmp = oldXRange;
	oldXRange = [plot xRange];
    [self setXRange:tmp];   // state is updated, too

    tmp = oldYRange;
	oldYRange = [plot yRange];
    [self setYRange:tmp];   // state is updated, too
}

#define apprx_eq(a, b) (fabs(((a) - (b))/(mmx.max - mmx.min)) < eps)

- (NSArray *)makeLinLabelWithRange:(MinMax)mmx ntic:(int)ntic
{
	PlotLabel		*label;
	int				i, ix, st, n;
	double			minc = mmx.inc / ntic;
	double			val;
    double          eps = 1e-4;
	int				flag = 0;
	NSMutableArray	*tmpArray = [NSMutableArray array];

// new implementation (linear)
	st = ceil(mmx.min / minc);
	n = (mmx.max - mmx.min) / minc;
	if (apprx_eq(st * minc - mmx.min, 0)) {	// if max is label position
		n++;
	}
	for (i = 0; i < n; i++) {
		ix = st + i;
		label = [PlotLabel label];
		val = ix * minc;
		flag = 0;
        if (apprx_eq(val, mmx.min) || apprx_eq(val, mmx.max)) {
            flag |= LABEL_FRAME;
        }
		if (ix == 0) {
			flag |= LABEL_AXIS;
			val = 0;
		}
		if (ix % ntic == 0) {
			flag |= LABEL_MAJOR;
		} else {
			flag |= LABEL_MINOR;
		}
		[label setValue:val];
		[label setFlag:flag];
		[tmpArray addObject:label];
	}
	return [NSArray arrayWithArray:tmpArray];
}

// "Range" should be globalMin/Max
- (NSArray *)makeLogLabelWithRange:(MinMax)mmx ntic:(int)ntic
{
	PlotLabel		*label;
	int				i, j;
	int				ix, st, n;
	double			fmin, fmax;
	double			minc;
	double			val, majv;
	int				flag = 0;
	NSMutableArray	*tmpArray = [NSMutableArray array];

	fmin = mmx.min;
	fmax = mmx.max;
	st = floor(log10(fmin));
	n = (log10(fmax) - st) + 1;
	for (i = 0; i < n; i++) {
		ix = st + i;
		majv = pow(10.0, (double)ix);
		minc = 10.0 / ntic * majv;
		for (j = 1; j < ntic; j++) {
			flag = 0;
			if (j == 1) {
				flag |= LABEL_MAJOR;
			} else {
				flag |= LABEL_MINOR;
			}
			val = j * minc;
			if ((val >= fmin) && (val <= fmax)) {
				label = [PlotLabel label];
				[label setValue:val];
				[label setFlag:flag];
				[tmpArray addObject:label];
			}
		}
	}
	return [NSArray arrayWithArray:tmpArray];
}

- (NSArray *)xLabel
{
	return xLabel;
}

- (NSArray *)yLabel
{
	return yLabel;
}

// title text
- (NSString *)mainTitle
{
    NSString    *str = [mainTitleField stringValue];
    [plot setMainTitle:str];
    return str;
}

- (NSString *)xTitle
{
    NSString    *str = [xTitleField stringValue];
    [plot setXTitle:str];
    return str;
}

- (NSString *)yTitle
{
    NSString    *str = [yTitleField stringValue];
    [plot setYTitle:str];
    return str;
}

- (void)setMainTitle:(NSString *)str
{
    [mainTitleField setStringValue:str];
}

- (void)setXTitle:(NSString *)str
{
    [xTitleField setStringValue:str];
}

- (void)setYTitle:(NSString *)str
{
    [yTitleField setStringValue:str];
}

- (void)fontSizeChanged:(id)sender
{
    float   fontSize = [sender floatValue];
	if (sender == fontSizeStepper) {
		[fontSizeText setFloatValue:fontSize];
	}
    [plot changeFontSizeTo:fontSize];
	[canvas display];
}

//- (void)setFont
//{
//    font = [NSFont fontWithName:@"Helvetica" size:[plot fontSize]];
//}

//- (NSFont *)font
//{
//	return font;
//}

- (int)xColumn
{
    int xc = [xAxisColumn indexOfSelectedItem];
    [plot setXColumn:xc];
    return xc;
}

- (void)setWindowSize:(NSSize)sz
{
    [widthField  setFloatValue:sz.width];
    [heightField setFloatValue:sz.height];
    [plot setWindowSize:sz];
}

- (IBAction)windowSizeChanged:(id)sender
{
    NSWindow    *win = [canvas window];
    NSSize      sz;
    NSRect      fr = [win frame];
    sz.width  = [widthField floatValue];
    sz.height = [heightField floatValue];
    fr.size = sz;
    [control changeWindowSizeTo:sz];
    [plot setWindowSize:sz];
}

@end
