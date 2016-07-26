//
//  NSString.h


#import <Foundation/Foundation.h>

@interface NSString (Luhn)

+ (BOOL) luhnCheck:(NSString *)stringToTest;
@end
