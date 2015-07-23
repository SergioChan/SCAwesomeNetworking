//
//  ANOperation.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANOperation.h"

@implementation ANOperation

@synthesize operationId;
@synthesize timestamp;

#pragma mark - Coding method
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    self.operationId = [[decoder decodeObjectForKey:@"id"] integerValue];
    self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[NSNumber numberWithInteger:operationId] forKey:@"id"];
    [coder encodeObject:timestamp forKey:@"timestamp"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ANOperation *operation = [super copyWithZone:zone];
    
    operation.operationId = self.operationId;
    operation.timestamp = self.timestamp;
    
    return operation;
}

- (instancetype)initWithOperation:(AFHTTPRequestOperation *)op
{
    if(op)
    {
        self = [super init];
        if (self)
        {
            self = [(ANOperation *)op copy];
            self.operationId = (NSInteger)[[NSDate date] timeIntervalSince1970];
            self.timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        }
        return self;
    }
    else
    {
        return nil;
    }
}
@end
