# Awesome-Networking
An optimized networking framework based on AFNetworking and ProtoBuffers.

## Version
Beta 0.9

## License
MIT License

## Basic Library
本拓展库用到了以下两个第三方框架作为底层支持：

* google/protoBuf
* AFNetworking

## Brief Introduction
这个网络拓展库的基本机制来自于微信朋友圈的网络请求机制。我们可以通过Charles抓包分析朋友圈各个操作过后的请求，基本表现出:

* 所有网络失败的请求都会在网络恢复的时候优先于当前页面的网络请求恢复进行
* 请求Body都是二进制字节，虽然并不是protoBuffer
* 所有网络失败的请求都会被缓存下来
* 在网络失败的情况下，写入和取消写入的操作并不是按照缓存的顺序执行的，比如你点赞又取消交替进行了各5次，最后在网络恢复的时候会先执行所有的取消操作，再执行所有的点赞操作，我们猜测在这种频繁点赞和取消并且请求被缓存下来的操作场景下，微信认为用户是因为网络问题才会重复执行同一操作，因此点赞或者发表朋友圈的操作等级优先于取消。这是我们发现的一个比较有趣的细节。
* 恢复网络的时候会执行一个同步请求，可能是根据同步请求返回的参数来判断是否恢复本地缓存中的请求

所以我们为了实现出类似的需求，需要完成以下功能：

* √ 有一个全局队列的单例 
* √ 每个operation都有个唯一id和分类编号 在全局的header中定义 
* √ 可以直接在队列中找到某个指定标签的请求并取消 
* √ 每次操作有发送完成的回调，有成功的回调，有失败的回调 
* √ 如果获取到网络失败的error则缓存请求
* √ 全局manager里有一个恢复指定category的请求的方法
* √ 引入protoBuffer，继承serializers做请求和响应的序列化

### ANManager
继承于`AFHTTPRequestOperationManager`，拓展了缓存请求，删除缓存中指定请求和恢复缓存请求等方法，同时覆盖了父类的基础网络请求方法。

```Objective-C
/**
 *  用POST方法创建并运行一个`ANOperation`的对象，附带了附加字典，缓存分类和缓存标识
 *
 *  @param URLString  请求的目标地址
 *  @param category   请求的缓存分类
 *  @param context    请求的缓存拓展字典
 *  @param tag        请求的缓存标签
 *  @param parameters 请求的参数，若为普通POST请求则传入NSDictionary即可，若采用protoBuffer，则需要传入NSData
 *  @param success
 *  @param failure
 *
 *  @return ANOperation
 */
- (ANOperation *)POST:(NSString *)URLString
             category:(ANCategory)category
              context:(NSDictionary *)context
                  tag:(NSInteger)tag
           parameters:(id)parameters
           completion:(void (^)(ANOperation *operation))completed
              success:(void (^)(ANOperation *operation, id responseObject))success
              failure:(void (^)(ANOperation *operation, NSError *error))failure
              {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    
    ANOperation *t_operation = [self ANHTTPRequestOperationWithRequest:request success:^(ANOperation *operation, id responseObject) {
        [(ANOperationQueue *)self.operationQueue removeRequestByOperationId:[operation operationId]];
        success(operation,responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        if(error.code == HTTP_NONETWORK_CODE || error.code == HTTP_NOTCONNECTEDTOSERVER_CODE || error.code == HTTP_TIMEOUT_CODE || error.code == HTTP_RESPONSENOTJSON_CODE)
            [(ANOperationQueue *)self.operationQueue cacheOperationByOperationId:[operation operationId]];
        
        [(ANOperationQueue *)self.operationQueue removeRequestByOperationId:[operation operationId]];
        failure(operation,error);
    }];
    
    ANRequest *tmp = [[ANRequest alloc]initWithOperation:t_operation andCategory:category];
    tmp.context = context;
    tmp.tag = tag;
    
    completed(t_operation);
    
    [(ANOperationQueue *)self.operationQueue addRequest:tmp];
    [(ANOperationQueue *)self.operationQueue addOperation:t_operation];
    
    return t_operation;
}
```