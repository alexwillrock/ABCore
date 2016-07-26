//
//  UIButton+ABMBHitAreaInsets.m
//  ABMBiPhone
//

#import "UIButton+ABHitAreaInsets.h"
#import <objc/runtime.h>

@implementation UIButton (ABMBHitAreaInsets)

@dynamic hitAreaEdgeInsets;

static const NSString *keyHitEdgeInsets = @"HitAreaEdgeInsets";

- (void)setHitAreaEdgeInsets:(UIEdgeInsets)hitAreaEdgeInsets
{
    NSValue *value = [NSValue value:&hitAreaEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &keyHitEdgeInsets, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitAreaEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &keyHitEdgeInsets);
    if(value)
    {
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [value getValue:&edgeInsets];
        return edgeInsets;
    }
    else
    {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(UIEdgeInsetsEqualToEdgeInsets(self.hitAreaEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden)
    {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitAreaEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
