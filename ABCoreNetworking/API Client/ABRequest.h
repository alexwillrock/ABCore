//
//  ABP2PRequest.h
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ABError.h"

@interface ABRequest : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *requestKey;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) id responseObject;

@property (nonatomic, strong) id payload;
@property (nonatomic, strong) NSError *error;

@end
