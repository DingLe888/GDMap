//
//  GDMapManager.m
//  GDMap
//
//  Created by 丁乐 on 2017/10/25.
//

#import "GDMapManager.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>
#import "MapViewController.h"


@interface GDMapManager()<AMapLocationManagerDelegate,AMapSearchDelegate>

@property (nonatomic,strong)AMapLocationManager *locationManager;

@property (nonatomic,strong)NSDictionary *locationData;

@property (nonatomic,copy)NSString *mCity;

@property (nonatomic,strong)AMapSearchAPI *searchManager;

@property (nonatomic,strong)NSDictionary *searchData;


@end

@implementation GDMapManager

static GDMapManager *instance;

+(instancetype)getInstance{
    @synchronized(self) {
        if (instance == nil) {
            instance = [[GDMapManager  alloc]init];
        }
    }
    return instance;
}

// 懒加载 locationManager
-(AMapLocationManager *)locationManager{
    if(_locationManager == nil){
        _locationManager = [[AMapLocationManager alloc] init];
        
        //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
        
        //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
        
        _locationManager.delegate = self;
        
        ///设定定位的最小更新距离。单位米，默认为 kCLDistanceFilterNone，表示只要检测到设备位置发生变化就会更新位置信息。
        _locationManager.distanceFilter = 200.0;
        
        ///连续定位是否返回逆地理信息，默认NO。
        _locationManager.locatingWithReGeocode = YES;
    }
    
    return _locationManager;
}



+(void)setGDAppKey:(NSString *)appKey{
    [[GDMapManager getInstance] setAppKey:appKey];
}

-(void)setAppKey:(NSString *)appKey{
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey = appKey;
}

// 开始定位  持续定位中
+(void)startUpdatingLocation:(NSDictionary *)data{
    GDMapManager *ma = [GDMapManager getInstance];
    ma.locationData = data;

    [ma.locationManager startUpdatingLocation];
}


// 开始定位   单次定位
+(void)getLocation:(NSDictionary *)data{
    GDMapManager *ma = [GDMapManager getInstance];
    
    BOOL success = [ma.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSMutableDictionary *resultDict = [NSMutableDictionary  dictionary];
        if(error){
            [resultDict setObject:@"failed" forKey:@"result"];
            [resultDict setObject:[error localizedDescription] forKey:@"data"];

        }else if (regeocode){
            ma.mCity = regeocode.city;
            NSMutableDictionary *data = [NSMutableDictionary  dictionary];

            [data setObject:@(location.coordinate.latitude) forKey:@"latitude"];
            [data setObject:@(location.coordinate.longitude) forKey:@"longitude"];
            
            NSDictionary *reGeocodeDict = [regeocode dictionaryWithValuesForKeys:@[@"formattedAddress",@"country",@"province",@"city",@"district",@"street",@"number",@"POIName",]];
            [data setDictionary:reGeocodeDict];
            [data setObject:reGeocodeDict[@"formattedAddress"] forKey:@"address"];
            
            [resultDict setObject:@"success" forKey:@"result"];
            [resultDict setObject:data forKey:@"data"];
        }
        
        [ma putResult:resultDict data:data];
    }];
    
    if(!success){
        NSDictionary *resultDict = @{@"result":@"failed",@"data":@"当前正在持续定位中，不能进行单次定位"};
        
        [ma putResult:resultDict data:data];
    }
}

// 结束定位
+(void)stopUpdatingLocation{
    GDMapManager *ma = [GDMapManager getInstance];
    
    [ma.locationManager stopUpdatingLocation];
}

//接收位置更新,实现AMapLocationManagerDelegate代理的amapLocationManager:didUpdateLocation方法，处理位置更新
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
//    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (reGeocode)
    {
        self.mCity = reGeocode.city;
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        [resultDict setObject:@"success" forKey:@"result"];

        NSDictionary *reGeocodeDict = [reGeocode dictionaryWithValuesForKeys:@[@"formattedAddress",@"country",@"province",@"city",@"district",@"street",@"number",@"POIName",]];
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:reGeocodeDict];

        [data setObject:reGeocodeDict[@"formattedAddress"] forKey:@"address"];

        [data setObject:@(location.coordinate.latitude) forKey:@"latitude"];
        [data setObject:@(location.coordinate.longitude) forKey:@"longitude"];
        [resultDict setObject:data forKey:@"data"];
        
        [self putResult:resultDict data:self.locationData];
    }
}


