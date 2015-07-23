//
//  ANRequest.m
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "ANRequest.h"

@implementation ANRequest

@synthesize operation;
@synthesize category;
@synthesize tag;
@synthesize context;

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger:category] forKey:@"category"];
    [aCoder encodeObject:[NSNumber numberWithInteger:tag] forKey:@"tag"];
    [aCoder encodeObject:operation forKey:@"operation"];
    [aCoder encodeObject:context forKey:@"context"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        operation = [aDecoder decodeObjectForKey:@"operation"];
        category = [[aDecoder decodeObjectForKey:@"category"] integerValue];
        tag = [[aDecoder decodeObjectForKey:@"tag"] integerValue];
        context = [aDecoder decodeObjectForKey:@"context"];
    }
    return self;
}

- (instancetype)initWithOperation:(ANOperation *)oper
                      andCategory:(ANCategory)t_category
{
    self = [super init];
    if(self)
    {
        self.operation = [oper copy];
        self.category = t_category;
    }
    return self;
}
@end
