

#import "ABUtils.h"

#import <UIKit/UIKit.h>
#import "OpenUDID.h"
#import <AddressBook/AddressBook.h>
#import "NSData+Base64.h"
#import <sys/utsname.h>
#import "UIImage+CS_Extensions.h"
#import "NSString+RemoveEmoji.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+Luhn.h"
#import <CommonCrypto/CommonHMAC.h>


//
//#define kUserRegionKey @"userRegionKey"
//
#define kFacebookDomain @"facebook.com"
#define kVKDomain @"vk.com"
#define kFBDomain @"Domain"



NSString *const ABErrorDomain = @"com.temaslizhik.common";



	// Color utility functions
inline UIColor *ABColorFromIntWithAlpha(unsigned int rgbValue, CGFloat alpha)
{
	return [UIColor colorWithRed:((CGFloat)((rgbValue & 0xFF0000) >> 16))/(CGFloat)255.0
						   green:((CGFloat)((rgbValue & 0xFF00)	  >> 8)) /(CGFloat)255.0
							blue:((CGFloat) (rgbValue & 0xFF))			 /(CGFloat)255.0
						   alpha:alpha];
}

inline UIColor *ABColorFromInt(unsigned int rgbValue) {
	return ABColorFromIntWithAlpha(rgbValue, 1.f);
}

inline UIColor *ABColorFromIntGrey(unsigned int greyHex) {
	if (greyHex > 0xFF) { NSLog(@"WARNING: Trying to get grey color with too big HEX value %d, Maybe is supposed to use ABColorFromInt", greyHex); };
	return [UIColor colorWithWhite:greyHex/255.f alpha:1.f];
}




@implementation ABUtils

#pragma mark --------------------
#pragma mark Crossproject methods
#pragma mark --------------------

#pragma mark - App Version

+ (NSString *)appVersionString
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)buildNumberString
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appVersionAndBuildNumberString
{
	return [NSString stringWithFormat:@"%@(%@)",[ABUtils appVersionString], [ABUtils buildNumberString]];
}

#pragma mark -  Device info

+ (NSString *)deviceModel
{
	return [UIDevice currentDevice].model;
}

+ (NSString *)deviceOS
{
	return [UIDevice currentDevice].systemVersion;
}

+ (NSString*)deviceModelName
{
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    
//    NSDictionary *commonNamesDictionary =
//    @{
//      @"i386":     @"iPhone Simulator",
//      @"x86_64":   @"iPad Simulator",
//      
//      @"iPhone1,1":    @"iPhone",
//      @"iPhone1,2":    @"iPhone 3G",
//      @"iPhone2,1":    @"iPhone 3GS",
//      @"iPhone3,1":    @"iPhone 4",
//      @"iPhone3,2":    @"iPhone 4(Rev A)",
//      @"iPhone3,3":    @"iPhone 4(CDMA)",
//      @"iPhone4,1":    @"iPhone 4S",
//      @"iPhone5,1":    @"iPhone 5(GSM)",
//      @"iPhone5,2":    @"iPhone 5(GSM+CDMA)",
//      @"iPhone5,3":    @"iPhone 5c(GSM)",
//      @"iPhone5,4":    @"iPhone 5c(GSM+CDMA)",
//      @"iPhone6,1":    @"iPhone 5s(GSM)",
//      @"iPhone6,2":    @"iPhone 5s(GSM+CDMA)",
//      
//      @"iPad1,1":  @"iPad",
//      @"iPad2,1":  @"iPad 2(WiFi)",
//      @"iPad2,2":  @"iPad 2(GSM)",
//      @"iPad2,3":  @"iPad 2(CDMA)",
//      @"iPad2,4":  @"iPad 2(WiFi Rev A)",
//      @"iPad2,5":  @"iPad Mini(WiFi)",
//      @"iPad2,6":  @"iPad Mini(GSM)",
//      @"iPad2,7":  @"iPad Mini(GSM+CDMA)",
//      @"iPad3,1":  @"iPad 3(WiFi)",
//      @"iPad3,2":  @"iPad 3(GSM+CDMA)",
//      @"iPad3,3":  @"iPad 3(GSM)",
//      @"iPad3,4":  @"iPad 4(WiFi)",
//      @"iPad3,5":  @"iPad 4(GSM)",
//      @"iPad3,6":  @"iPad 4(GSM+CDMA)",
//      
//      @"iPod1,1":  @"iPod 1st Gen",
//      @"iPod2,1":  @"iPod 2nd Gen",
//      @"iPod3,1":  @"iPod 3rd Gen",
//      @"iPod4,1":  @"iPod 4th Gen",
//      @"iPod5,1":  @"iPod 5th Gen",
//      
//      };
    
//    NSString *deviceName = commonNamesDictionary[machineName];
//    
//    if (deviceName == nil) {
//        deviceName = machineName;
//    }
    
    return machineName;
}

+ (NSString*) deviceId
{	
	return [OpenUDID value];
}

+ (NSString *)platform
{
	return @"ios";
}
	
+ (NSString *)screenResolution
{
//разрешение экрана - mdpi, hdpi, xhdpi (для ios: mdpi это обычное, а xhdpi это retina)
	if ([self retina])
		return @"xhdpi";

	return @"mdpi";
}

+ (NSString *)bundleAdditionalIdentifier
{
	return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"BUNDLE_ADDITIONAL_IDENTIFIER"];
}

+ (NSString *)dpi
{
	if ([ABUtils retina])
		return @"dpi=l";
	
	return @"dpi=m";
}

+ (NSString *)screenSize
{
//размер экрана - бывает small, medium, large, xlarge - в ios 2.0 всем нужно подставлять large
	return @"large";
}

+ (CGFloat)fourInchesScreenHeight
{
    return 480.0f;
}

