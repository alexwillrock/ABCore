#import "ABAnalytics.h"
#import "Flurry.h"
#import "FlurryCommonEvents.h"
#import "AppsFlyerTracker.h"
#import "UIView+FirstResponder.h"
//#import <ABCoreUtils/ABUtils.h>
#import <ABUtils.h>
@implementation ABAnalytics


#define kTimeIntervalAfterAppActive @"_timeIntervalAfterAppActive"

+ (void)startSessionWithKey:(NSString *)key
{
	[Flurry startSession:key];
}

+ (void)appDidEnterBackground
{
    NSTimeInterval timeIntervalAfterAppActive = [[NSUserDefaults standardUserDefaults] doubleForKey:kTimeIntervalAfterAppActive];
	NSString * workingTime = [NSString stringWithFormat:@"%.0f",([[NSDate date] timeIntervalSince1970] - timeIntervalAfterAppActive)];
    NSDictionary * parameters = @{ @"working time" : workingTime};

	[Flurry logEvent:kFlurryEventAppEnterBackground withParameters:parameters];
}

+ (void)appBecomeActive
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)([[NSDate date] timeIntervalSince1970] + 0.5)
											   forKey:kTimeIntervalAfterAppActive];

    [[NSUserDefaults standardUserDefaults] synchronize];
	NSDateFormatter * formatter = [ABUtils dateFormatter];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	[formatter setTimeStyle:NSDateFormatterLongStyle];

	NSString * activateTimeString = [formatter stringFromDate:[NSDate date]];

    NSDictionary * parameters = @{ @"activate time" : activateTimeString };

	[Flurry logEvent:kFlurryEventAppBecomeActive withParameters: parameters];
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
}

+ (void)appTerminate
{
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger)([[NSDate date] timeIntervalSince1970] + 0.5) forKey:kTimeIntervalAfterAppActive];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)openView:(id)sender
{
	NSDictionary * parameters = @{ kFlurryParamViewName : [[sender class] description]};

	[Flurry logEvent:kFlurryEventViewOpen
	  withParameters:parameters
			   timed:YES];
}

+ (void)closeView:(id)sender
{
	NSDictionary * parameters = @{ kFlurryParamViewName : [[sender class] description]};
	[Flurry endTimedEvent:kFlurryEventViewOpen
		   withParameters:parameters];
}

+ (void)pressButton:(id)sender
{
    NSString * buttonName = [(UIButton *)sender titleLabel].text;
    NSString * parentVC = [[[(UIButton *)sender firstAvailableUIViewController] class] description];
    
    if (buttonName.length == 0 || buttonName == nil)
        buttonName = @"UNKNOWN";
    
    if (parentVC.length == 0 || parentVC == nil)
        parentVC = @"UNKNOWN";

	NSDictionary * parameters = @{kFlurryParamButtonName :buttonName,
								  kFlurryParamViewName : parentVC
								  };

	[Flurry logEvent:kFlurryEventButtonClick
	  withParameters:parameters];
}

+ (void)pullToRefreshOnView:(Class)sender
{
	NSDictionary * parameters = @{kFlurryParamViewName : [[sender class] description]};

	[Flurry logEvent:kFlurryEventPullToRefresh
	  withParameters:parameters];
}

+ (void)logEvent:(NSString *)event
{
	[Flurry logEvent:event];
    [[AppsFlyerTracker sharedTracker] trackEvent:event withValue:nil];
}

+ (void)logEvent:(NSString *)event withParameters:(NSDictionary *)dic
{
	[Flurry logEvent:event withParameters:dic];
//    [[AppsFlyerTracker sharedTracker] trackEvent:event withValue:dic];
}

@end
