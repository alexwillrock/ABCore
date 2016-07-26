//
//  NSStream+BoundPairAdditions.h
//  BYNetwork
//
//  Created by Boyd Yang on 10/31/12.
//  Copyright (c) 2012 xxx Co.,Inc. All rights reserved.
//

@import Foundation;

@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;

@end
