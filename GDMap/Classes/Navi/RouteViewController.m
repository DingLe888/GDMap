//
//  RouteViewController.m
//  reactMap
//
//  Created by 丁乐 on 2017/4/26.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "RouteViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"


static const NSString *RoutePlanningViewControllerStartTitle       = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
static const NSInteger RoutePlanningPaddingEdge                    = 40;


@interface RouteViewController ()<MAMapViewDelegate,AMapSearchDelegate>

/* 起始点经纬度. */
@property (nonatomic) CLLocationCoordinate2D startCoordinate;

/* 终点经纬度. */
@property (nonatomic) CLLocationCoordinate2D destinationCoordinate;
/* 终点名称. */
@property(nonatomic,copy) NSString *destinationName;


@property(nonatomic,strong) MAMapView *mapView;

@property(nonatomic,strong) AMapSearchAPI *search;

@property(nonatomic,assign) BOOL userLocation;

@property (nonatomic, strong) MAPointAnnotation *startAnnotation;
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

@property (nonatomic, strong) AMapRoute *route;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

/* 当前路线方案的类型 */
@property(nonatomic,assign)MANaviAnnotationType trafficRoutesType;
// -------- 按钮们 --------

// 导航按钮
@property (weak, nonatomic) IBOutlet UIButton *naviBtn;
// 公交按钮
@property (weak, nonatomic) IBOutlet UIButton *transitBtn;

// 当前选中按钮
@property (weak, nonatomic) UIButton *selectedBtn;

@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  // -----------  地图 --------------
  [AMapServices sharedServices].enableHTTPS = YES;
  
  _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
  _mapView.delegate = self;
  [self.view addSubview:_mapView];
  [self.view sendSubviewToBack:_mapView];
  
  [self.mapView setZoomLevel:14];

  self.mapView.showsCompass = false; // 不显示罗盘
  self.mapView.showsScale = false; //  不显示比例尺
  self.mapView.showsUserLocation = YES;  //  显示用户位置
  self.userLocation = YES;
  self.mapView.userTrackingMode = MAUserTrackingModeFollow;  // 定位点模式

  // ----------- 搜索 ---------------
  self.search = [[AMapSearchAPI alloc] init];
  self.search.delegate = self;
  

    // 导航
  self.naviBtn.layer.masksToBounds = YES;
  self.naviBtn.layer.cornerRadius = self.naviBtn.bounds.size.width * 0.5;
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];

  // --------- 定位权限 -----------
  CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
  if ([CLLocationManager locationServicesEnabled] && (state == kCLAuthorizationStatusAuthorizedWhenInUse || state == kCLAuthorizationStatusNotDetermined || state == kCLAuthorizationStatusAuthorizedAlways)) {
    //定位功能可用
    [self transitRoute:self.transitBtn];


  }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {

    //定位不能用 -- 发出提示 并移动地图中心点
    [self cantFindUserLocation];

    [self.mapView setCenterCoordinate:self.destinationCoordinate animated:true];

    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle   = self.destinationName;
    self.destinationAnnotation = destinationAnnotation;

    [self.mapView addAnnotation:destinationAnnotation];
  }



}

- (void)setTarget:(NSDictionary *)destinationDict
{
  double latitude = [[destinationDict objectForKey:@"latitude"] doubleValue];
  double longitude = [[destinationDict objectForKey:@"longitude"] doubleValue];
  
  self.destinationName = [destinationDict objectForKey:@"destinationName"];
  
  self.destinationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
}

// 返回按钮
- (IBAction)backBtnClick:(UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

// 公交
- (IBAction)transitRoute:(UIButton *)sender {
  [self selectedTrafficRouteType:MANaviAnnotationTypeBus];
  
  AMapTransitRouteSearchRequest *navi = [[AMapTransitRouteSearchRequest alloc] init];
  
  navi.requireExtension = YES;
  
  /* 出发点. */
  navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                         longitude:self.startCoordinate.longitude];
  /* 目的地. */
  navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                              longitude:self.destinationCoordinate.longitude];
  [self.search AMapTransitRouteSearch:navi];

  self.selectedBtn = sender;
}

// 步行
- (IBAction)walkingRoute:(UIButton *)sender {
  [self selectedTrafficRouteType:(MANaviAnnotationTypeWalking)];
  
  AMapWalkingRouteSearchRequest *navi = [[AMapWalkingRouteSearchRequest alloc] init];
  
  /* 出发点. */
  navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                         longitude:self.startCoordinate.longitude];
  /* 目的地. */
  navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                              longitude:self.destinationCoordinate.longitude];
  [self.search AMapWalkingRouteSearch:navi];

  self.selectedBtn = sender;
}

