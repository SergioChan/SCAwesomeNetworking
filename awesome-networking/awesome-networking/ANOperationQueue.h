//
//  ANOperationQueue.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANOperationQueue : NSOperationQueue

- (BOOL)cancelOperationByOperationId:(NSInteger)operationId;

- (NSArray *)getAllOperations;

+ (ANOperationQueue *) sharedInstance;

@end