+ (NSString *)rootCheck
{
	BOOL rooted = NO;
	NSArray *jailbrokenPath = [NSArray arrayWithObjects:
							   @"/Applications/Cydia.app",
							   @"/Applications/RockApp.app",
							   @"/Applications/Icy.app",
							   @"/usr/sbin/sshd",
							   @"/usr/bin/sshd",
							   @"/usr/libexec/sftp-server",
							   @"/Applications/WinterBoard.app",
							   @"/Applications/SBSettings.app",
							   @"/Applications/MxTube.app",
							   @"/Applications/IntelliScreen.app",
							   @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
							   @"/Applications/FakeCarrier.app",
							   @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
							   @"/private/var/lib/apt",
							   @"/Applications/blackra1n.app",
							   @"/private/var/stash",
							   @"/private/var/mobile/Library/SBSettings/Themes",
							   @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
							   @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
							   @"/private/var/tmp/cydia.log",
							   @"/private/var/lib/cydia", nil];


	for(NSString *string in jailbrokenPath)
		if ([[NSFileManager defaultManager] fileExistsAtPath:string])
			rooted = rooted & YES;

	NSError *error;
	NSString *str = @"Some string";

	[str writeToFile:@"/private/test_jail.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
	if(error==nil)
	{
		rooted = YES;
	}

	NSString *result = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];

	if (!rooted)
	{
		result = [result stringByReplacingOccurrencesOfString:@"1" withString:@"A"];
		result = [result stringByReplacingOccurrencesOfString:@"2" withString:@"B"];
		result = [result stringByReplacingOccurrencesOfString:@"3" withString:@"C"];
		result = [result stringByReplacingOccurrencesOfString:@"4" withString:@"D"];
		result = [result stringByReplacingOccurrencesOfString:@"5" withString:@"E"];
		result = [result stringByReplacingOccurrencesOfString:@"6" withString:@"F"];
		result = [result stringByReplacingOccurrencesOfString:@"7" withString:@"G"];
	}

	return result;
}

+ (NSString *)appVersion
{
	NSBundle *bundle = [NSBundle mainBundle];
	return [NSString stringWithFormat:@"%@(%@)",
				[bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString" ],
				[bundle objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

+ (BOOL)iOS7OrLater
{
	return [[self deviceOS] doubleValue] >= 7;
}

+ (BOOL)iOS8OrLater
{
    return [[self deviceOS] doubleValue] >= 8;
}

+ (BOOL)retina
{
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
	{
		return YES;
	}
	
	return NO;
}

+ (BOOL)isIFamilyLessThen4S
{
	NSString *machineName = [ABUtils deviceModelName];
	BOOL isIFamilyLessThen4S = NO;

	if (
		[machineName rangeOfString:@"iPhone3"].location != NSNotFound
		|| [machineName rangeOfString:@"iPhone2"].location != NSNotFound
		|| [machineName rangeOfString:@"iPhone1"].location != NSNotFound
		|| [machineName rangeOfString:@"iPod1"].location != NSNotFound
		|| [machineName rangeOfString:@"iPod2"].location != NSNotFound
		|| [machineName rangeOfString:@"iPod3"].location != NSNotFound
		|| [machineName rangeOfString:@"iPod4"].location != NSNotFound
		)
	{
		isIFamilyLessThen4S = YES;
	}

	return isIFamilyLessThen4S;
}

+ (BOOL)isDeviceInDevicesList:(NSArray *)supportedDevices
{
    NSString *machineName = [ABUtils deviceModelName];
    
    for (NSString *deviceModelSubstring in supportedDevices)
    {
        if ([machineName rangeOfString:deviceModelSubstring].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)hasAccessToVideo
{
    if (![self iOS8OrLater])
    {
        return YES;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        return YES;
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)
    {
        __block BOOL accessGranted = NO;
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
        {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        return accessGranted;
    }
    else
    {
        return NO;
    }
    
    //Может понадобится...
    //    else if(authStatus == AVAuthorizationStatusDenied){
    //        // denied
    //    } else if(authStatus == AVAuthorizationStatusRestricted){
    //        // restricted, normally won't happen
    //    }
}

+ (CGSize)sizeAccordingToRetina:(CGSize)size
{
    if ([self retina])
    {
        size.width += size.width;
        size.height += size.height;
    }
    
    return size;
}

+ (CGFloat)windowWidth
{
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    return keyWindow.frame.size.width;
}

+ (CGFloat)windowHeight
{
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    return keyWindow.frame.size.height;
}

#pragma mark - Word Ending

+ (ABWordEndingByCountType)wordEndingWithCountOf:(int)count
{
	count = abs(count);
	int countResidue10 = count % 10;

	if ((count <= 20 && count >= 5) || (countResidue10 == 0))
	{
		return ABWordEndingByCountTypeFrom5To20OrResidue0;
	}

	if (countResidue10 <=4 && countResidue10 >=2)
	{
		return ABWordEndingByCountTypeResidueFrom2To4;
	}

	return ABWordEndingByCountTypeResidue1;
}



#pragma mark - Date and Time calculation


+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Moscow"]];
        [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
	return dateFormatter;
}

+ (NSCalendar *)gregorianCalendar
{
    static NSCalendar *calendar = nil;
    
    if (!calendar)
    {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Moscow"]];
    }
    
    return calendar;
}

+(NSDate *)dateWithCurrentDateMinusYears:(NSInteger)years
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setYear:-years];

	NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
	return date;
}

+ (NSDateComponents *)dateDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    // Manage Date Formation same for both dates
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:date1];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:date2];
    
    
    NSCalendar *calendar = [ABUtils gregorianCalendar];
    unsigned flags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents *difference = [calendar components:flags fromDate:startDate toDate:endDate options:0];
    
    return difference;
}

+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date
{
    NSCalendar *calendar = [ABUtils gregorianCalendar];
    unsigned flags = NSMinuteCalendarUnit| NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    return [calendar components:flags fromDate:date];
}

+ (NSInteger)dayDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    return 	(NSInteger)(fabs(date1 - date2)/(60*60*24));
}

+ (NSInteger)secondDiffrenceFromDate:(NSTimeInterval)date1 second:(NSTimeInterval)date2
{
    // Manage Date Formation same for both dates
	NSInteger difference = (NSInteger)fabs(date2 - date1);
    
    return difference;
}

+ (NSUInteger)daysInCurrentYear
{
    NSDate *someDate = [NSDate date];

    NSDate *beginningOfYear;
    NSTimeInterval lengthOfYear;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian rangeOfUnit:NSYearCalendarUnit
                 startDate:&beginningOfYear
                  interval:&lengthOfYear
                   forDate:someDate];
    NSDate *nextYear = [beginningOfYear dateByAddingTimeInterval:lengthOfYear];
    NSUInteger startDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit
                                              inUnit:NSEraCalendarUnit
                                             forDate:beginningOfYear];
    NSUInteger endDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit
                                            inUnit:NSEraCalendarUnit
                                           forDate:nextYear];

    return endDay - startDay;
}

+ (NSUInteger)daysInCurrentMonth
{
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:today];
    return days.length;
}

