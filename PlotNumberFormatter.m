//
//	simple printf like formatter
//

#import "PlotNumberFormatter.h"

@implementation PlotNumberFormatter

//	NSString	*formatString;

- (id)init
{
	self = [super init];
    if (self == nil) return nil;
	formatString = @"%g";
	return self;
}

- (void)setFormatString:(NSString *)str
{
	if (formatString && (str != formatString)) {
		formatString = str;
	}
}

- (NSString *)stringForObjectValue:(id)obj
{
	return [NSString stringWithFormat:formatString, [obj doubleValue]];
}

- (BOOL)getObjectValue:(id *)obj forString:(NSString *)string errorDescription:(NSString  **)error
{
	double		doubleResult;
    NSScanner	*scanner;
    BOOL		returnValue = NO;

    scanner = [NSScanner scannerWithString: string];
    [scanner scanString: @"$" intoString: NULL];
    if ([scanner scanDouble:&doubleResult] && ([scanner isAtEnd])) {
        returnValue = YES;
        if (obj) *obj = [NSNumber numberWithDouble:doubleResult];
    } else {
        if (error) *error = NSLocalizedString(@"Couldn’t convert  to float", @"Error converting");
    }
    return returnValue;
}

- (NSNumber *)numberFromString:(NSString *)str	// this is not used
{
//printf("numberFromString:%s\n", [str UTF8String]);
	return [NSNumber numberWithDouble:[str doubleValue]];
}

- (NSNumberFormatterBehavior)formatterBehavior
{
	return NSNumberFormatterBehavior10_4;
}

@end

