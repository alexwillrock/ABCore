//
//  NSString+HTML.h


#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)stringByStrippingLiteHTMLEscapes;
- (NSString *)stringByStrippingHTMLEscapes;
- (NSString *)stringFromHTML;
- (NSString *)stringWithPreparedNewLineChars;

@end