+ (NSInteger)currentYear
{
    NSCalendar *calendar = [ABUtils gregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
    
    return dateComponents.year;
}

+ (NSInteger)currentMonth
{
    NSCalendar *calendar = [ABUtils gregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSMonthCalendarUnit fromDate:[NSDate date]];
    
    return dateComponents.month;
}

+ (NSTimeInterval)dateToTimeStampInMilliseconds:(NSDate *)date
{
    NSTimeInterval timeStamp = [date timeIntervalSince1970];
	timeStamp = timeStamp * (NSTimeInterval)kMillisecondsMultiplier;
    timeStamp = ceil(timeStamp);

    return timeStamp;
}

+ (NSDate *)nextDateFromNowWithDayOfMonth:(NSInteger)day
{
    NSDate *nextPayment;
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:0];
    NSDate * date = [NSDate date];
    NSDateComponents * dc = [calendar components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    
    if (day==31)
    {
        dc.day = 0;
        dc.month = dc.month+1;
        nextPayment = [calendar dateFromComponents:dc];
        if ([nextPayment earlierDate:date] == nextPayment)
        {
            dc = [calendar components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:nextPayment];
            dc.month = dc.month + 2;
            dc.day = 0;
            nextPayment = [calendar dateFromComponents:dc];
        }
        
    }
    else
    {
        dc.day = day;
        nextPayment = [calendar dateFromComponents:dc];
        if ([nextPayment earlierDate:date] == nextPayment)
        {
            dc = [[NSDateComponents alloc]init];
            dc.month = 1;
            nextPayment = [calendar dateByAddingComponents:dc toDate:nextPayment options:0];
        }
    }
    
    return nextPayment;
}

+ (NSDate *)nextDateFromNowWithDayOfWeek:(NSUInteger)day
{
    NSDate *nextPayment;
    
    NSCalendar * calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:0];
    NSDate * date = [NSDate date];
    
    NSDateComponents *dc = [calendar components:(NSWeekdayCalendarUnit|NSWeekCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    [dc setWeekday:(NSInteger)(day + 1)];
    nextPayment = [calendar dateFromComponents:dc];
    if ([nextPayment earlierDate:date] == nextPayment)
    {
        nextPayment=[nextPayment dateByAddingTimeInterval:7*24*60*60];
    }
    
    return nextPayment;
}

+ (NSString *)dayOfTheWeekName:(NSUInteger)day
{
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	[df setLocale: [NSLocale currentLocale]];
	NSArray * weekdays = [df weekdaySymbols];

	return weekdays[day == 6 ? 0 : day + 1];
}

#pragma mark - Text Masking

+ (void) logCharacterSet:(NSCharacterSet*)characterSet
{
    unichar unicharBuffer[20];
    NSUInteger index = 0;

    for (unichar uc = 0; uc < (0xFFFF); uc ++)
    {
        if ([characterSet characterIsMember:uc])
        {
            unicharBuffer[index] = uc;

            index ++;

            if (index == 20)
            {
                NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
                NSLog(@"%@", characters);

                index = 0;
            }
        }
    }

    if (index != 0)
    {
        NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
        NSLog(@"%@", characters);
    }
}

+ (NSArray *)charactersInMask:(NSString *)mask
{
	NSMutableArray * array = [NSMutableArray arrayWithArray:[mask componentsSeparatedByString:@"_"]];
	[array addObject:@"+7"];

	NSUInteger arrayCount = [array count];
	for (unsigned int i = 0; i < arrayCount ; i++)
	{
		NSString * string = (NSString *)array[i];
		if ([string length] > 1)
		{
			[array addObject:[string substringToIndex:string.length - 1]];
		}
	}

	mask = [mask stringByReplacingOccurrencesOfString:@"_" withString:@""];
	
	if (mask.length)
	{
		[mask enumerateSubstringsInRange:[mask rangeOfString:mask]
								 options:NSStringEnumerationByComposedCharacterSequences
							  usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
								  if (![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[substring characterAtIndex:0]])
								  {
									  [array addObject:substring];
								  }
							  }];
	}
	else // нужно для случая если маска имеет вид @"______"
	{
		return @[];
	}

	return array;
}


+ (NSString *)stringWithoutMask:(NSString *)string mask:(NSString *)mask
{

	for (NSString * character in [ABUtils charactersInMask:mask])
	{
		string = [string stringByReplacingOccurrencesOfString:character withString:@""];
	}

	if (string == nil)
	{
		string = @"";
	}

	return string;
}

+ (NSString *)maskSubstringToFirstInputElement:(NSString *)mask
{
	if (mask.length == 0)
	{
		return @"";
	}

	return [mask substringToIndex:[mask rangeOfString:@"_"].location];
}


+ (NSString *)stringByApplyingMask:(NSString*)iFaceMask toString:(NSString*)originalString
{
	NSString *string = [ABUtils stringWithoutMask:originalString mask:iFaceMask];

	NSMutableString * sourceString = [NSMutableString stringWithString:string];
	NSMutableString * appliedString = [NSMutableString string];

	for (unsigned int i=0;(sourceString.length > 0 && i < iFaceMask.length) ; i++)
	{
		NSRange range = {i,1};
		NSString *strChar = [iFaceMask substringWithRange:range];

		if ([strChar isEqualToString:@"_"])
		{
			[appliedString appendString:[sourceString substringWithRange:NSMakeRange(0, 1)]];
			[sourceString deleteCharactersInRange:NSMakeRange(0, 1)];
		}
		else
		{
			[appliedString appendString:strChar];
		}
	}

	if (appliedString.length == 0 && iFaceMask.length > 0 && originalString.length > 0)
	{
		return [ABUtils maskSubstringToFirstInputElement:iFaceMask];
	}

	return appliedString;
}

+ (NSString *)stringForMask:(NSString *)maskString
			availableString:(NSString *)availableString
				  newString:(NSString *)newString
{
	if (!availableString || availableString.length==0)
	{
		availableString = @"";
	}

	if (newString == nil)
	{
		newString = @"";
	}

	NSCharacterSet *maskCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@")( -"];
	NSString *availableStringNonFormat = [[availableString componentsSeparatedByCharactersInSet:maskCharacterSet] componentsJoinedByString:@""];
	newString = [[newString componentsSeparatedByCharactersInSet:maskCharacterSet] componentsJoinedByString:@""];
	newString = [newString stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSString *strNecessarily = [[maskString componentsSeparatedByCharactersInSet:maskCharacterSet] componentsJoinedByString:@""];
	strNecessarily = [strNecessarily stringByReplacingOccurrencesOfString:@"_" withString:@""];

	NSString *strResultAvailableString = @"";
	if ([newString length] == 0 && [availableStringNonFormat length] > [strNecessarily length])
	{
		strResultAvailableString = [availableStringNonFormat substringToIndex:[availableStringNonFormat length]-1];
	}
	else if ([availableStringNonFormat length] == 0 && [strNecessarily isEqualToString:newString])
	{
		strResultAvailableString = [NSString stringWithFormat:@"%@", strNecessarily];
	}
	else if ([newString length] >= [availableStringNonFormat length] && [newString length]>2)
	{
		if ([newString rangeOfString:strNecessarily].length > 0)
			strResultAvailableString = [NSString stringWithFormat:@"%@", newString];
		else
			strResultAvailableString = [NSString stringWithFormat:@"%@%@", strNecessarily, newString];
	}
	else if ([availableString length] == [strNecessarily length])
	{
		strResultAvailableString = [NSString stringWithFormat:@"%@%@", strNecessarily, newString];
	}
	else
	{
		strResultAvailableString = [NSString stringWithFormat:@"%@%@", availableStringNonFormat, newString];
	}

	NSMutableString *result = [[NSMutableString alloc] init];

	if ([strResultAvailableString length]>0)
	{
		unsigned int charIncertIndex = 0;
		for (NSUInteger i=0;i<[maskString length]; i++)
		{
			NSRange range = {i,1};
			NSString *strChar = [maskString substringWithRange:range];
			if ([strChar rangeOfCharacterFromSet:maskCharacterSet].location != NSNotFound)
			{
				[result appendString:strChar];
			}
			else
			{
				range.location = charIncertIndex;
				strChar = [strResultAvailableString substringWithRange:range];
				[result appendString:strChar];
				charIncertIndex ++;
				if (charIncertIndex >= [strResultAvailableString length])
				{
					if (i+1<[maskString length]-1)
					{
						NSRange substringRange = {i+1,1};
						NSString *substring = [maskString substringWithRange:substringRange];
						if ([substring rangeOfCharacterFromSet:maskCharacterSet].location != NSNotFound)
						{
							[result appendString:substring];
						}
					}
					break;
				}
			}
		}
	}

	return result;
}



+ (NSString *)stringPhoneDialFromString:(NSString*)string
{
	NSMutableString * resultString = [NSMutableString string];
	NSMutableCharacterSet * set = [NSMutableCharacterSet decimalDigitCharacterSet];
	[set addCharactersInString:@"+"];

	for (unsigned int i = 0; i < string.length; i++)
	{
		if ([set characterIsMember:[string characterAtIndex:i]])
		{
			[resultString appendFormat:@"%c", [string characterAtIndex:i]];
		}
	}

	return resultString;
}

+ (NSString *)stringWithAdd7PhoneString:(NSString *)phoneString
{
    NSString *resultString = phoneString;
    
    if (phoneString.length >= 10)
    {
        resultString = [phoneString substringFromIndex:phoneString.length - 10];
        
        return [NSString stringWithFormat:@"+7%@",resultString];
    }
    
    return phoneString;
}

+ (NSString *)unformattedStringForPhone:(NSString *)phone
{
    NSString *result = [[phone componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    
    if (result.length >= 10)
    {
        result = [result substringFromIndex:result.length - 10];
    }
    
    return result;
}

+ (CGSize)correctAttributedStringSize:(CGSize)size
{
    CGSize realSize = size;
    realSize.width += 1;
    realSize.height += 1;
    
    return realSize;
}

+ (NSString *)formattedCardNumberString:(NSString *)string
{
    ABP2PCardType cardType = [self cardTypeByCardNumberString:string];
    
	NSMutableString *verifiedString = [NSMutableString stringWithString:string];
	
    if (cardType != ABP2PCardTypeMaestro)
    {
        if (string.length >= kDefaulMaxCardNumberCharaters)
        {
            for (unsigned int i = kDefaulNumberCharatersPerCardNumberChunk; i < kDefaulMaxCardNumberCharaters; i += (kDefaulNumberCharatersPerCardNumberChunk + 1))
            {
                [verifiedString insertString:@" " atIndex:i];
            }
        }
    }
    else
    {
        if (verifiedString.length > kMaestroNumberCharatersPerCardNumberChunk)
        {
            [verifiedString insertString:@" " atIndex:kMaestroNumberCharatersPerCardNumberChunk];
        }
    }
	
	return [NSString stringWithString:verifiedString];
}

#pragma mark - Trimm text

+ (NSString *)trimmedText:(NSString *)text
{
	if (text.length == 0)
	{
		return @"";
	}
	else if ([[text substringToIndex:1] isEqualToString:@" "])
	{
		return [ABUtils trimmedText:[text substringFromIndex:1]];
	}
	else if ([[text substringFromIndex:text.length-1] isEqualToString:@" "])
	{
		return [ABUtils trimmedText:[text substringToIndex:text.length-1]];
	}
	else
	
	return text;
}

+ (NSString *)serviceNameFromURLString:(NSString *)url
{
//	asdfkjshf/servicename?fsgsgadfsdf

	NSArray * components = [url componentsSeparatedByString:@"?"];
	if (components)
	{
		url = components[0];
	}

	components = [url componentsSeparatedByString:@"/"];
	if (components)
	{
		url = [components lastObject];
	}

	return url;
}

+ (NSString *)parameterValue:(NSString *)parameter fromURLString:(NSString *)urlString
{
	NSString * parameterValue = nil;
	NSRange locationOfParameter = [urlString rangeOfString:[NSString stringWithFormat:@"%@=",parameter]];

	if (locationOfParameter.location != NSNotFound)
	{
		NSString * rightPartFromParameter = [urlString substringFromIndex:locationOfParameter.location+locationOfParameter.length];
		NSArray * componentsOfString = [rightPartFromParameter componentsSeparatedByString:@"&"];

		if (componentsOfString && componentsOfString.count > 0)
		{
			parameterValue = componentsOfString[0];
		}
	}

	return parameterValue;
}

+ (void)removeEmojiFromTextInTextView:(UITextView *)textView
{
	NSRange selectedRange = [textView selectedRange];
    NSUInteger lengthWithEmoji = textView.text.length;
    NSUInteger lengthWithoutEmoji = [textView.text removeEmoji].length;

    textView.text = [textView.text removeEmoji];
    [textView setSelectedRange:NSMakeRange(selectedRange.location - (lengthWithEmoji - lengthWithoutEmoji), selectedRange.length)];
}

#pragma mark - Regexp


+ (BOOL)isString:(NSString *)string
isValidWithRegexp:(NSString *)regExp
	  isRequired:(BOOL)isRequired
{
    if (!string || !string.length)
    {
        return !isRequired;
    }
    
    if (!regExp || !regExp.length)
    {
        return YES;
    }
    
	else if ( string != nil)
	{
		NSError * error;
		NSRegularExpression * _regExp= [NSRegularExpression regularExpressionWithPattern:regExp options:0 error:&error];
		NSString *strValidateValue = string;
		NSRange wholeRange = NSMakeRange(0, [strValidateValue length]);
		NSTextCheckingResult * checkResult = [_regExp firstMatchInString:strValidateValue options:0 range:wholeRange];
		NSRange firstRange = [checkResult rangeAtIndex:0];

		if (checkResult == nil || [checkResult numberOfRanges] == 0 || !NSEqualRanges(firstRange, wholeRange))
			return NO;
		else
			return YES;
	}

	return NO;
}


#pragma mark - Summ formatting

+ (NSNumberFormatter *)summNumberFormatterWithoutComma
{
	static NSNumberFormatter * summNumberFormatter = nil;

	if (summNumberFormatter == nil)
	{
		summNumberFormatter = [[NSNumberFormatter alloc] init];
		[summNumberFormatter setGroupingSize:3];
		[summNumberFormatter setGroupingSeparator:kSummGroupingSeparator];
		[summNumberFormatter setUsesGroupingSeparator:YES];
		[summNumberFormatter setDecimalSeparator:kSummDecimalSeparator];
		[summNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[summNumberFormatter setMaximumFractionDigits:0];
		[summNumberFormatter setMinimumFractionDigits:0];
	}

	return summNumberFormatter;
}

+ (NSNumberFormatter *)summNumberFormatter
{
	static NSNumberFormatter * summNumberFormatter = nil;

	if (summNumberFormatter == nil)
	{
		summNumberFormatter = [[NSNumberFormatter alloc] init];
		[summNumberFormatter setGroupingSize:3];
		[summNumberFormatter setGroupingSeparator:kSummGroupingSeparator];
		[summNumberFormatter setUsesGroupingSeparator:YES];
		[summNumberFormatter setDecimalSeparator:kSummDecimalSeparator];
		[summNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[summNumberFormatter setMaximumFractionDigits:2];
		[summNumberFormatter setMinimumFractionDigits:2];
	}

	return summNumberFormatter;
}

+ (NSUInteger)numberOfPartsForMoneyAmountString:(NSString *)amountString
{
    return [[amountString componentsSeparatedByString:kWhitespaceCharacter] count];
}

+ (Float64)fractionAmountFromAmount:(Float64)amount withNumberOfDigits:(NSInteger)numberOfDigits
{
	amount = fabs(amount);
	double fractionAmount = (amount - floor(amount))*pow(10, numberOfDigits);

	return fractionAmount;
}

+ (BOOL)hasAmountFractionDigits:(Float64)amount digit:(NSInteger)digit
{
    Float64 fractionAmount = [ABUtils fractionAmountFromAmount:amount withNumberOfDigits:digit];

    return (round(fractionAmount) == 0) ? YES : NO;
}

+ (BOOL)hasAmountFractionDigits:(Float64)amount
{
    return [ABUtils hasAmountFractionDigits:amount digit:2];
}

+ (BOOL)hasAmountFractionDigits4:(Float64)amount
{
    return [ABUtils hasAmountFractionDigits:amount digit:4];
}

+ (NSString *)amountAsFormattedString:(Float64)amount
{
    if ([ABUtils hasAmountFractionDigits:amount])
    {
        return [ABUtils amountWholeDigits:amount];
    }
    
	return [ABUtils amountAsString:amount];
}

+ (NSString *)amountAsFormattedString1:(Float64)amount
{
    if ([ABUtils hasAmountFractionDigits:amount digit:1])
    {
        return [ABUtils amountWholeDigits:amount];
    }
    
    return [ABUtils amountAsString1:amount];
}

+ (NSString *)amountAsString1:(Float64)amount
{
    return [NSString stringWithFormat:@"%@%@%@", [ABUtils amountWholeDigits:amount], kSummDecimalSeparator, [ABUtils amountFractionDigits1:amount]];
}

+ (NSString *)amountAsString:(Float64)amount
{
	return [NSString stringWithFormat:@"%@%@%@", [ABUtils amountWholeDigits:amount], kSummDecimalSeparator, [ABUtils amountFractionDigits:amount]];
}

+ (NSString *)amountAsStringForCommission:(Float64)amount
{
	return [NSString stringWithFormat:@"%@%@%@", [ABUtils amountWholeDigits:amount], kSummMachineDecimalSeparator, [ABUtils amountFractionDigits:amount]];
}

+ (NSString *)amountWholeDigits:(Float64)amount
{
    NSString *string = [[self summNumberFormatter] stringFromNumber:@(amount)];
	NSArray *array = [string componentsSeparatedByString:kSummDecimalSeparator];

	if ([array count] == 2)
	{
		return array[0];
	}

	return string;
}

/*
 Метод возвращает дробную часть amount с точностью 2 знака после запятой
 */
+ (NSString *)amountFractionDigits:(Float64)amount
{
	Float64 fractionAmount = [ABUtils fractionAmountFromAmount:amount withNumberOfDigits:2];
    Float64 retVal = round(fractionAmount);
    
    return [NSString stringWithFormat:retVal < 10 ? @"%02.0f" : @"%.0f", retVal];
}

/*
 Метод возвращает дробную часть amount с точностью 4 знака после запятой
 */
+ (NSString *)amountFractionDigits4:(Float64)amount
{
    Float64 fractionAmount = [ABUtils fractionAmountFromAmount:amount withNumberOfDigits:4];
    Float64 retVal = round(fractionAmount);
    
    return [NSString stringWithFormat:retVal < 1000 ? @"%04.0f": @"%.0f",retVal];
}

+ (NSString *)amountFractionDigits1:(Float64)amount
{
    Float64 fractionAmount = [ABUtils fractionAmountFromAmount:amount withNumberOfDigits:1];
    Float64 retVal = round(fractionAmount);
    
    return [NSString stringWithFormat:retVal < 1 ? @"%01.0f" : @"%.0f", retVal];
}


+ (NSString *)setSummDecimalSeparator:(NSString *)amountString
{
    NSString *strAmount = [amountString stringByReplacingOccurrencesOfString:@"." withString:kSummDecimalSeparator];
	strAmount = [strAmount stringByReplacingOccurrencesOfString:@"," withString:kSummDecimalSeparator];
    
    return strAmount;
}

+ (NSString *)fixDecimalSeparator:(NSString *)decimalString
{
    return [decimalString stringByReplacingOccurrencesOfString:@"," withString:kSummMachineDecimalSeparator];
}

+ (NSNumber *)nonFormatAmount:(NSString *)amountString
{
	NSString *strAmount = [ABUtils nonFormatAmountString:amountString];
    
    NSNumber *number = @([strAmount floatValue]);
    
    return number;
}

+ (NSString *)nonFormatAmountString:(NSString *)amountString
{
    NSString *strAmount = [ABUtils fixDecimalSeparator:amountString];
    
    strAmount = [strAmount stringByReplacingOccurrencesOfString:@" " withString:@""];
    strAmount = [strAmount stringByReplacingOccurrencesOfString:@" " withString:@""];
	
    return strAmount;
}

/*
 Метод возвращает форматированное значение суммы.
 Используется при вводе в UITextField
 */
+ (NSString *)formatInputSumm:(NSString *)aTextFieldString string:(NSString *)string range:(NSRange)range
{
	string = [string stringByReplacingOccurrencesOfString:@"." withString:kSummDecimalSeparator];
	string = [string stringByReplacingOccurrencesOfString:@"," withString:kSummDecimalSeparator];
	
	NSString * regExpString = [NSString stringWithFormat:@"[0-9]*\\%@?[0-9]{0,2}", kSummDecimalSeparator];
	
	NSMutableString * resString = [NSMutableString stringWithString:aTextFieldString];
	[resString replaceCharactersInRange:range withString:string];
	
	NSError * error = nil;
	NSRegularExpression * regExp= [NSRegularExpression regularExpressionWithPattern: regExpString
																			options: NSRegularExpressionCaseInsensitive
																			  error: &error];
	resString = (NSMutableString*)[resString stringByReplacingOccurrencesOfString:kSummGroupingSeparator withString:@""];
	NSRange wholeRange = NSMakeRange(0, resString.length);
	NSTextCheckingResult * checkResult = [regExp firstMatchInString:resString options:0 range:wholeRange];
	if (checkResult == nil) {
		DLog(@"checkResult == nil");
		return aTextFieldString;
	}
	
	if ([checkResult numberOfRanges] == 0 && resString.length > 0) {
		DLog(@"[checkResult numberOfRanges] == 0 && string.length > 0");
		return aTextFieldString;
	}
	
	NSRange rirstRange = [checkResult rangeAtIndex:0];
	if (!NSEqualRanges(rirstRange, wholeRange))
	{
		DLog(@"!NSEqualRanges(rirstRange, wholeRange)");
		return aTextFieldString;
	}
	
	range = [resString rangeOfString:kSummDecimalSeparator];
	NSString *strCurrencyAfterDot = nil;
	
	if (range.length >0)
	{
		strCurrencyAfterDot = [resString substringFromIndex:range.location];
		resString = (NSMutableString*)[resString substringToIndex:range.location];
	}
	
	// TODO: get rid of redundant formatter creation
	NSNumberFormatter * currencyFormatter = nil;
	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setGroupingSize:3];
	[currencyFormatter setNumberStyle:NSNumberFormatterNoStyle];
	[currencyFormatter setGroupingSeparator:kSummGroupingSeparator];
	[currencyFormatter setDecimalSeparator:kSummDecimalSeparator];
	[currencyFormatter setUsesGroupingSeparator:YES];
	
	if ([resString longLongValue] > LONG_LONG_MAX-1)
	{
		return aTextFieldString;
	}
	
	NSString *str = [currencyFormatter stringFromNumber:@([resString longLongValue])];
	
	if ([strCurrencyAfterDot length]>0)
	{
		str = [NSString stringWithFormat:@"%@%@",str,strCurrencyAfterDot];
	}
	
	return str;
}

//+ (NSString *)formatInputSumm:(NSString *)aTextFieldString string:(NSString *)string range:(NSRange)range
//{
//	return [ABUtils formatInputSumm:[aTextFieldString stringByReplacingCharactersInRange:range withString:string] oldString:aTextFieldString];
//}

+ (NSString *)formatInputSumm:(NSString *)nonFormatAmountString oldString:(NSString *)oldString
{
	nonFormatAmountString = [self setSummDecimalSeparator:nonFormatAmountString];
	NSString * regExpString = [NSString stringWithFormat:@"[0-9]*\\%@?[0-9]{0,2}", kSummDecimalSeparator];

	NSMutableString * resString = nonFormatAmountString ? [NSMutableString stringWithString:nonFormatAmountString] : [NSMutableString string];

	NSError * error = nil;
	NSRegularExpression * regExp= [NSRegularExpression regularExpressionWithPattern: regExpString
																			options: NSRegularExpressionCaseInsensitive
																			  error: &error];
	resString = (NSMutableString*)[resString stringByReplacingOccurrencesOfString:kSummGroupingSeparator withString:@""];
	NSRange wholeRange = NSMakeRange(0, resString.length);
	NSTextCheckingResult * checkResult = [regExp firstMatchInString:resString options:0 range:wholeRange];
	if (checkResult == nil) {
		DLog(@"checkResult == nil");
		return oldString;
	}

	if ([checkResult numberOfRanges] == 0 && resString.length > 0) {
		DLog(@"[checkResult numberOfRanges] == 0 && string.length > 0");
		return oldString;
	}

	NSRange firstRange = [checkResult rangeAtIndex:0];
	if (!NSEqualRanges(firstRange, wholeRange))
	{
		DLog(@"!NSEqualRanges(firstRange, wholeRange)");
		return oldString;
	}

	NSRange range = [resString rangeOfString:kSummDecimalSeparator];
	NSString *strCurrencyAfterDot = nil;

	if (range.length >0)
	{
		strCurrencyAfterDot = [resString substringFromIndex:range.location];
		resString = (NSMutableString*)[resString substringToIndex:range.location];
	}

	NSNumberFormatter * currencyFormatter = nil;
	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setGroupingSize:3];
	[currencyFormatter setNumberStyle:NSNumberFormatterNoStyle];
	[currencyFormatter setGroupingSeparator:kSummGroupingSeparator];
	[currencyFormatter setDecimalSeparator:kSummDecimalSeparator];
	[currencyFormatter setUsesGroupingSeparator:YES];

	if ([resString integerValue] > NSIntegerMax-1)
	{
		return oldString;
	}

	NSString *str = [currencyFormatter stringFromNumber:@([resString integerValue])];

	if ([strCurrencyAfterDot length]>0)
	{
		str = [NSString stringWithFormat:@"%@%@",str,strCurrencyAfterDot];
	}

	return str;
}


#pragma mark - Map cluster objects


+ (NSString *)stringFromNumber:(NSInteger)number strOne:(NSString *)strOne strSeveral:(NSString *)strSeveral strLot:(NSString *)strLot
{
	NSInteger value = number % 100;
	if (value > 10 && value < 20)
		return strLot;
    
	value = value % 10;
	if (value == 1)
		return strOne;
	else
		if (value > 1 && value< 5) return strSeveral;
    
	return strLot;
}

+ (NSString *)stringForObjectsGroup:(NSInteger)value
{
    return [self stringFromNumber:value strOne:LOC(@"объекта") strSeveral:LOC(@"объектов") strLot:LOC(@"объектов")]; // TODO: Localization
}


#pragma mark - Card Type

+ (ABP2PCardType)cardTypeByCardNumberString:(NSString *)cardNumber
{
    int firstNum = cardNumber.length>0 ? [[cardNumber substringToIndex:1]intValue] : 0;
    switch (firstNum)
    {
        case 4:  return ABP2PCardTypeVisa;		  // Visa
        case 5:  return ABP2PCardTypeMasterCard; // Mastercard
        case 6:	 return ABP2PCardTypeMaestro;	  // Maestro
        default: return ABP2PCardTypeNone;		  // Unknown
    }
}


+ (NSArray *)cardNumberChunksWithCardNumber:(NSString *)cardNumber
{
    if (!cardNumber || ![cardNumber length])
    {
        return nil;
    }
    
    NSMutableArray *cardNumberChunks = [NSMutableArray new];
    ABP2PCardType cardType = [ABUtils cardTypeByCardNumberString:cardNumber];
    
    if (cardType == ABP2PCardTypeMaestro && [cardNumber length] > kDefaulMaxCardNumberCharaters)
    {
        if ([cardNumber length] > kMaestroMaxCardNumberCharaters)
        {
            cardNumber = [cardNumber substringToIndex:kMaestroMaxCardNumberCharaters];
        }
        
        if ([cardNumber length] > kMaestroNumberCharatersPerCardNumberChunk)
        {
            [cardNumberChunks addObject:[cardNumber substringToIndex:kMaestroNumberCharatersPerCardNumberChunk]];
            [cardNumberChunks addObject:[cardNumber substringFromIndex:kMaestroNumberCharatersPerCardNumberChunk]];
        }
        else
        {
            [cardNumberChunks addObject:cardNumber];
        }
    }
    else
    {
        if ([cardNumber length] > kDefaulMaxCardNumberCharaters)
        {
            cardNumber = [cardNumber substringToIndex:kDefaulMaxCardNumberCharaters];
        }
        
        while ([cardNumber length] > 0)
        {
            if ([cardNumber length] < kDefaulNumberCharatersPerCardNumberChunk)
            {
                [cardNumberChunks addObject:cardNumber];
                break;
            }
            
            [cardNumberChunks addObject:[cardNumber substringToIndex:kDefaulNumberCharatersPerCardNumberChunk]];
            cardNumber = [cardNumber substringFromIndex:kDefaulNumberCharatersPerCardNumberChunk];
        };
    }
    
    return cardNumberChunks;
}


#pragma mark - String is Substring

+ (BOOL)searchString:(NSString *)searchString inString:(NSString *)inString
{
    return [self searchString:searchString inString:inString matchingCase:NO];
}

+ (BOOL)searchString:(NSString *)searchString inString:(NSString *)inString matchingCase:(BOOL)matchingCase
{
    if (!matchingCase)
    {
        inString = [inString uppercaseString];
        searchString = [searchString uppercaseString];
    }
    
    NSRange range = [inString rangeOfString:searchString];
    if (range.length > 0)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isStringNumeric:(NSString *)string
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:string];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    return valid;
}

#pragma mark - Image masking

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{

    CGImageRef maskRef = maskImage.CGImage;

    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, NO);

    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];

    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);

    return maskedImage;
}

