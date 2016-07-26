//
//  UIView+FirstResponder.m
//  ABP2PiPhone
//

#import "UIView+FirstResponder.h"

@implementation UIView (FirstResponder)

- (UIView *)findFirstResponder
{
    UIView *firstResponder = nil;
    if ([self isFirstResponder])
	{
        return self;
    }
    for (UIView *subView in [self subviews])
	{
        firstResponder = [subView findFirstResponder];
        if (firstResponder)
        {
            break;
        }
    }
	
    return firstResponder;
}

- (UIViewController *) firstAvailableUIViewController
{
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
	{
        return nextResponder;
    }
	else if ([nextResponder isKindOfClass:[UIView class]])
	{
        return [nextResponder traverseResponderChainForUIViewController];
    } 
	
	return nil;
}

@end
