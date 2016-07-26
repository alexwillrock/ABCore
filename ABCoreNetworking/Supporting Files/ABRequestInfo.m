//
//  ABRequestInfo.m
//  ABCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import "ABRequestInfo.h"

@implementation ABRequestInfo

@synthesize url = _url;
@synthesize bytes = _bytes;

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n\n Request info log URL: %@ \n %@ \n\n", self.url, [NSByteCountFormatter stringFromByteCount:[self.bytes integerValue] countStyle:NSByteCountFormatterCountStyleFile]];
}

@end
