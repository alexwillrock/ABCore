//
//  ABParseResponseHandler.h
//  ABCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkOperation.h"
#import "ABRequest.h"

@class ABError;

@protocol ABParseResponseHandlerDelegate <NSObject>
@optional
- (void)parseJSONResponseFromRequest:(ABRequest *)request
				   completionHandler:(void (^)(BOOL success, NSError *error))complete;
- (NSArray *)balanceAffectingAPIMethods;

@end

@interface ABParseResponseHandler : NSObject

@property (nonatomic, weak) id<ABParseResponseHandlerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * requestsQueue;
@property (nonatomic, strong) NSArray * requestsArray;
@property (nonatomic, readonly, strong) MKNetworkOperation * operation;

@property (nonatomic, copy) void(^onCompletion)(MKNetworkOperation * operation, id responseObject, NSError *error);
@property (nonatomic, copy) void(^onSuccess)(MKNetworkOperation * operation, id responseObject);
@property (nonatomic, copy) void(^onFailure)(MKNetworkOperation * operation, ABError * error);

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<ABParseResponseHandlerDelegate>)delegate
		   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
		   failureBlock:(void (^)(MKNetworkOperation * operation, ABError * error))onFailure;

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<ABParseResponseHandlerDelegate>)delegate
	  onCompletionBlock:(void (^)(MKNetworkOperation * operation, id responseObject, NSError * error))onCompletionBlock;

- (void)parseResponse;

@end
