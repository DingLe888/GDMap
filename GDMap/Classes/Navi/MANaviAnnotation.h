//
//  MANaviAnnotation.h
//  OfficialDemo3D
//
//  Created by yi chen on 1/7/15.
//  Copyright (c) 2015 songjian. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MAMapKit/MAMapKit.h>

#import "MAMapKit.h"

typedef NS_ENUM(NSInteger, MANaviAnnotationType)
{
    MANaviAnnotationTypeDrive = 0,
    MANaviAnnotationTypeWalking = 2,
    MANaviAnnotationTypeBus = 1,
    MANaviAnnotationTypeRailway = 4,
    MANaviAnnotationTypeRiding = 3
};

@interface MANaviAnnotation : MAPointAnnotation

@property (nonatomic) MANaviAnnotationType type;

@end
