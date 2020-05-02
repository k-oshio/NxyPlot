//
//	printf like formatter
//

#import <Cocoa/Cocoa.h>

@interface PlotNumberFormatter : NSNumberFormatter
{
	NSString	*formatString;
}

- (void)setFormatString:(NSString *)str;

// overriding super classes
//- (NSString *)stringForObjectValue:(id)obj;
//- (NSNumber *)numberFromString:(NSString *)str;

@end
