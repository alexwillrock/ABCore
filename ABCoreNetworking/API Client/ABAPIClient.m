//
//  ABAPIClient.m

#import "ABAPIClient.h"
#import "UIImage+CS_Extensions.h"
#import "NSDictionary+RequestEncoding.h"
#import "ABNetworkLogger.h"

@interface ABAPIClient ()

@end

@implementation ABAPIClient

NSString *const ABNotificationResponseNeedsProcessing = @"ABNotificationResponseNeedsProcessing";

NSString *const ABKeyResponse = @"response";
NSString *const ABKeyHandler  = @"handler";
NSString *const ABKeyError	   = @"error";

NSString *const ABErrorDomainAPI = @"com.appzavr.api";

NSString *const ABAPIClientMethodGET  = @"GET";
NSString *const ABAPIClientMethodPOST = @"POST";

@synthesize arrayOfOperationsToEnqueue = _arrayOfOperationsToEnqueue;
@synthesize balanceAffectingAPIMethods = _balanceAffectingAPIMethods;




#pragma mark -
#pragma mark - Creation

+ (id)sharedInstance
{
	static dispatch_once_t pred = 0;
	__strong static id _sharedObjectABAPIClient = nil;

	dispatch_once(&pred,
				  ^{
					  _sharedObjectABAPIClient = [[self alloc] init];
					  if ([NSStringFromClass([self class]) isEqualToString:@"ABAPIClient"])
					  {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
						  ALog(@"Wrong initialization of ABAPIClient in %@",NSStringFromSelector(_cmd));
#pragma clang diagnostic pop
					  }
				  });

	return _sharedObjectABAPIClient;
}

- (id)init
{
	NSMutableDictionary * headerFields = [NSMutableDictionary dictionary];
	[headerFields setObject:@"text/html,application/xhtml+xml,application/json,application/xml;q=0.9,*/*;q=0.8" forKey:@"Accept"];
	[headerFields setObject:@"gzip,deflate" forKey:@"Accept-Encoding"];
	[headerFields setObject:@"keep-alive" forKey:@"Connection"];

	if (self = [super initWithHostName:[[self class] domainName]
							   apiPath:[[self class] domainPath]
					customHeaderFields:headerFields])
	{
		_arrayOfOperationsToEnqueue = [NSMutableArray array];

		[self useCache];
	}

	return self;
}




#pragma mark -
#pragma mark - ABAPIClientCustomization

+ (BOOL)useSSL {
	return YES;
}

+ (NSString *)domainName
{
	return @"Should override + (NSString *)domainName method!";
}

+ (NSString *)domainPath
{
	return @"Should override + (NSString *)domainPath method!";
}

- (NSString *)sessionId
{
	return nil;
}

- (NSDictionary*)additionalCommonParameters
{
	NSString * appVersion = [ABUtils appVersionAndBuildNumberString];
	NSString * platform = [ABUtils platform];

	NSDictionary * commonParameters = @{ kAppVersion : appVersion,
										 kPlatform	 : platform };
	return commonParameters;
}

- (NSArray *)resultCodesSuccess {
	return @[];
}

- (NSArray *)resultCodesNeedProcessing {
	return @[];
}


#pragma mark -
#pragma mark - Creating Request Operation

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   onCompletion:(void (^)(MKNetworkOperation *, id, NSError *))onCompletionBlock
{
	NSMutableDictionary * parametersToSpacifyInPath = [NSMutableDictionary dictionary];

	if (shouldInject)
	{
		[parametersToSpacifyInPath addEntriesFromDictionary:self.additionalCommonParameters];
	}

	if (addSessionId)
	{
		NSString * sessionId = [self sessionId];
		if (sessionId && sessionId.length > 0) {
			parametersToSpacifyInPath[kSessionid] = sessionId;
		} else {
			DLog(@"\n\n\n***\nNO SESSION ID PROVIDED IN REQUEST FOR: %@!\n***\n\n\n", path);
		}
	}

	if (parametersToSpacifyInPath.allKeys.count > 0)
	{
		path = [NSString stringWithFormat:@"%@?%@", path, [parametersToSpacifyInPath urlEncodedKeyValueString]];
	}

	MKNetworkOperation * networkOperation = [super operationWithPath:path params:body httpMethod:method ssl:[[self class] useSSL]];

	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
#ifdef DEBUG_LOG
		 [ABAPIClient printLog:completedOperation];
#endif
		 ABParseResponseHandler * parseResponseHandler = [[ABParseResponseHandler alloc] initWithOperation:completedOperation
																							   parseDelegate:self
																						   onCompletionBlock:onCompletionBlock];

		 [parseResponseHandler parseResponse];
         

	 }
							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
#ifdef DEBUG_LOG
		 [ABAPIClient printLog:completedOperation];
#endif
		 onCompletionBlock(completedOperation, nil, error);
	 }];

	//отменяем предыдущую операцию с полностью совпадающим адресом запроса
