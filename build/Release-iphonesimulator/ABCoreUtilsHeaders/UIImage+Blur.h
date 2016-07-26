//
//  UIImage+Blur.h
//  ABP2P
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (Blur)

- (UIImage*) bluredImageWithCoefficient:(CGFloat)coefficient numberOfIterations:(NSInteger)iterations;

@end
