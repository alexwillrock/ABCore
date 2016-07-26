//
//  UIView+ABKeyboardLayoutAnimation.m
//  MT
//

#import "UIView+ABKeyboardLayoutAnimation.h"
#include <objc/runtime.h>

void handleKeyboardLayoutAnimation(UIView* this, NSNotification* notification, BOOL isShown);

@implementation UIView (ABKeyboardLayoutAnimation)
@dynamic isKeyboardShown_;
@dynamic adjustingConstait_;
@dynamic layoutAdjstmentsBlock_;
@dynamic showCompletion_;
@dynamic hideCompletion_;

- (void)configureKeyboardLayoutAnimationWithAdjustments:(ABKeyboardLayoutAdjstmentBlock)adjustmentsBlock
										 showCompletion:(void (^)(BOOL))showBlock
										 hideCompletion:(void (^)(BOOL))hideBlock
{
    if (adjustmentsBlock) { self.layoutAdjstmentsBlock_ = adjustmentsBlock; }
    if (showBlock)		  { self.showCompletion_		= showBlock; }
    if (hideBlock)		  { self.hideCompletion_		= hideBlock; }
}

- (void)enableKeyboardLayoutAnimation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow_:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide_:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)disableKeyboardLayoutAnimation {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWillShow_:(NSNotification*)notification {
    handleKeyboardLayoutAnimation(self, notification, YES);
}

- (void)keyboardWillHide_:(NSNotification*)notification {
    handleKeyboardLayoutAnimation(self, notification, NO);
}

- (NSLayoutConstraint *)adjustingConstait_ {
    return (NSLayoutConstraint*)objc_getAssociatedObject(self, @selector(adjustingConstait_));
}

- (void)setAdjustingConstait_:(NSLayoutConstraint *)adjustingConstait_ {
    objc_setAssociatedObject(self, @selector(adjustingConstait_), adjustingConstait_, OBJC_ASSOCIATION_ASSIGN);
}

- (ABKeyboardLayoutAdjstmentBlock)layoutAdjstmentsBlock_ {
    return (ABKeyboardLayoutAdjstmentBlock)objc_getAssociatedObject(self, @selector(layoutAdjstmentsBlock_));
}

- (void)setLayoutAdjstmentsBlock_:(ABKeyboardLayoutAdjstmentBlock)keyboardLayoutAdjstmentBlock_ {
    objc_setAssociatedObject(self, @selector(layoutAdjstmentsBlock_), keyboardLayoutAdjstmentBlock_, OBJC_ASSOCIATION_COPY);
}

- (void (^)(BOOL))showCompletion_ {
    return (void (^)(BOOL))objc_getAssociatedObject(self, @selector(showCompletion_));
}

- (void)setShowCompletion_:(void (^)(BOOL))showCompletion_ {
    objc_setAssociatedObject(self, @selector(showCompletion_), showCompletion_, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(BOOL))hideCompletion_ {
    return (void (^)(BOOL))objc_getAssociatedObject(self, @selector(showCompletion_));
}

- (void)setHideCompletion_:(void (^)(BOOL))hideCompletion_ {
    objc_setAssociatedObject(self, @selector(hideCompletion_), hideCompletion_, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)isKeyboardShown_ {
    NSNumber* value = (NSNumber*)objc_getAssociatedObject(self, @selector(isKeyboardShown_));
    return value ? value.boolValue : NO;
}

- (void)setIsKeyboardShown_:(BOOL)isKeyboardShown_ {
    objc_setAssociatedObject(self, @selector(isKeyboardShown_), [NSNumber numberWithBool:isKeyboardShown_], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

void handleKeyboardLayoutAnimation(UIView* this, NSNotification* notification, BOOL willShowKeyboard)
{
    BOOL isKeyboardShown =  this.isKeyboardShown_;
    ABKeyboardLayoutAdjstmentBlock adjustmentsBlock = this.layoutAdjstmentsBlock_;
    if (adjustmentsBlock && ((!isKeyboardShown && willShowKeyboard) || (isKeyboardShown && !willShowKeyboard)))
	{
        if (willShowKeyboard != isKeyboardShown) { this.isKeyboardShown_ = willShowKeyboard; }
        NSDictionary *userInfo = notification.userInfo;
        CGRect keyboardFrame = [(NSNumber*)userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? keyboardFrame.size.height : keyboardFrame.size.width;
        
        adjustmentsBlock(keyboardHeight, willShowKeyboard);
        
        UIViewAnimationOptions options = (UIViewAnimationOptions)[(NSNumber*)userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue] << 16 | UIViewAnimationOptionBeginFromCurrentState;
        double duration = [(NSNumber*)userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            [this.superview layoutIfNeeded];
        } completion:willShowKeyboard ? this.showCompletion_ : this.hideCompletion_];
    }
}