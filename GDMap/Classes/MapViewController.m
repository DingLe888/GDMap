//
//  MapViewController.m
//  GDMap
//
//  Created by 丁乐 on 2017/10/30.
//

#import "MapViewController.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>


@interface MapViewController ()<MAMapViewDelegate>

@property (nonatomic,strong)NSDictionary *data;

@property (nonatomic,strong) MAMapView * mapView;

@end

@implementation MapViewController

-(instancetype)initWithData:(NSDictionary *)date{
    if (self = [super init]) {
        _data = date;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    ///初始化地图
    MAMapView *_mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];

    ///把地图添加至view
    [self.view addSubview:_mapView];

    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;

    [_mapView setZoomLevel:14.0];
    
    _mapView.delegate = self;
    NSLog(@"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemDone) target:self action:@selector(dismiss)];
    
    self.mapView = _mapView;
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    
    CLLocationDegrees latitude = [self.data[@"latitude"] doubleValue];
    CLLocationDegrees longitude = [self.data[@"longitude"] doubleValue];

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    pointAnnotation.coordinate = center;
    pointAnnotation.title = self.data[@"title"];
    
    [_mapView addAnnotation:pointAnnotation];
    
    [self.mapView setCenterCoordinate:center animated:YES];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if([annotation isKindOfClass:[MAUserLocation class]]){return nil;}
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

@end
