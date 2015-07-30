# awesome-networking
An optimized networking framework based on AFNetworking.

## TODO List

* √ 有一个全局队列的单例 
* √ 每个operation都有个唯一id和分类编号 在全局的header中定义 
* √ 可以直接在队列中找到某个指定tag的请求并取消 
* √ 每次操作有成功的发送完成的回调，有获取返回的回调，有失败的回调 
* √ 如果获取到网络失败的error则缓存请求
* √ 全局manager里有一个恢复指定category的请求的方法
* 引入protoBuffer，继承serializers