+ (void)addImageAsMask:(UIImage *)maskImage toView:(UIView *)view
{
    UIImageView *maskView = [[UIImageView alloc] initWithImage:maskImage];

    [view.layer setMasksToBounds:YES];
    [view.layer setMask:maskView.layer];
}

+ (UIImage *)maskedImage:(UIImage *)imageToAddMask
		   withMaskImage:(UIImage *)maskImage
			 contentMode:(UIViewContentMode)contentMode
{
	UIImage *scaledImageToMaskSize = nil;

    if (contentMode == UIViewContentModeScaleToFill)
    {
        scaledImageToMaskSize = [imageToAddMask imageByScalingProportionallyToMinimumSize:CGSizeMake(maskImage.size.width, maskImage.size.height)];
    }
    else
    {
        scaledImageToMaskSize = [imageToAddMask imageByScalingProportionallyToSize:CGSizeMake(maskImage.size.width, maskImage.size.height)];
    }

	UIImage *maskedImage = [ABUtils maskImage:scaledImageToMaskSize withMask:maskImage];

    return maskedImage;
}

#pragma mark Image to Base64

+ (NSString *)imageToString:(UIImage *)image
{
    if (!image)
    {
        return @"";
    }

    NSData* data = UIImageJPEGRepresentation(image, 1.0f);

    NSString *strEncoded = [data base64EncodedString];

    return strEncoded;
}