-(void)putResult:(NSDictionary *)result data:(NSDictionary *)data{
    if (data && data[@"callback"]) {
        NSString *notifiName = data[@"callback"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notifiName object:result userInfo:nil];
    }
}

// ======================    搜索部分   ========================
-(AMapSearchAPI *)searchManager{
    if (_searchManager == nil) {
        _searchManager = [[AMapSearchAPI alloc]init];
        _searchManager.delegate = self;
    }
    
    return _searchManager;
}

+(void)poiKeywordsSearch:(NSDictionary *)data{
    GDMapManager *ma = [GDMapManager getInstance];

    if(data && data[@"keyword"]){
        ma.searchData = data;

        NSString *allTypes = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        
        request.keywords            = data[@"keywords"];
        
        request.city                = data[@"city"] ? data[@"city"] : ma.mCity;
        
        request.types               = data[@"types"] ? data[@"types"] : allTypes;
        request.requireExtension    = YES;
        
//        /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
//        request.cityLimit           = YES;
        request.requireSubPOIs      = YES;
        
        [ma.searchManager AMapPOIKeywordsSearch:request];
    }
}

+(void)poiLocationSearch:(NSDictionary *)data{
    GDMapManager *ma = [GDMapManager getInstance];
    if (data && data[@"longitude"]) {
        ma.searchData = data;

        NSString *allTypes = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";

        
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        
        request.location            = [AMapGeoPoint locationWithLatitude:[data[@"latitude"] doubleValue] longitude:[data[@"longitude"] doubleValue]];
        
        request.keywords            = data[@"keywords"] ? data[@"keywords"] : nil;
        
        request.types               = data[@"types"] ? data[@"types"] : allTypes;

        /* 按照距离排序. */
        request.sortrule            = 0;
        request.requireExtension    = YES;
        
        [ma.searchManager AMapPOIAroundSearch:request];
        
    }
    
}

/**
 * @brief 当请求发生错误时，会调用代理的此方法.
 * @param request 发生错误的请求.
 * @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    [resultDict setObject:@"failed" forKey:@"result"];
    [resultDict setObject:[error localizedDescription] forKey:@"data"];

    [self putResult:resultDict data:self.searchData];
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
//    NSLog(@"response: %@",response);
    if (response.pois.count == 0)
    {
        [resultDict setObject:@"failed" forKey:@"result"];
        [resultDict setObject:@"未查询到任何数据" forKey:@"data"];
        
    }else{
        NSMutableArray *poiArray = [NSMutableArray array];
        for (AMapPOI *obj in response.pois) {
            NSDictionary *dict = [obj dictionaryWithValuesForKeys:@[@"name",@"type",
                                                                    @"address",
                                                                    @"tel",@"province",
                                                                    @"city",@"district",
                                                                    @"businessArea",@"uid"]];
            NSMutableDictionary *poi_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
            [poi_dict setObject:@(obj.location.latitude) forKey:@"latitude"];
            [poi_dict setObject:@(obj.location.longitude) forKey:@"longitude"];

            
            [poiArray addObject:poi_dict];
        }
        [resultDict setObject:@"success" forKey:@"result"];
        [resultDict setObject:poiArray forKey:@"data"];
    }
    
    [self putResult:resultDict data:self.searchData];

}

//===================   地图部分  ======================
+(void)showMapview:(NSDictionary *)data{
    
    [[self getInstance] showMapview:data];
}

-(void)showMapview:(NSDictionary *)data{
    UIViewController *rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    MapViewController *mapVC = [[MapViewController alloc]initWithData:data];
    
    UINavigationController *mapNav = [[UINavigationController alloc]initWithRootViewController:mapVC];
    
    [rootVC presentViewController:mapNav animated:YES completion:^{
        
    }];
}





@end