//	DLog(@"HASH: %d",networkOperation.hash);
	[MKNetworkEngine cancelOperationsContainingURLString:networkOperation.readonlyRequest.URL.absoluteString];

	return networkOperation;
}

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
								   failureBlock:(void (^)(MKNetworkOperation * operation, ABError * error))onFail
{

	NSMutableDictionary * parametersToSpacifyInPath = [NSMutableDictionary dictionary];

	if (shouldInject)
	{
		[parametersToSpacifyInPath addEntriesFromDictionary:self.additionalCommonParameters];
	}

	if (addSessionId)
	{
		NSString * sessionId = [self sessionId];
		if (sessionId && sessionId.length > 0)
		{
			parametersToSpacifyInPath[kSessionid] = sessionId;
		}else
		{
			DLog(@"\n\n\n***\nNO SESSION ID PROVIDED IN REQUEST FOR: %@!\n***\n\n\n", path);
		}
	}

	if (parametersToSpacifyInPath.allKeys.count > 0)
	{
		path = [NSString stringWithFormat:@"%@?%@", path, [parametersToSpacifyInPath urlEncodedKeyValueString]];
	}

	MKNetworkOperation * networkOperation = [super operationWithPath:path params:body httpMethod:method ssl:[[self class] useSSL]];

	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
#ifdef DEBUG_LOG
		 [ABAPIClient printLog:completedOperation];
#endif
		 ABParseResponseHandler * parseResponseHandler = [[ABParseResponseHandler alloc] initWithOperation:completedOperation
																							   parseDelegate:self
																								successBlock:onSuccess
																								failureBlock:onFail];


		 [parseResponseHandler parseResponse];

	 }
							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
#ifdef DEBUG_LOG
		 [ABAPIClient printLog:completedOperation];
#endif
		 if (onFail)
		 {
			 onFail(completedOperation, [ABAPIClient appzavrErrorFromError:error]);
		 }
	 }];

	//отменяем предыдущую операцию с полностью совпадающим адресом запроса
	//	DLog(@"HASH: %d",networkOperation.hash);
	[MKNetworkEngine cancelOperationsContainingURLString:networkOperation.readonlyRequest.URL.absoluteString];

	return networkOperation;
}




#pragma mark -
#pragma mark - Performing Service Request

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
parametersInjection:(BOOL)shouldInject
addSessionId:(BOOL)addSessionId
	 success:(void (^)(MKNetworkOperation * completedOperation, id responseObject))success
	 failure:(void (^)(MKNetworkOperation * completedOperation, ABError *error))failure
{
	void (^enqueueOperation)() = ^
	{

		MKNetworkOperation * networkOperation = [self parsedOperationWithPath:path
																	   params:parameters
																   httpMethod:method
														  parametersInjection:shouldInject
																 addSessionId:addSessionId
																 successBlock:success
																 failureBlock:failure];

		[self enqueueOperation:networkOperation];
	};

	if (shouldInject && [self shouldKeepRequestCreationBlockInQueueCondition])
	{
		[_arrayOfOperationsToEnqueue addObject:[enqueueOperation copy]];
	}
	else
	{
		enqueueOperation();
	}
}

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
  parametersInjection:(BOOL)shouldInject
		 addSessionId:(BOOL)addSessionId
		 onCompletion:(void (^)(MKNetworkOperation * completedOperation, id responseObject, NSError * error))onCompletionBlock
{
	void (^enqueueOperation)() = ^
	{
		MKNetworkOperation * networkOperation = [self parsedOperationWithPath:path
																	   params:parameters
																   httpMethod:method
														  parametersInjection:shouldInject
																 addSessionId:addSessionId
																 onCompletion:onCompletionBlock];

		[self enqueueOperation:networkOperation];
	};

	if (shouldInject && [self shouldKeepRequestCreationBlockInQueueCondition])
	{
		[_arrayOfOperationsToEnqueue addObject:[enqueueOperation copy]];
	}
	else
	{
		enqueueOperation();
	}
}

#pragma mark -
#pragma mark - Response parsing

- (void)parseJSONResponse:(ABRequest *)request
				onSuccess:(void(^)())success
				   onFail:(void(^)(ABError * error))fail
{
	ALog(@"Метод %@ в классе %@ должен быть переопределен!", NSStringFromSelector(_cmd), NSStringFromClass([self class]));
}

- (void)parseJSONResponseFromRequest:(ABRequest *)request
				   completionHandler:(void (^)(BOOL, NSError *))onCompletion
{
	DAssert(onCompletion, @"Completion handler is mandatory");
	
	id responseObject = request.responseObject;
	DAssert(!onCompletion || [responseObject isKindOfClass:[NSDictionary class]], @"Expecting that response is a kind of NSDictionary, responseObject: %@", responseObject);
	
	NSString *resultCode = [responseObject valueForKey:kResultCode];
	NSError  *error		 = [[self class] errorFromResponseObject:responseObject];
	
    request.error   = error;
    request.payload = responseObject[kPayload];
	
	if ([[self resultCodesSuccess] containsObject:resultCode])
	{
		onCompletion(YES, nil);
	}
	else if ([[self resultCodesNeedProcessing] containsObject:resultCode])
	{
		void (^handler)(BOOL, id, NSError *) = ^(BOOL success, id handlerResponseObject, NSError *handlerError)
		{
			request.responseObject = handlerResponseObject;
			onCompletion(success, handlerError);
		};
		
		NSDictionary *userInfo = @{ ABKeyResponse : responseObject,
									ABKeyHandler  : handler,
									ABKeyError	   : error };
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:ABNotificationResponseNeedsProcessing
										  object:self
										userInfo:userInfo];
	}
	else
	{
		onCompletion(NO, error);
	}
}