// 骑行
- (IBAction)ridingRoute:(UIButton *)sender {
  [self selectedTrafficRouteType:(MANaviAnnotationTypeRiding)];
  
  AMapRidingRouteSearchRequest *navi = [[AMapRidingRouteSearchRequest alloc] init];
  
  /* 出发点. */
  navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                         longitude:self.startCoordinate.longitude];
  /* 目的地. */
  navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                              longitude:self.destinationCoordinate.longitude];
  
  [self.search AMapRidingRouteSearch:navi];

  self.selectedBtn = sender;

}

// 驾车
- (IBAction)drivingRoute:(UIButton *)sender {
  [self selectedTrafficRouteType:MANaviAnnotationTypeDrive];
  
  AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
  
  navi.requireExtension = YES;
  navi.strategy = 5;
  /* 出发点. */
  navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                         longitude:self.startCoordinate.longitude];
  /* 目的地. */
  navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                              longitude:self.destinationCoordinate.longitude];
  
  [self.search AMapDrivingRouteSearch:navi];
  
  self.selectedBtn = sender;
}

-(void)setSelectedBtn:(UIButton *)selectedBtn{
  _selectedBtn.titleLabel.font = [UIFont systemFontOfSize:15];

  selectedBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
  _selectedBtn = selectedBtn;
}

// 导航
- (IBAction)naviBtnClick:(UIButton *)sender {
  
  [self jump3partyMap:self.startCoordinate endCoor:self.destinationCoordinate];
}


/* 清空地图上已有的路线. */
- (void)selectedTrafficRouteType:(MANaviAnnotationType)trafficRouteType
{
  [self.naviRoute removeFromMapView];
  self.trafficRoutesType = trafficRouteType;
}

- (void)addDefaultAnnotations
{
  MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
  startAnnotation.coordinate = self.startCoordinate;
  startAnnotation.title      = (NSString*)RoutePlanningViewControllerStartTitle;
  startAnnotation.subtitle   = @"我的位置";
  self.startAnnotation = startAnnotation;
  
  MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
  destinationAnnotation.coordinate = self.destinationCoordinate;
  destinationAnnotation.title      = (NSString*)RoutePlanningViewControllerDestinationTitle;
  destinationAnnotation.subtitle   = self.destinationName;
  self.destinationAnnotation = destinationAnnotation;
  
  [self.mapView addAnnotation:startAnnotation];
  [self.mapView addAnnotation:destinationAnnotation];
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse
{

  AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude]; //起点
  
  AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude];  //终点
  if (self.trafficRoutesType == MANaviAnnotationTypeBus) {
    
    self.naviRoute = [MANaviRoute naviRouteForTransit:self.route.transits[0]
                                           startPoint:startPoint
                                             endPoint:endPoint
                      ];

  }else{

    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[0]
                                      withNaviType:self.trafficRoutesType
                                       showTraffic:YES
                                        startPoint:startPoint
                                          endPoint:endPoint
                      ];
  }
  
  [self.naviRoute addToMapView:self.mapView];
  
  /* 缩放地图使其适应polylines的展示. */
  [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                      edgePadding:UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge)
                         animated:YES];
}


#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{

  [self tipMessage:@"搜索路线错误！"];
}