+ (UIImage *)fixOrientation:(UIImage*)image
{
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (image.imageOrientation)
	{
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, (float)M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, (float)M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, (float)-M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (image.imageOrientation)
	{
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)(image.size.width + 0.5f), (size_t)(image.size.height + 0.5f),
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);

    return img;
}

+ (UIImage*)cuttedImageFromImage:(UIImage*)image withRect:(CGRect)rect
{
	image = [ABUtils fixOrientation:image];
	CGSize size = image.size;

	// create a graphics context of the correct size
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();

	// correct for image orientation
	UIImageOrientation orientation = [image imageOrientation];

	switch (orientation) {
		case UIImageOrientationUp:
		{
			CGContextTranslateCTM(context, 0, size.height);
			CGContextScaleCTM(context, 1, -1);
			rect = CGRectMake(rect.origin.x,
							  -rect.origin.y,
							  rect.size.width,
							  rect.size.height);
		}
			break;

		case UIImageOrientationRight:
		{
			CGContextScaleCTM(context, 1.0, -1.0);
			CGContextRotateCTM(context, (CGFloat)(-M_PI/2.0));
			size = CGSizeMake(size.height, size.width);
			rect = CGRectMake(rect.origin.y,
							  rect.origin.x,
							  rect.size.height,
							  rect.size.width);
		}
			break;

		case UIImageOrientationDown:
		{
			CGContextTranslateCTM(context, size.width, 0);
			CGContextScaleCTM(context, -1, 1);
			rect = CGRectMake(-rect.origin.x,
							  rect.origin.y,
							  rect.size.width,
							  rect.size.height);
		}
			break;

		case UIImageOrientationLeft:
		{

		}
			break;

		default:
			break;
	}

	// draw the image in the correct place
	CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
	CGContextDrawImage(context,
					   CGRectMake(0,0, size.width, size.height),
					   image.CGImage);
	// and pull out the cropped image
	UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return croppedImage;
}

