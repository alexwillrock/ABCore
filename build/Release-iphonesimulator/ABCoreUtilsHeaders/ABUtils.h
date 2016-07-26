
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ABConstants.h"
#import "ABMacroses.h"

#pragma mark --------------------
#pragma mark Type definitions
#pragma mark --------------------

typedef enum
{
	ABP2PDateFormatShort = 0,
	ABP2PDateFormatFull,
	ABP2PDateFormatLong,
	ABP2PDateFormatRecently,
	ABP2PDateFormatTime,
    ABP2PDateFormatCardExpiry,
	ABP2PDateFormatLock,
	ABP2PDateFormatHumanTimer
	
}ABP2PDateFormat;

typedef enum
{
    ABP2PCardTypeNone = 0,
    ABP2PCardTypeVisa,
    ABP2PCardTypeMasterCard,
    ABP2PCardTypeMaestro
}
ABP2PCardType;

typedef enum {
	ABWordEndingByCountTypeResidue1,
	ABWordEndingByCountTypeFrom5To20OrResidue0,
	ABWordEndingByCountTypeResidueFrom2To4

}ABWordEndingByCountType;

	// Color utility functions
UIColor *ABColorFromIntWithAlpha(unsigned int rgbHex, CGFloat alpha); // Example: ABColorFromIntWithAlpha(0x00FF00, 0.7) - Green with 70% transparency
UIColor *ABColorFromInt(unsigned int rgbHex);
UIColor *ABColorFromIntGrey(unsigned int greyHex);


@interface ABUtils : NSObject

#pragma mark - Device & App info

	
+ (NSString *)deviceModel;
+ (NSString *)deviceOS;
+ (NSString *)deviceModelName;
+ (NSString *)deviceId;
+ (NSString *)platform;
+ (NSString *)screenResolution;
+ (NSString *)bundleAdditionalIdentifier;
+ (NSString *)dpi;
+ (NSString *)screenSize;
+ (NSString *)rootCheck;

+ (NSString *)buildNumberString;
+ (NSString *)appVersion;
+ (NSString *)appVersionAndBuildNumberString;

+ (CGFloat)fourInchesScreenHeight;

+ (BOOL)iOS7OrLater;
+ (BOOL)iOS8OrLater;
+ (BOOL)retina;
+ (BOOL)isIFamilyLessThen4S;
+ (BOOL)isDeviceInDevicesList:(NSArray *)supportedDevices;
+ (BOOL)hasAccessToVideo;

+ (CGSize)sizeAccordingToRetina:(CGSize)size;

+ (CGFloat)windowWidth;
+ (CGFloat)windowHeight;


#pragma mark - Word Ending

+ (ABWordEndingByCountType)wordEndingWithCountOf:(int)count;

#pragma mark - Date and Time calculation


+ (NSDateFormatter *)dateFormatter;

+ (NSCalendar *)gregorianCalendar;

+ (NSDate*)dateWithCurrentDateMinusYears:(NSInteger)years;

+ (NSDateComponents *)dateDiffrenceFromDate:(NSTimeInterval)date1
									 second:(NSTimeInterval)date2;

+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;

+ (NSInteger)dayDiffrenceFromDate:(NSTimeInterval)date1
                           second:(NSTimeInterval)date2;
+ (NSInteger)secondDiffrenceFromDate:(NSTimeInterval)date1
                              second:(NSTimeInterval)date2;
+ (NSUInteger)daysInCurrentYear;
+ (NSUInteger)daysInCurrentMonth;
+ (NSInteger)currentYear;
+ (NSInteger)currentMonth;

+ (NSTimeInterval)dateToTimeStampInMilliseconds:(NSDate *)date;

+ (NSDate *)nextDateFromNowWithDayOfMonth:(NSInteger)day;
+ (NSDate *)nextDateFromNowWithDayOfWeek:(NSUInteger)day;

+ (NSString *)dayOfTheWeekName:(NSUInteger)day;

#pragma mark - Text Masking

+ (void) logCharacterSet:(NSCharacterSet*)characterSet;

+ (NSArray *)charactersInMask:(NSString *)mask;

+ (NSString *)stringWithoutMask:(NSString *)string
						   mask:(NSString*)mask;

+ (NSString *)maskSubstringToFirstInputElement:(NSString *)mask;

+ (NSString *)stringByApplyingMask:(NSString*)iFaceMask
						  toString:(NSString*)string;

+ (NSString *)stringForMask:(NSString *)maskString
			availableString:(NSString *)availableString
				  newString:(NSString *)newString;

+ (NSString *)stringPhoneDialFromString:(NSString*)string;
+ (NSString *)stringWithAdd7PhoneString:(NSString *)phoneString;  //89161234567 -> +79161234567

#pragma mark - Text Formatting

+ (NSString *)unformattedStringForPhone:(NSString *)phone;
+ (CGSize)correctAttributedStringSize:(CGSize)size;
+ (NSString *)formattedCardNumberString:(NSString *)string;


