//
//  ABNetworkLogger.h
//  ABCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABSingleton.h"

#define AB_NETWORK_LOGGING

@class NSArray, NSMutableArray, MKNetworkOperation, ABRequestInfo;

@interface ABNetworkLogger : ABSingleton

@property (nonatomic, strong) NSMutableArray *requestsInfo; // ABRequestInfo

- (void)logDoneOperation:(MKNetworkOperation *)operation;

- (ABRequestInfo *)heaviestRequest;
- (NSArray *)requestsInfoSortedByDESC;

- (void)printTotalUsage;

@end
