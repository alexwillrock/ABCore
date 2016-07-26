//
//  ABError.m
//  ABCore
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABError.h"

@implementation ABError

@synthesize errorMessage     = _errorMessage;
@synthesize initialOperation = _initialOperation;
@synthesize operationTicket  = _operationTicket;
@synthesize payload          = _payload;
@synthesize resultCode       = _resultCode;

+ (ABError *)walletErrorFromCommonError:(NSError *)error
{
	return [[self alloc] initWithDictionary:error.userInfo];
}


- (NSString *)description {
	return _dictionary[kErrorMessage];
}

-(void)clearAllProperties
{
    _errorMessage     = nil;
    _initialOperation = nil;
    _operationTicket  = nil;
    _payload          = nil;
    _resultCode       = nil;
}

-(NSString *)errorMessage
{
    if (!_errorMessage)
    {
        _errorMessage = _dictionary[kErrorMessage];
        
		if (!_errorMessage)
		{
			_errorMessage = LOC(@"title.errorMessageIsEmpty");
		}

    }
    
    return _errorMessage;
}

//-(NSString *)initialOperation
//{
//    if (!_initialOperation)
//    {
//        _initialOperation = _dictionary[kInitialOperation];
//    }
//    
//    return _initialOperation;
//}
//
//-(NSString *)operationTicket
//{
//    if (!_operationTicket)
//    {
//        _operationTicket = _dictionary[kOperationTicket];
//    }
//    
//    return _operationTicket;
//}

-(NSDictionary *)payload
{
    if (!_payload)
    {
        _payload = _dictionary[kPayload];
    }
    
    return _payload;
}

-(NSString *)resultCode
{
    if (!_resultCode)
    {
        _resultCode = _dictionary[kResultCode];
    }
    
    return _resultCode;
}

@end
