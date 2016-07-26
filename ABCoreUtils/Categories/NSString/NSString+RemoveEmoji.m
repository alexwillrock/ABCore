//
//  NSString+RemoveEmoji.m
//

#import "NSString+RemoveEmoji.h"

@implementation NSString (RemoveEmoji)

- (NSString*)removeEmoji
{
    __block NSMutableString* temp = [NSMutableString string];

    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         NSMutableString *mutableSubstring = [NSMutableString stringWithString:substring];
         
         NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                       @"1⃣|2⃣|3⃣|4⃣|5⃣|6⃣|7⃣|8⃣|9⃣|0⃣|#⃣" options:0 error:nil];
         [regex replaceMatchesInString:mutableSubstring options:0 range:NSMakeRange(0, [mutableSubstring length]) withTemplate:@""];
         
         if (mutableSubstring.length == 0)
         {
             [temp appendString:@""];
             return ;
         }

         const unichar hs = [substring characterAtIndex: 0];
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             const unichar ls = [substring characterAtIndex: 1];
             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;

             [temp appendString: (0x1d000 <= uc && uc <= 0x1f77f)? @"": substring]; // U+1D000-1F77F

			 // non surrogate
         } else {
             [temp appendString: [self stringContainsEmoji:hs] ? @"": substring]; // U+2100-26FF
         }
     }];

    return temp;
}

- (BOOL)stringContainsEmoji:(unichar)hs
{
    if (0x2000 <= hs && hs <= 0x27ff)
    {
        return YES;
    }
    else if (0x2B05 <= hs && hs <= 0x2b07)
    {
        return YES;
    }
    else if (0x2934 <= hs && hs <= 0x2935)
    {
        return YES;
    }
    else if (0x3297 <= hs && hs <= 0x3299)
    {
        return YES;
    }
    else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
        return YES;
    }
    
    return NO;
}

@end
