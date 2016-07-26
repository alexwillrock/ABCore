//
//  UIView+ABKeyboardLayoutAnimation.h
//  MT
//

@import UIKit;

typedef void (^ABKeyboardLayoutAdjstmentBlock)(CGFloat keyboardHeight, BOOL willShowKeyboard);

@interface UIView (ABKeyboardLayoutAnimation)
@property (nonatomic, assign) BOOL isKeyboardShown_;
@property (nonatomic, weak) NSLayoutConstraint *adjustingConstait_;
@property (copy) ABKeyboardLayoutAdjstmentBlock layoutAdjstmentsBlock_;
@property (copy) void (^showCompletion_)(BOOL finished);
@property (copy) void (^hideCompletion_)(BOOL finished);

- (void)configureKeyboardLayoutAnimationWithAdjustments:(ABKeyboardLayoutAdjstmentBlock)adjustmentsBlock
										 showCompletion:(void (^)(BOOL))showBlock
										 hideCompletion:(void (^)(BOOL))hideBlock;
- (void)enableKeyboardLayoutAnimation;
- (void)disableKeyboardLayoutAnimation;

@end
