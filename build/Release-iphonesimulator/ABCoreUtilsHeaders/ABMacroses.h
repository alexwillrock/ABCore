///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Logging & Assert

#ifdef DEBUG
	#define DEBUG_LOG
#endif

#ifdef ALog
#	undef ALog
#endif
#ifdef DLog
#	undef DLog
#endif

#ifdef DEBUG

#define DLog( s, ... )								NSLog( @"%@%s:(%d)> %@", [[self class] description], __FUNCTION__ , __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ALog( s, ... )								[[[UIAlertView alloc]initWithTitle:@"Error!" message:[NSString stringWithFormat:(s), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];\
													DLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__]);
#define DAssert(A, B, ...)							NSAssert(A, B, ##__VA_ARGS__);

#else

#define ALog( s, ... )
#define DLog( s, ... )
#define DAssert(...)

#endif


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Color conversion

#define COLOR_RGB(r, g, b)							[UIColor colorWithRed:(float)r/256.0 green:(float)g/256.0 blue:(float)b/256.0 alpha:1.0f]
#define COLOR_RGBA(r, g, b, a)						[UIColor colorWithRed:(float)r/256.0 green:(float)g/256.0 blue:(float)b/256.0 alpha:(float)a]


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Localization

#define LOC(key)									NSLocalizedString(key, @"")


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Screen

#define screnBounds									[[UIScreen mainScreen] bounds]
#define screnBoundsWidth							[[UIScreen mainScreen] bounds].size.width
#define screnBoundsHeight							[[UIScreen mainScreen] bounds].size.height
#define statusBarFrame								[[UIApplication sharedApplication] statusBarFrame]



///////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark SINGLETON_GCD

#define SINGLETON_GCD(classname)\
+ (id)sharedInstance\
{\
static dispatch_once_t pred = 0;\
__strong static id _sharedObject##classname = nil;\
dispatch_once(&pred,\
^{\
_sharedObject##classname = [[self alloc] init];\
});\
return _sharedObject##classname;\
}\