+ (UIImage *)squareImageFromCenterOfImage:(UIImage *)image
{
    if (image.size.width != image.size.height)
    {
        CGFloat minSize = MIN(image.size.width, image.size.height);
        image = [image imageAtRect:CGRectMake(image.size.width/2 - minSize/2, image.size.height/2 - minSize/2, minSize, minSize)];
    }
    
    return image;
}

#pragma mark - Distance
+ (NSString *)formatDistance:(double)dist
{
    NSString *km_m = (dist > 100) ? LOC(@"text.kilometers") : LOC(@"text.meters");
    
    if( dist < 1e2 ) { // lower available
        return [NSString stringWithFormat:@"%d %@", (int)dist, km_m];
    }
    
    if( dist >= 1e4 ) { // upper available
        return [NSString stringWithFormat:@"%d %@", (int)(dist/1e3), km_m];
    }
    
    return [NSString stringWithFormat:@"%.1f %@", dist/1e3, km_m];
}


#pragma mark Color gradient


+ (UIColor*)colorWithVerticalGradientStart:(float)sr
										 G:(float)sg
										 B:(float)sb
										 A:(float)sa
									  endR:(float)er
										 G:(float)eg
										 B:(float)eb
										 A:(float)ea
								   forSize:(CGSize)size
{
    CGFloat width = size.width;         // max 1024 due to Core Graphics limitations
    CGFloat height = size.height;       // max 1024 due to Core Graphics limitations

    // create a new bitmap image context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));

    // get context
    CGContextRef context = UIGraphicsGetCurrentContext();

    // push context to make it current (need to do this manually because we are not drawing in a UIView)
    UIGraphicsPushContext(context);

    //draw gradient
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { sr, sg, sb, sa,  // Start color
        er, eg, eb, ea }; // End color
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    CGPoint topCenter = CGPointMake(0, 0);
    CGPoint bottomCenter = CGPointMake(0, height);
    CGContextDrawLinearGradient(context, glossGradient, topCenter, bottomCenter, 0);

    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);

    // pop context
    UIGraphicsPopContext();

    // get a UIImage from the image context
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();

    // clean up drawing environment
    UIGraphicsEndImageContext();

    return [UIColor colorWithPatternImage:gradientImage];
}


