//
//  ABP2PRequest.m
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABRequest.h"

@implementation ABRequest
@synthesize path           = _path;
@synthesize requestKey     = _requestKey;
@synthesize parameters     = _parameters;
@synthesize responseObject = _responseObject;
@synthesize payload        = _payload;
@synthesize error          = _error;

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p> path=%@ requestKey=%@\nparameters=%@\nresponseObject=%@\n-----------\nerror=%@", [self class], self, _path, _requestKey, _parameters, _responseObject, _error];
}

@end
