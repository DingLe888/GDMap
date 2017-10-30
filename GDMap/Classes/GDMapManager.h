//
//  GDMapManager.h
//  GDMap
//
//  Created by 丁乐 on 2017/10/25.
//  如果需要同时支持在iOS8-iOS10和iOS11系统上后台定位，建议在plist文件中同时添加NSLocationWhenInUseUsageDescription、NSLocationAlwaysUsageDescription和NSLocationAlwaysAndWhenInUseUsageDescription权限申请。
// //   需要手动把资源Bundle 拖入工程中



#import <Foundation/Foundation.h>


@interface GDMapManager : NSObject

// 开始定位 位置
+(void)startUpdatingLocation:(NSDictionary *)data;

// 初始化设置appKey
+(void)setGDAppKey:(NSString *)appKey;

//  单次定位
+(void)getLocation:(NSDictionary *)data;

// 结束定位。
+(void)stopUpdatingLocation;

// 关键字Poi搜索
+(void)poiKeywordsSearch:(NSDictionary *)data;

// 关键字经纬度 搜索周边
+(void)poiLocationSearch:(NSDictionary *)data;

+(void)showMapview;
@end
