//
//  ABP2PBaseObject.m
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABBaseObject.h"

@implementation ABBaseObject
@synthesize dictionary = _dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (![dictionary count]) { return nil; }

	self = [super init];
	if (!self) { return nil; }

	_dictionary = dictionary;
	return self;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
	[self clearAllProperties];
	_dictionary = dictionary;
}

- (void)clearAllProperties
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wselector"
	ALog(@"%@ method not implemented in class %@",	NSStringFromSelector(_cmd), NSStringFromClass([self class]));
#pragma clang diagnostic pop
}

-(BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[self class]]) { return NO; }

	ABBaseObject *objectAsBaseObject = (ABBaseObject*)object;
	return [self.dictionary isEqualToDictionary:objectAsBaseObject.dictionary];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ object with data:\n%@", [self class], _dictionary];
}

@end