#pragma mark -
#pragma mark - Requests Queueing

- (BOOL)shouldKeepRequestCreationBlockInQueueCondition
{
	return NO;
}

- (void)performBlocksInQueue
{
	for (void (^ enqueueOperationBlock)() in _arrayOfOperationsToEnqueue)
	{
		enqueueOperationBlock();
	}

	[_arrayOfOperationsToEnqueue removeAllObjects];
}




#pragma mark -
#pragma mark - Helpers

+ (NSString *)messageFromError:(NSError *)error
{
	NSString * errorString = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

	if (errorString == nil)
	{
		errorString = LOC(@"error.connectionError");
	}

	return errorString;
}

+ (void)printLog:(MKNetworkOperation *)operation
{
	dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

		DLog(@"\n**************************************************\n");
		DLog(@"\nOperation:\n%@",[operation description]);
		DLog(@"\n**************************************************\n");

		if ([operation isCachedResponse])
		{
			DLog(@"\n**************************************************\n");
			DLog(@"\n***********Запрос из кэша*************************\n");
			DLog(@"\n**************************************************\n");
		}

	});
}

+ (ABError *)appzavrErrorFromError:(NSError *)error
{
    NSString * errorString = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

	if(!errorString)
	{
        if ([error code])
        {
            errorString = [NSString stringWithFormat:LOC(@"error.networkErrorWithCode"),[error code]];
        }
        else
        {
            errorString = [error description];
        }
	}

	ABError *abError = [[ABError alloc] initWithDictionary: errorString ? @{kErrorMessage : errorString} : [NSDictionary dictionary]];

    return abError;
}

+(ABError *)tcsErrorWithMessage:(NSString *)message
{
    ABError *error = [[ABError alloc] initWithDictionary:@{kErrorMessage : message}];
    return error;
}

+ (NSError *)errorFromResponseObject:(id)object
{
	if (![object isKindOfClass:[NSDictionary class]]) { return nil; }
	
	NSDictionary *response = (NSDictionary *)object;
	
	static NSDictionary *resultCodeTranslator = nil;
	
	if (!resultCodeTranslator)
	{
		resultCodeTranslator = @{
								 kResultCode_OK		: @(ABResponseCodeOK),
								 kResultCode_ERROR	: @(ABResponseCodeError),
								 @"restCode"		: @(ABResponseCodeError),
								 };
	}
	
	NSNumber *resultCodeNum = resultCodeTranslator[response[kResultCode]];
//	DAssert(resultCodeNum, @"Unknown resultCode"); // TODO: uncomment and handle
	
	NSInteger resultCode = [resultCodeNum integerValue];
	if (resultCode == ABResponseCodeOK) { return nil; } // Unknown result codes will be handled as exceptions in Debug mode and as "no error" in production
	
	NSError *error = [NSError errorWithDomain:ABErrorDomainAPI
										 code:resultCode
									 userInfo:object];
	return error;
}



#pragma mark -
#pragma mark - Download Image

- (MKNetworkOperation *)imageAtURL:(NSURL *)url completionHandler:(MKNKImageBlock)imageFetchedBlock errorHandler:(MKNKResponseErrorBlock)errorBlock
{
	return [super imageAtURL:url size:CGSizeZero completionHandler:imageFetchedBlock errorHandler:errorBlock];
}

- (MKNetworkOperation *)imageAtURL:(NSURL *)url size:(CGSize)size completionHandler:(MKNKImageBlock)imageFetchedBlock errorHandler:(MKNKResponseErrorBlock)errorBlock
{
	size = [ABUtils sizeAccordingToRetina:size];
	return [super imageAtURL:url size:size completionHandler:imageFetchedBlock errorHandler:errorBlock];
}

#pragma mark -
#pragma mark - Network Logger

#ifdef AB_NETWORK_LOGGING

- (void)enqueueOperation:(MKNetworkOperation *)operation forceReload:(BOOL)forceReload
{
    void (^operationChangeStateCopy)(MKNetworkOperationState) = [operation.operationStateChangedHandler copy];
    
    __weak MKNetworkOperation *weakOperation = operation;
    
    [operation setOperationStateChangedHandler:^(MKNetworkOperationState state)
     {
         if (state == MKNetworkOperationStateFinished)
         {
             [[ABNetworkLogger sharedInstance] logDoneOperation:weakOperation];
         }
         
         if (operationChangeStateCopy)
         {
             operationChangeStateCopy(state);
         }
         
     }];
    
    [super enqueueOperation:operation forceReload:forceReload];
}

#endif

@end
