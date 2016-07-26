//
//  ABRequestInfo.h
//  ABCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2015 "Appzavr" Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ABRequestInfo : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *bytes;

@end
