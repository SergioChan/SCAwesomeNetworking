//
//  ANOperationQueue.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANOperationQueue.h"

@implementation ANOperationQueue

+ (ANOperationQueue *) sharedInstance
{
    static dispatch_once_t  onceToken;
    static ANOperationQueue * sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ANOperationQueue alloc] init];
    });
    return sharedInstance;
}

- (BOOL)cancelOperationByOperationId:(NSInteger)operationId
{
    return NO;
}

- (NSArray *)getAllOperations
{
    return nil;
}

@end
