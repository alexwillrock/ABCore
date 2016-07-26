//
//  ABError.h
//  ABCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABBaseObject.h"

@interface ABError : ABBaseObject

+ (ABError *)walletErrorFromCommonError:(NSError *)error;

@property (nonatomic, strong, readonly) NSString *errorMessage;
@property (nonatomic, strong, readonly) NSString *initialOperation;
@property (nonatomic, strong, readonly) NSString *operationTicket;
@property (nonatomic, strong, readonly) NSDictionary *payload;
@property (nonatomic, strong, readonly) NSString *resultCode;

@end