/* 路径规划搜索回调. */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
  if (response.route == nil)
  {
    [self tipMessage:@"未搜索到路线"];
    return;
  }
  
  self.route = response.route;
  
  if (response.count > 0)
  {
    [self presentCurrentCourse];
  }
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
  if (userLocation.location && self.userLocation && self.destinationCoordinate.latitude){
    self.startCoordinate = userLocation.location.coordinate;
    
    [self addDefaultAnnotations];
    self.userLocation = NO;
  }
}


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
  if ([overlay isKindOfClass:[LineDashPolyline class]])
  {
    MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
    polylineRenderer.lineWidth   = 8;
    polylineRenderer.lineDash = YES;
    polylineRenderer.strokeColor = [UIColor redColor];
    
    return polylineRenderer;
  }
  if ([overlay isKindOfClass:[MANaviPolyline class]])
  {
    MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
    MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
    
    polylineRenderer.lineWidth = 8;
    
    if (naviPolyline.type == MANaviAnnotationTypeWalking)
    {
      polylineRenderer.strokeColor = self.naviRoute.walkingColor;
    }
    else if (naviPolyline.type == MANaviAnnotationTypeRailway)
    {
      polylineRenderer.strokeColor = self.naviRoute.railwayColor;
    }
    else
    {
      polylineRenderer.strokeColor = self.naviRoute.routeColor;
    }
    
    return polylineRenderer;
  }
  if ([overlay isKindOfClass:[MAMultiPolyline class]])
  {
    MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
    
    polylineRenderer.lineWidth = 10;
    polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
    polylineRenderer.gradient = YES;
    
    return polylineRenderer;
  }
  
  return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
  if ([annotation isKindOfClass:[MAPointAnnotation class]])
  {
    static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
    
    MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
    if (poiAnnotationView == nil)
    {
      poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:routePlanningCellIdentifier];
    }
    
    poiAnnotationView.canShowCallout = YES;
    poiAnnotationView.image = nil;
    
    if ([annotation isKindOfClass:[MANaviAnnotation class]])
    {
      switch (((MANaviAnnotation*)annotation).type)
      {
        case MANaviAnnotationTypeRailway:
          poiAnnotationView.image = [UIImage imageNamed:@"railway_station"];
          break;
          
        case MANaviAnnotationTypeBus:
          poiAnnotationView.image = [UIImage imageNamed:@"bus"];
          break;
          
        case MANaviAnnotationTypeDrive:
          poiAnnotationView.image = [UIImage imageNamed:@"car"];
          break;
          
        case MANaviAnnotationTypeWalking:
          poiAnnotationView.image = [UIImage imageNamed:@"man"];
          break;
          
        case MANaviAnnotationTypeRiding:
          poiAnnotationView.image = [UIImage imageNamed:@"ride"];
          break;
          
        default:
          break;
      }
    }
    else
    {
      /* 起点. */
      if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle])
      {
        poiAnnotationView.image = [UIImage imageNamed:@"startPoint"];
      }
      /* 终点. */
      else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle])
      {
        poiAnnotationView.image = [UIImage imageNamed:@"endPoint"];
      }
      
    }
    
    return poiAnnotationView;
  }
  
  return nil;
}

-(void)jump3partyMap:(CLLocationCoordinate2D)startCoor endCoor:(CLLocationCoordinate2D)endCoor {
  
  CLLocationDegrees startLatitude = startCoor.latitude;
  CLLocationDegrees startLongitude = startCoor.longitude;

  CLLocationDegrees endLatitude = endCoor.latitude;
  CLLocationDegrees endLongitude = endCoor.longitude;
  
  NSString *BDModel = @"driving";
  
  switch (self.trafficRoutesType) {
    case MANaviAnnotationTypeBus:
      BDModel = @"transit";
      break;
      
    case MANaviAnnotationTypeWalking :
      BDModel = @"walking";
      break;
      
    case MANaviAnnotationTypeRiding:
      BDModel = @"riding";
      break;
    default:
      break;
  }
  
  NSString *GDUrlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&dlat=%f&dlon=%f&dev=0&t=%zd",@"家政阿姨端",endLatitude,endLongitude,self.trafficRoutesType] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

  NSString *BDUrlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=name:我的位置|latlng:%f,%f&destination=name:目的地|latlng:%f,%f&mode=%@&sy=0&index=0&target=1",startLatitude, startLongitude,endLatitude, endLongitude,BDModel] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

  
  if ([self openUrl:GDUrlString]) {
    [self openUrl:GDUrlString];
    
  }else if([self openUrl:BDUrlString]){
    [self openUrl:BDUrlString];
  }else{
    [self tipMessage:@"请先下载百度地图或者高德地图APP"];
  }
  
}

- (BOOL)canOpenUrl:(NSString *)url{
  return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

- (BOOL)openUrl:(NSString *)urlStr{
  NSURL *url = [NSURL URLWithString:urlStr];
  return [[UIApplication sharedApplication] openURL:url];
}

-(void)tipMessage:(NSString *)message{
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
  [alertVC addAction:action];
  [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)cantFindUserLocation
{
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法定位您的位置，请去设置中打开定位功能" preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
  [alertVC addAction:action];

  UIAlertAction *actionGo = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    NSURL *url = [[NSURL alloc]initWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
  }];

  [alertVC addAction:actionGo];

  [self presentViewController:alertVC animated:YES completion:nil];
}


@end