#pragma mark AddressBook


+ (BOOL)addressBookAccessGranted
{
	CFErrorRef *error = nil;
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

	__block BOOL accessGranted = NO;

	if (ABAddressBookRequestAccessWithCompletion != NULL)
	{ // we're on iOS 6
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);

		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef accessError) {
			accessGranted = granted;
			dispatch_semaphore_signal(sema);
		});

		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	}
	else
	{ // we're on iOS 5 or older
		accessGranted = YES;
	}
	CFRelease(addressBook);

	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // The user has previously given access, add the contact
        return YES;
    }

	CFErrorRef *creationError = nil;
	addressBook = ABAddressBookCreateWithOptions(NULL, creationError);
	
	accessGranted = NO;
	
	if (ABAddressBookRequestAccessWithCompletion != NULL)
	{ // we're on iOS 6
		dispatch_semaphore_t sema = dispatch_semaphore_create(0);
		
		ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef completitionError) {
			accessGranted = granted;
			dispatch_semaphore_signal(sema);
		});
		
		dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
	}
	else
	{ // we're on iOS 5 or older
		accessGranted = YES;
	}
	
	if (addressBook)
	{
		CFRelease(addressBook);
	}
	
	return accessGranted;
}


#pragma mark - Facebook

+(void)clearFacebookCookies
{
	NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray* facebookCookies = [cookies cookies];
	
	for (NSHTTPCookie* cookie in facebookCookies)
	{
		if ([cookie.properties[kFBDomain] rangeOfString:kFacebookDomain].location != NSNotFound)
		{
			[cookies deleteCookie:cookie];
		}
	}
}

