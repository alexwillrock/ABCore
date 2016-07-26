//
//  ABP2PBaseObject.h
//  ABP2P
//
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABBaseObject : NSObject
{
	NSDictionary *_dictionary;
}
@property (nonatomic, strong) NSDictionary * dictionary;

- (id)initWithDictionary:(NSDictionary*)dictionary;
- (void)clearAllProperties;
@end
