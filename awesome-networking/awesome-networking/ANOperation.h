//
//  ANOperation.h
//  awesome-networking
//
//  Created by chen Yuheng on 15/7/21.
//  Copyright (c) 2015年 chen Yuheng. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "ANHeader.h"

@interface ANOperation : AFHTTPRequestOperation

/**
 *  主键标识
 */
@property(nonatomic, assign) NSInteger operationId;

/**
 *  时间戳
 */
@property(nonatomic, strong) NSString *timestamp;

/**
 *  由父类实例初始化自身，其实就是生成一个父类实例的copy，然后加上子类的一些特有属性
 *
 *  @param op 父类实例
 *
 *  @return 子类实例
 */
- (instancetype)initWithOperation:(AFHTTPRequestOperation *)op;
@end
