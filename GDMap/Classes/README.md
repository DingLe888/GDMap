## GDMap 目的
是Arena地图部分Api的实现

## 配置要求
* 在Appdelegate 的 application:didFinishLaunchingWithOptions方法中注册高德地图的key

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        let GDKey1 = "3193f87ffdedbf5ef545a0831fe4fea4"        
        GDMapManager.setGDAppKey(GDKey1)
        
        return true
}
```

## 资源文件
* arena.plugins.plist文件主要是配合Arena而做的一个维护api和函数实现之间的映射关系plist文件，不需要去关心。
* pod install 结束后需要手动把Resources中的bundle文件引入主工程。