#pragma mark - Trimm text

+ (NSString *)trimmedText:(NSString *)text;
+ (NSString *)serviceNameFromURLString:(NSString *)url;
+ (NSString *)parameterValue:(NSString *)parameter fromURLString:(NSString *)urlString;
+ (void)removeEmojiFromTextInTextView:(UITextView *)textView;


#pragma mark - Regexp validation

+ (BOOL)isString:(NSString *)string
isValidWithRegexp:(NSString *)regExp
	  isRequired:(BOOL)isRequired;

#pragma mark - Summ Formatting

+ (NSUInteger)numberOfPartsForMoneyAmountString:(NSString *)amountString;
+ (BOOL)hasAmountFractionDigits:(Float64)amount;                    //Проверка на копейки 00
+ (BOOL)hasAmountFractionDigits4:(Float64)amount;                   //Проверка на копейки 0000
+ (NSString *)amountAsFormattedString:(Float64)amount;              //Метод возвращает строковое значение amount без дробной части, если она равна 0
+ (NSString *)amountWholeDigits:(Float64)amount;                    //Целая часть
+ (NSString *)amountFractionDigits:(Float64)amount;                 //Дробная часть
+ (NSString *)amountFractionDigits4:(Float64)amount;                //Дробная часть с точностью 4 для курса валют
+ (NSString *)amountAsString:(Float64)amount;
+ (NSString *)amountAsStringForCommission:(Float64)amount;
+ (NSString *)setSummDecimalSeparator:(NSString *)amountString;
+ (NSString *)fixDecimalSeparator:(NSString *)decimalString;
+ (NSNumber *)nonFormatAmount:(NSString *)amountString;
+ (NSString *)nonFormatAmountString:(NSString *)amountString;
+ (NSString *)formatInputSumm:(NSString *)aTextFieldString string:(NSString *)string range:(NSRange)range;//ввод суммы
+ (NSString *)formatInputSumm:(NSString *)nonFormatAmountString oldString:(NSString *)oldString;//ввод суммы

#pragma mark - Map cluster objects

+ (NSString *)stringFromNumber:(NSInteger)number strOne:(NSString *)strOne strSeveral:(NSString *)strSeveral strLot:(NSString *)strLot;
+ (NSString *)stringForObjectsGroup:(NSInteger)value;

#pragma mark - Card Type

+ (ABP2PCardType)cardTypeByCardNumberString:(NSString *)cardNumber;
+ (NSArray *)cardNumberChunksWithCardNumber:(NSString *)cardNumber;

#pragma mark - String is Substring

+ (BOOL)searchString:(NSString *)searchString inString:(NSString *)inString;
+ (BOOL)searchString:(NSString *)searchString inString:(NSString *)inString matchingCase:(BOOL)matchingCase;
+ (BOOL)isStringNumeric:(NSString *)string;

#pragma mark - Image masking

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (void)addImageAsMask:(UIImage *)maskImage toView:(UIView *)view;

+ (UIImage *)maskedImage:(UIImage *)imageToAddMask
		   withMaskImage:(UIImage *)maskImage
			 contentMode:(UIViewContentMode)contentMode;

#pragma mark Image to Base64

+ (NSString *)imageToString:(UIImage *)image;

#pragma mark - UIImage from crop rect

+ (UIImage *)fixOrientation:(UIImage*)image;
+ (UIImage *)cuttedImageFromImage:(UIImage*)image withRect:(CGRect)rect;
+ (UIImage *)squareImageFromCenterOfImage:(UIImage *)image;

#pragma mark - Distance
+ (NSString *)formatDistance:(double)dist;

#pragma mark Color gradient

+ (UIColor*)colorWithVerticalGradientStart:(float)sr
										 G:(float)sg
										 B:(float)sb
										 A:(float)sa
									  endR:(float)er
										 G:(float)eg
										 B:(float)eb
										 A:(float)ea
								   forSize:(CGSize)size;

#pragma mark AddressBook

+ (BOOL)addressBookAccessGranted;

#pragma mark - Facebook

+ (void)clearFacebookCookies;

#pragma mark - VK

+ (void)clearVKCookies;

#pragma mark - Encoding

+ (NSStringEncoding)stringEncodingWithName:(NSString*)stringEncodingName;

#pragma mark - Error logging format

+ (NSString *)dictionaryToStringInLoggerFormat:(NSDictionary *)dictionary;

#pragma mark - Card validation

+ (BOOL)cardNubmerLuhnCheck:(NSString *)cardNumber;
+ (BOOL)cardExpCheckWithString:(NSString *)cardExp;
+ (BOOL)cardExpCheckWithDate:(NSDate *)cardExp;

+ (NSString *)numberForRussian:(NSNumber *)number ;

+ (NSString*)sha256HashFor:(NSString*)input;

@end