# Awesome-Networking

An optimized networking framework based on AFNetworking and ProtoBuffers.

## Version

Beta 1.0

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

```Objective-C
@interface ANManager : AFHTTPRequestOperationManager
```

继承于`AFHTTPRequestOperationManager`，拓展了缓存请求，删除缓存中指定请求和恢复缓存请求等方法，同时新增了一个基础网络请求方法。其中最基础的发送POST请求的方法如下:

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
    
    [(ANOperationQueue *)self.operationQueue addRequest:tmp];
    [(ANOperationQueue *)self.operationQueue addOperation:t_operation];
    
    completed(t_operation);
    return t_operation;
}
```

你可以根据需要或者业务场景来确定当网络请求返回什么样的`error`的时候选择将网络请求缓存下来。缓存请求的时候需要初始化一个`ANRequest`对象，指定这个请求的功能分类，这个功能分类的`Category`可以在全局的`ANHeader`中定义:

```Objective-C
typedef NS_ENUM(NSInteger,ANCategory){
    DEFAULT_CATEGORY = 0,
    TEST_CATEGORY,
};
```

这些被缓存的网络请求在**何时被恢复执行**可以**由你来决定**。正常情况下是根据网络状况的变化来判断，即当网络恢复通畅的时候恢复执行这些缓存请求。但是当整个应用的功能模块变得较多的时候，恢复所有被缓存的请求可能对于刚刚获得的网络资源是一种占用和浪费，因此就有了`ANCategory`来区分这些缓存的网络请求都是属于什么功能模块的，当用户进入这个模块的时候才选择恢复缓存的请求，而且当请求被恢复的时候，他们会被重新加到全局的`ANOperationQueue`中去，因此恢复缓存请求的这个操作一定要先于当前模块的所有网络请求。这样就可以保证数据的同步性了。
默认的恢复操作被添加在一个网络状态变化的监听器中:

```Objective-C
- (void)networkStatusChange:(NSNotification *)notification
{
    NSNumber *status = [notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem];
    if ([status integerValue] == AFNetworkReachabilityStatusReachableViaWWAN
        || [status integerValue] == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self resumeCachedRequestWithCategory:nil];
    }
}
```

在**发送网络请求的操作被执行完成**后，如果网络较慢或者请求的数据较多，这个时候可能用户需要等待的时间较长，在某些不需要阻塞用户操作的使用场景下（例如发布朋友圈图文动态），`completion`的block的回调可以很好地改进这时的用户体验。在`ANOperation`被成功执行后，你可以通过`completion`返回的回调来进行你需要的本地缓存或者跳过的操作。具体的使用方式可以在测试的请求中看到。

### ANOperation

```Objective-C
@interface ANOperation : AFHTTPRequestOperation
```

`ANOperation`是继承于`AFHTTPRequestOperation`的网络请求操作对象。这里主要是加上了主键和时间戳的属性，并重写了初始化的方法。因为请求的缓存用到了`NSKeyedArchiver`来序列化对象并缓存，因此子类也重写了这三个方法来实现序列化存储。同样的在他的上层`ANRequest`类中也实现了这三个方法。

```Objective-C
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
```

### ANOperationQueue

```Objective-C
@interface ANOperationQueue : NSOperationQueue
```

`ANOperationQueue`是继承于`NSOperationQueue`的网络请求队列。用来作为`AFHTTPRequestOperationManager`单例的网络请求队列。这里主要是提供了一些特殊场景下的功能。例如在程序退出的时候，可能有些操作成功和失败的回调都没有收到，传输可能会被中断，因此就需要将队列中仍在执行和仍在等待被执行的操作一起缓存下来。这个类主要提供的是对网络请求队列中的请求的管理和维护。

### ANRequest

```Objective-C
@interface ANRequest : NSObject
```

`ANRequest`没有继承于任何父类。他只是请求最后被缓存下来的时候的数据类型。和`ANOperation`一样，他只是实现了几个用于序列化存储的方法。其中的`context`字段可以用来拓展请求需要缓存的一些信息。

### ANRequestSerializer

```Objective-C
@interface ANRequestSerializer : AFHTTPRequestSerializer
```

为了使用protoBuffer，我们必须使用自定义的请求和响应的serializer。`ANRequestSerializer`继承于`AFHTTPRequestSerializer`，对请求的Body进行序列化。对于普通的POST请求来说，父类的序列化操作就是简单地将POST传参拼接成字符串。而对于protoBuffer来说，请求的Body就是NSData，也就是二进制字节。因此在调用序列化操作函数的时候，你必须要传入正确类型的参数：

```Objective-C
/**
 *  重写了父类序列化request的方法，将非NSDictionary的接口通过父类的该方法返回
 *  只有类型为NSData的protoBuffer的数据需要通过子类的这个方法返回
 *
 *  @param request    请求
 *  @param parameters 需要序列化的BODY数据
 *  @param error      错误
 *
 *  @return 序列化之后的请求
 */
- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    if(!parameters)
    {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
    else
    {
        if([parameters isKindOfClass:[NSDictionary class]])
        {
            return [super requestBySerializingRequest:request withParameters:parameters error:error];
        }
        else
        {
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            
            [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
                if (![request valueForHTTPHeaderField:field]) {
                    [mutableRequest setValue:value forHTTPHeaderField:field];
                }
            }];
            [mutableRequest setHTTPBody:parameters];
            return mutableRequest;
        }
    }
}
```

### ANResponseSerializer

```Objective-C
@interface ANResponseSerializer : AFHTTPResponseSerializer
```

`ANResponseSerializer`继承于`AFHTTPResponseSerializer`，由于需要解析返回的响应数据，所以将AFNetworking自带的JSON解析器作为默认解析，而根据返回响应头中的`content-type`来判断是否是符合protoBuffer的返回体。因此在构建与Awesome-Networking相配合的后端的时候，返回的响应头中需要将`content-type`设置为`application/octet-stream`。当然，如果您已经有成熟后端的话，这个地方也可以**留给你自定义**根据你已有后端的返回数据所对应的解析操作。

```Objective-C
- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
#pragma - 根据response获得的content-type决定返回的是经过json序列化后的data还是protobuf的data，可以拓展
    if([response.MIMEType isEqualToString:@"application/octet-stream"])
    {
        return data;
    }
    else
    {
        return [self JSONresponseObjectForResponse:response data:data error:error];
    }
}
```

## Usage

用法可以参考`ANManager+test`中定义的单个网络请求的示例:

```Objective-C
- (void)testRequestCompletion:(completionBlock)completed
                      success:(successWithObjectBlock)success
                      failure:(failErrorBlock)failure
{
    NSString *test_url = @"http://****.test.com/test/";
    
    Request *t_request = [[Request alloc]init];
    t_request.cmdid = (int32_t)1;
    t_request.timestamp = (int64_t)[[NSDate date] timeIntervalSince1970];
    
    testMessage *t_testMessage = [[testMessage alloc]init];
    t_testMessage.content = @"Hello world!";
    t_testMessage.common = t_request;
    
    testMessageWithImage *t_testMessageWithImage = [[testMessageWithImage alloc]init];
    t_testMessageWithImage.common = t_request;
    t_testMessageWithImage.content = @"Hello world!";
//    t_testMessageWithImage.imagesArray为一个ANFile对象的数组,ANFile由如下代码初始化
    
//    UIImage *image = [UIImage imageNamed:@"test"];
//    ANFile *file = [[ANFile alloc]init];
//    file.content = UIImageJPEGRepresentation(image, 0.3);
//    file.mimetype = @"image/jpeg";
//    file.filename = @"image.jpeg";
    
    [self POST:test_url category:TEST_CATEGORY context:[NSDictionary dictionary] tag:1002 parameters:[t_testMessage data] completion:^(ANOperation *operation) {
        completed();
    } success:^(ANOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(ANOperation *operation, NSError *error) {
        failure(error);
    }];
}
```

其中示范了简单的带图片和不带图片的protoBuffer对象的构建和传参。你可以在外层捕获到三种情况的回调：

* 操作完成，请求发出
* 请求成功获得返回数据
* 请求由于本地错误或Http错误返回失败

## Thanks

如果您觉得这个库对你会有帮助，哪怕是一点点的启发，留下个Star，我也会十分感谢的！