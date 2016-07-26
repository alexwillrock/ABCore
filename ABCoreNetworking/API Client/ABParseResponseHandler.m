//
//  ABParseResponseHandler.m
//  ABCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABParseResponseHandler.h"
#import "ABAPIClient.h"

@interface ABParseResponseHandler ()
@end



@implementation ABParseResponseHandler
@synthesize delegate = _delegate;
@synthesize requestsArray = _requestsArray;
@synthesize operation = _operation;
@synthesize requestsQueue = _requestsQueue;
@synthesize onCompletion = _onCompletion;
@synthesize onSuccess = _onSuccess;
@synthesize onFailure = _onFailure;

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<ABParseResponseHandlerDelegate>)delegate
	  onCompletionBlock:(void (^)(MKNetworkOperation *, id, NSError *))onCompletionBlock
{
	if (self = [super init])
	{
		_operation = operation;
		self.delegate = delegate;
		self.onCompletion = onCompletionBlock;
	}

	return self;
}

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<ABParseResponseHandlerDelegate>)delegate
		   successBlock:(void (^)(MKNetworkOperation *, id))onSuccess
		   failureBlock:(void (^)(MKNetworkOperation *, ABError *))onFailure
{
	if (self = [super init])
	{
		_operation = operation;
		self.delegate = delegate;
		self.onSuccess = onSuccess;
		self.onFailure = onFailure;
	}

	return self;
}

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<ABParseResponseHandlerDelegate>)delegate
		  completeBlock:(void (^)(MKNetworkOperation *, id, NSError *))onComplete
{
	if (self = [super init])
	{
		_operation = operation;
		self.delegate = delegate;
		self.onCompletion = onComplete;
	}
	
	return self;
}


- (void)parseResponse
{
	NSString *apiService = [ABUtils serviceNameFromURLString:_operation.url];
	id responseObject = _operation.responseJSON;

	ABRequest *mainRequest = [ABRequest new];
    [mainRequest setParameters:[NSMutableDictionary dictionaryWithDictionary:_operation.readonlyPostDictionary]];
	[mainRequest setResponseObject:responseObject];
    [mainRequest setPath:apiService];
	[[self requestsQueue] addObject:mainRequest];

	if ([apiService isEqualToString:API_groupedRequests])
	{
		NSDictionary * includedResponseDictionary = [responseObject objectForKey:kPayload];

		for (NSString * requestKey in includedResponseDictionary)
		{
			ABRequest * includedRequest = [ABRequest new];
			[includedRequest setRequestKey:requestKey];
			[includedRequest setResponseObject:[includedResponseDictionary objectForKey:requestKey]];
			
			[[self requestsQueue] addObject:includedRequest];
		}
	}

	self.requestsArray = [NSArray arrayWithArray:self.requestsQueue];

	[self checkIfOperationContainsBalanceAffectingServices:_operation];

	[self startNextParseIteration];
}

- (void)checkIfOperationContainsBalanceAffectingServices:(MKNetworkOperation *)operation
{
	NSMutableArray * servicesArray = [NSMutableArray array];

	NSString * operationService = [ABUtils serviceNameFromURLString:_operation.url];

	[servicesArray addObject:operationService];

	if ([operationService isEqualToString:API_groupedRequests])
	{
		NSString *requestsData = [[ABUtils parameterValue:kRequestsData fromURLString:_operation.url] urlDecodedString];
		NSData *data = [requestsData dataUsingEncoding:NSUTF8StringEncoding];

		NSError *error = nil;
		NSArray *requestsDataObjects = data ? [NSJSONSerialization JSONObjectWithData:data
																			  options:NSJSONReadingMutableContainers
																				error:&error] : nil;
		if (!error)
		{
			for (NSDictionary * requestDictionary in requestsDataObjects)
			{
				[servicesArray addObject:[requestDictionary objectForKey:kOperation]];
			}
		}
	}
    __strong id<ABParseResponseHandlerDelegate> strongDelegate = _delegate;
	if (strongDelegate)
	{
		NSArray * balanceAffectingAPIMethods = [strongDelegate balanceAffectingAPIMethods];

		for (NSString * method in servicesArray)
        {
            if ([balanceAffectingAPIMethods containsObject:method])
			{
				__weak void(^weakOnSuccessBlock)(MKNetworkOperation * requestOperation, id responseObject) = self.onSuccess;
				self.onSuccess = ^(MKNetworkOperation * requestOperation, id responseObject)
				{
                    __strong typeof(weakOnSuccessBlock) strongOnSuccessBlock = weakOnSuccessBlock;
                    if (strongOnSuccessBlock)
                    {
                        strongOnSuccessBlock(operation, responseObject);
                    }
                    
					[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBalanceAffected object:nil];
				};

				__weak void(^weakOnCompletionBlock)(MKNetworkOperation * requestOperation, id responseObject, NSError * error) = self.onCompletion;
				self.onCompletion = ^(MKNetworkOperation * requestOperation, id responseObject, NSError * error)
				{
                    __strong typeof(weakOnCompletionBlock) strongOnCompletionBlock = weakOnCompletionBlock;
                    if (strongOnCompletionBlock)
                    {
                        strongOnCompletionBlock(operation, responseObject, error);
                    }
                    
					[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBalanceAffected object:nil];
				};
				
				__weak void(^onCompleteBlock)(MKNetworkOperation *, id, NSError *) = self.onCompletion;
				self.onCompletion = ^(MKNetworkOperation * requestOperation, id responseObject, NSError *error)
				{
					onCompleteBlock(requestOperation, responseObject, error);
					[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBalanceAffected object:nil];
				};

				break;
			}
        }
	}

}

- (void)startNextParseIteration
{
	NSMutableArray *queue = self.requestsQueue;
	if (queue.count > 0)
	{
		ABRequest *request = [queue firstObject];
		[queue removeObject:request];

		id delegate = self.delegate;
		[delegate parseJSONResponseFromRequest:request
							 completionHandler:^(BOOL success, NSError *error) {
								 if (success) { request.error = nil; }
								 [self startNextParseIteration];
							 }];
	}
	else
	{
		ABRequest *mainRequest = self.requestsArray[0];
		if (mainRequest.error) {
			if (self.onFailure) { self.onFailure(_operation, [[ABError alloc] initWithDictionary:mainRequest.error.userInfo]); }
		} else {
			if (self.onSuccess) { self.onSuccess(_operation, mainRequest.responseObject); }
		}
		if (self.onCompletion) { self.onCompletion(_operation, mainRequest.responseObject, mainRequest.error); }
		
        self.onSuccess    = nil;
        self.onFailure    = nil;
        self.onCompletion = nil;
	}
}



#pragma mark Properties Helpers

- (NSMutableArray *)requestsQueue
{
	if (!_requestsQueue)
	{
		_requestsQueue = [NSMutableArray array];
	}

	return _requestsQueue;
}

@end
