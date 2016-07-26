//
//  UIImageView+Blur.m
//  ABP2P

#import "UIImageView+Blur.h"
#import <objc/runtime.h>

#define kOriginalImage @"originalImage"

@implementation UIImageView (Blur)

@dynamic originalImage;


-(void)setOriginalImage:(UIImage *)originalImage
{
	objc_setAssociatedObject(self, kOriginalImage, originalImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage *)originalImage
{
	return objc_getAssociatedObject(self, kOriginalImage);
}

-(void)addBlurWithCoefficient:(CGFloat)coefficient
{
	[self addBlurWithCoefficient:coefficient andImage:[self image] withCompletion:^{
        ;
    }];
}

-(void)addBlurWithCoefficient:(CGFloat)coefficient andImage:(UIImage *)image withCompletion:(void (^)())success
{
	if ([self originalImage] == nil)
	{
		self.originalImage = [UIImage imageWithCGImage:image.CGImage];
	}
	
	if (coefficient == 0.0f)
	{
		[self removeBlur];
	}
	else
	{
        __weak __typeof(self) weakSelf = self;
        __weak UIImage *weakImage = image;
        
		dispatch_queue_t processQueue = dispatch_queue_create("com.p2p.imageProcessing", NULL);
		dispatch_async(processQueue, ^
	    {
            __typeof(self) strongSelf = weakSelf;
            if (strongSelf)
            {
                UIImage* strongImage = weakImage;
                __block UIImage *filteredImage = [strongImage bluredImageWithCoefficient:coefficient numberOfIterations:5];
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   __typeof(self) subStrongSelf = strongSelf;
                                   [subStrongSelf setImage:filteredImage];
                                   success();
                               });
            }
	    });
	}
}

-(void)removeBlur
{
	[self setImage:[self originalImage]];
}

@end