#pragma mark - VK

+ (void)clearVKCookies
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for (NSHTTPCookie *cookie in cookies)
    {
        if (NSNotFound != [cookie.domain rangeOfString:kVKDomain].location)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]
             deleteCookie:cookie];
        }
    }
}

#pragma mark - Encoding

+ (NSStringEncoding)stringEncodingWithName:(NSString *)stringEncodingName
{
    NSStringEncoding stringEncoding = 0;
    CFStringEncoding aEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)stringEncodingName);
    stringEncoding = CFStringConvertEncodingToNSStringEncoding(aEncoding);
    
    return stringEncoding;
}

#pragma mark - Error logging format

+ (NSString *)dictionaryToStringInLoggerFormat:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
    {
        return kEmptyString;
    }

    return [NSString stringWithFormat:@"%@=\"%@\"", [dictionary allKeys][0], dictionary[[dictionary allKeys][0]]];
}

#pragma mark - Card validation

+ (BOOL)cardNubmerLuhnCheck:(NSString *)cardNumber {
	cardNumber = [cardNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if (cardNumber.length == 0 || cardNumber.length < 16) {
		return NO;
	}
	
	return [NSString luhnCheck:cardNumber];
}

+ (BOOL)cardExpCheckWithString:(NSString *)cardExp {
	
	cardExp = [cardExp stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if (cardExp.length < 5) {
		return NO;
	}
	
	NSInteger year = [[cardExp substringFromIndex:3] integerValue];
	NSInteger month = [[cardExp substringToIndex:2] integerValue];
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSInteger currentMonth = [components month];
	NSInteger currentYear = [components year] - 2000;
	
	if (month > 12 || month < 1) {
		return NO;
	}
	
	if (year >= currentYear && year <= currentYear + 20) {
		if (currentYear == year && month < currentMonth)
		{
			return NO;
		}
		
		return YES;
	}
	
	return NO;
}

+ (BOOL)cardExpCheckWithDate:(NSDate *)cardExp {
	return NO;
}

+ (NSString *)numberForRussian:(NSNumber *)number {
    long long value = number.longLongValue;
    if (value < 0) 
        value = 0;
    
    if (value < 1000) {
        return [NSString stringWithFormat:@"%lli", value];
    }
    else if (value >= 1000 && value < 1000000) {
        return [NSString stringWithFormat:@"%@ тыс.", [ABUtils amountAsFormattedString:value/1000.0f]];
    }
    else if (value >= 1000000 && value < 1000000000) {
        return [NSString stringWithFormat:@"%@ млн.", [ABUtils amountAsFormattedString:value/1000000.0f]];
    }
    else if (value >= 1000000000 && value < 1000000000000) {
        return [NSString stringWithFormat:@"%@ млрд.", [ABUtils amountAsFormattedString:value/1000000000.0f]];
    }
    else if (value >= 1000000000000 && value < 1000000000000000) {
        return [NSString stringWithFormat:@"%@ трлн.", [ABUtils amountAsFormattedString:value/1000000000000.0f]];
    }
    else if (value >= 1000000000000000 && value < 1000000000000000000) {
        return [NSString stringWithFormat:@"%@ трлрд.", [ABUtils amountAsFormattedString:value/1000000000000000.0f]];
    }
    else if (value >= 1000000000000000000) {
        return [NSString stringWithFormat:@"%@ квадр.", [ABUtils amountAsFormattedString:value/1000000000000000000.0f]];
    }
    
    return nil;
}

+ (NSString*)sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end