//
//  ABNetworkLogger.m
//  ABCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABNetworkLogger.h"

@import Foundation;

#import "ABRequestInfo.h"
#import "MKNetworkOperation.h"

@implementation ABNetworkLogger

@synthesize requestsInfo = _requestsInfo;

- (NSMutableArray *)requestsInfo
{
    if (!_requestsInfo)
    {
        _requestsInfo = [NSMutableArray new];
    }
    
    return _requestsInfo;
}

- (void)logDoneOperation:(MKNetworkOperation *)operation
{
    if (operation.isCachedResponse)
    {
        return;
    }
    
    ABRequestInfo *requestInfo = [ABRequestInfo  new];
    
    requestInfo.url = operation.url;
    
    SEL selector = NSSelectorFromString(@"downloadedDataSize");
    NSUInteger (*implFunction)(id, SEL) = (void *)[operation methodForSelector:selector];
    NSUInteger dataSize = implFunction(operation, selector);
    
    requestInfo.bytes = @(dataSize);
    
    [self.requestsInfo addObject:requestInfo];
    
    DLog(@"Logged operation with %@", requestInfo);
}

- (ABRequestInfo *)heaviestRequest
{
    NSArray *heaviestRequest = [self.requestsInfo sortedArrayUsingComparator:^NSComparisonResult(ABRequestInfo *obj1, ABRequestInfo *obj2)
    {
        return [obj1.bytes compare:obj2.bytes];
    }];
    
    return [heaviestRequest lastObject];
}

- (void)printTotalUsage
{
    NSNumber *totalUsage = [self.requestsInfo valueForKeyPath:@"@sum.bytes"];
    
    DLog(@"%@", [NSByteCountFormatter stringFromByteCount:[totalUsage integerValue] countStyle:NSByteCountFormatterCountStyleFile]);
}

- (NSArray *)requestsInfoSortedByDESC
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bytes" ascending:NO];
    
    NSArray *requestsInfoSortedByDESC = [self.requestsInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return requestsInfoSortedByDESC;
}

@end
