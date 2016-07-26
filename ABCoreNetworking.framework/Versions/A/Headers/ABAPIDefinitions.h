//
//  APIDefinitions.h

#pragma mark Known Host Domain Names

	//prod
#define kDomainNameProd		@"api.temaslizhik.com"

#define kDomainPathV1		@"v1"


#pragma mark -
#pragma mark API Services Names

//
//
//4x
//
//
#pragma mark -
#pragma mark API Parameter Keys

#define kResultCode									@"resultCode"
#define kErrorMessage								@"errorMessage"
#define kAppVersion									@"appVersion"
#define kPayload									@"payload"
#define kKey										@"key"
#define kParams										@"params"
#define kRequestsData								@"requestsData"
#define kOperation									@"operation"

#define kPlatform									@"platform"

#define kSessionid									@"sessionid"
#define kSessionId									@"sessionId"
#define kSessionTimeout								@"sessionTimeout"

#define API_groupedRequests				            @"grouped_requests"


#pragma mark - Other Keys

extern NSString *const ABKeyResponse;
extern NSString *const ABKeyHandler;
extern NSString *const ABKeyError;


///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark API Result Codes

#define kResultCode_OK								@"OK"
#define kResultCode_ERROR							@"ERROR"


extern NSString *const ABErrorDomainAPI;

typedef NS_ENUM(NSUInteger, ABResponseCode)
{
    ABResponseCodeOK                           = 0,
    ABResponseCodeServerError                  = 1,
    ABResponseCodeError                        = 100
};

typedef void (^ABCommonHandler)(BOOL success, NSError *error);

	// Userinfo contains objects for "response", "handler" and "error" keys
	//		"response" - NSDictionary contains server response with confirmation info (confirmation type,
	//					 initialOperationTicket, etc.). This info is used to instantiate ABConfirmationInfo object
	//		"handler" - (void)(^)(BOOL success, id response, NSError *error) - block that should be performed
	//					when confirmation is handled.
	//						success - either confirmation was successful or not;
	//						response - server response in case of successful confirmation passing;
	//						error - error object, if something unexpected happend during confirmation
	//		"error" - error that happened when requesting initial operation

extern NSString *const ABNotificationResponseNeedsProcessing;



//Temp session
#define kTempSessionTimeout 60
