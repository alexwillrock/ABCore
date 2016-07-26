//
//  UIView+Layer.h
//  ABiCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

@import UIKit;

@interface UIView (Layer)

@property (nonatomic, copy) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable BOOL maskToBounds;

@end
