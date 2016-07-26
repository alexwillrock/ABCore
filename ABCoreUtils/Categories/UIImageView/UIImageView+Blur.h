//
//  UIImageView+Blur.h
//  ABP2P
//

#import <UIKit/UIKit.h>
#import "UIImage+Blur.h"



@interface UIImageView (Blur)

@property (nonatomic, readonly) UIImage *originalImage;

-(void)addBlurWithCoefficient:(CGFloat)coefficient;
-(void)addBlurWithCoefficient:(CGFloat)coefficient andImage:(UIImage *)image withCompletion:(void (^)())success; // (0.0;+inf)
-(void)removeBlur;

@end
