
#ifndef ABCore_ABConstants_h
#define ABCore_ABConstants_h


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Time Formatting

#define kMillisecondsMultiplier						1000.0f

///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TextField Constants

#define kDefaulNumberCharatersPerCardNumberChunk    4
#define kDefaulMaxCardNumberCharaters               16
#define kMaestroMaxCardNumberCharaters              22
#define kMaestroNumberCharatersPerCardNumberChunk   8

#define kNewLineCharacter                           @"\n"
#define kWhitespaceCharacter                        @" "
#define kPositiveIntegerRegExp                      @"^([1-9]\\d*+(\\.[0-9]{1,2})?)|(0\\.[0-9]{1,2})$"
#define kCardExpirityDateRegExp                     @"(0[1-9]|1[0-2])\\/[0-9]{2}"
#define kMonthYearMask                              @"MM.YYYY"
#define kDayMonthYearMask                           @"dd.MM.YYYY"
#define kExtendedDateForrmat                        @"d MMMM yyyy 'г.'"
#define kIssueAuthorityCodeRegExp                   @"^\\d{3}\\d{3}$"
#define kItinRegExp                                 @"^\\d{12}$"
#define kServerDateFormat                           @"yyyy-MM-dd HH:mm:ss"


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Decimal Separators

#define kSummDecimalSeparator						@","
#define kSummMachineDecimalSeparator				@"."
#define kSummGroupingSeparator						@" "


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Operation Direction sign

#define kOperationTypeDebitSign						@"-"
#define kOperationTypeCreditSign					@"+"


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Char Identifiers

#define kBackspaceIdentifier						-8
#define kEmptyString								@""


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Avatar size

#define kMaxAvatarImageSize					CGSizeMake(640, 640)
#define kAvatarMaxSizeInBytes				6000000

///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications

#define kNotificationBalanceAffected		@"NotificationBalanceAffected"


// Mobile bank defines
#define kButtonHeightDefault						44.0f


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fonts

#define kFontBebas							@"Bebas Neue Cyrillic"
#define kFontHelveticaNeue					@"HelveticaNeueLTCYR-Cond"
#define kFontHelveticaNeueBold				@"HelveticaNeue-CondensedBold"

#pragma mark -
#pragma mark Identification State

#define kIdentificationNotIdentified 0
#define kIdentificationFullIdentified 1
#define kIdentificationShortIdentified 23

	///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Common Errors

extern NSString *const ABErrorDomain;

typedef NS_ENUM(NSInteger, ABErrorCode)
{
    ABErrorCodeNone            = 0,
    ABErrorCodeInvalidArgument = 1,
    ABErrorCodeEmptyResult     = 2,
    ABErrorCodeCanceledByUser  = 3
};


#endif




