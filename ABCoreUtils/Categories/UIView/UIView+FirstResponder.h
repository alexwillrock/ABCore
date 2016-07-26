//
//  UIView+FirstResponder.h
//  ABP2PiPhone
//

#import <UIKit/UIKit.h>

@interface UIView (FirstResponder)

- (UIView *)findFirstResponder;
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;

@end
