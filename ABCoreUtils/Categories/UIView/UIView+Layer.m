//
//  UIView+Layer.m
//  ABiCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "UIView+Layer.h"

@implementation UIView (Layer)

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (BOOL)maskToBounds {
    return self.layer.masksToBounds;
}

- (void)setMaskToBounds:(BOOL)maskToBounds {
    self.layer.masksToBounds = maskToBounds;
}

@end
