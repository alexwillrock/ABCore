#import <Foundation/Foundation.h>

@interface ABAnalytics : NSObject

+ (void)startSessionWithKey:(NSString *)key;
+ (void)appDidEnterBackground;
+ (void)appBecomeActive;
+ (void)appTerminate;
+ (void)openView:(id)sender;
+ (void)closeView:(id)sender;
+ (void)pressButton:(id)sender;
+ (void)pullToRefreshOnView:(Class)classView;
+ (void)logEvent:(NSString *)event;
+ (void)logEvent:(NSString *)event withParameters:(NSDictionary *)dic;

@end