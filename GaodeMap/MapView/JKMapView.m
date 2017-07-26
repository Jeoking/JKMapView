//
//  ZallMapView.m
//  GaodeMap
//
//  Created by JayKing on 17/6/21.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import "JKMapView.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/**
 *  @brief  中途点标注的复用标记
 */
static NSString * const JKMapMidWayIdentifier = @"JKMapMidWayIdentifier";

@interface JKMapView()

/**
 *  @brief  所有路径规划搜索
 */
@property (strong, nonatomic, readonly) AMapSearchAPI *drivingSearchTotal;

/* 用于显示当前路线方案. */
@property (nonatomic) MANaviRoute * naviRoute;

/* 回调的路径 */
@property (nonatomic, strong) AMapRoute *route;

/**
 *  @brief  用户经纬度
 */
@property (assign, nonatomic) CLLocationCoordinate2D userLocationCoordinate;

/**
 *  @brief  选中的标注index
 */
@property (assign, nonatomic) NSInteger selectAnnoIndex;

/**
 *  @brief  上一个选中的标签
 */
@property (strong, nonatomic) JKMapAnnotationView *preSelMapAnnotationView;

/**
 首次将用户坐标显示地图中心
 */
@property (assign, nonatomic) BOOL firstShowUserCenter;

/**
 路径起点
 */
@property (nonatomic, strong) MAPointAnnotation *startAnnotation;

/**
 路径终点
 */
@property (nonatomic, strong) MAPointAnnotation *destinationAnnotation;

/**
 路径途经点
 */
@property (nonatomic, strong) NSArray *wayAnnotations;

/**
 当前路径索引
 */
@property (nonatomic, assign) NSInteger currentPathIndex;

/**
 路径总数
 */
@property (nonatomic, assign) NSInteger routeCount;

/**
 此导航管理类为了计算路径节点距离
 */
@property (nonatomic, strong) AMapNaviDriveManager *driveManager;

@end

@implementation JKMapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.delegate = self;
        self.rotateEnabled = YES;            //锁定旋转
        self.rotateCameraEnabled = NO;      //锁定摄像机旋转
        self.showsUserLocation = NO;        //显示用户位置
        self.showsCompass = NO;             //不显示罗盘
        self.showsScale = NO;               //不显示比例尺
        self.showTraffic = NO;              //不显示交通
        self.mapType = MAMapTypeNavi;
        [self setUserTrackingMode:MAUserTrackingModeFollow animated:YES];   //用户跟踪模式
        
        self.userLocImageName = @"car";
        self.selectAnnoIndex = -1;
        
        _drivingSearchTotal = [[AMapSearchAPI alloc] init];
        _drivingSearchTotal.delegate = self;
    }
    return (self);
}

#pragma mark - setting method

- (void)setShouldShowUserLoction:(BOOL)showUserLoction {
    _shouldShowUserLoction = showUserLoction;
    self.showsUserLocation = showUserLoction;
    
    if (showUserLoction) {
        //设置用户坐标点的属性
        MAUserLocationRepresentation *represent = [[MAUserLocationRepresentation alloc] init];
        represent.showsAccuracyRing = YES;
        represent.showsHeadingIndicator = YES;
        represent.image = [UIImage imageNamed:self.userLocImageName];
        [self updateUserLocationRepresentation:represent];
    }
}

/**
 *  @brief  设置用户当前位置 并重新规划路线
 */
- (void)setUserLocationCoordinate:(CLLocationCoordinate2D)userLocationCoordinate {
    _userLocationCoordinate = userLocationCoordinate;
    [self searchRoutePlanningDrive];
}

/**
 传入的标签集合
 */
- (void)setMapAnnotationArray:(NSArray *)arr {
    if (!arr || arr.count == 0) {
        return;
    }
    _mapAnnotationArray = arr;
    //设置中心点
    [self setCenterCoordinate:((JKMapAnnotation *)arr[0]).coordinate animated:NO];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        JKMapAnnotation *ann = (JKMapAnnotation *)obj;
        ann.tag = idx + JKViewTagInterval;
    }];
    //先移除地图上所有的点
    [self removeAnnotations:arr];
    //添加组装好的点到地图视图上
    [self addAnnotations:arr];
    
    //调整地图缩放和显示范围
    [self showsAnnotations:arr edgePadding:UIEdgeInsetsMake(30, 30, 30, 30)];
}

#pragma mark - getting method
- (AMapNaviDriveManager *)driveManager {
    if (_driveManager != nil) {
        return _driveManager;
    }
    _driveManager = [[AMapNaviDriveManager alloc] init];
    [_driveManager setDelegate:self];
    return _driveManager;
}

#pragma mark - AMapNaviDriveManagerDelegate

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    NSString *distance;
    if (driveManager.naviRoute.routeLength < 1000) {
        distance = [NSString stringWithFormat:@"%ld米", driveManager.naviRoute.routeLength];
    } else {
        distance = [NSString stringWithFormat:@"%.1f公里", (CGFloat)driveManager.naviRoute.routeLength/1000];
    }
    NSString *takeTime;
    if (driveManager.naviRoute.routeTime < 3600) {
        takeTime = [NSString stringWithFormat:@"%ld分钟", driveManager.naviRoute.routeTime/60];
    } else {
        takeTime = [NSString stringWithFormat:@"%ld小时%ld分钟", driveManager.naviRoute.routeTime/3600, driveManager.naviRoute.routeTime%3600/60];
    }
    if (self.calculateRouteDistanceBlock) {
        self.calculateRouteDistanceBlock(distance, takeTime);
    }
}

#pragma mark - public
/**
 *  @brief  计算出路径距离和时间
 */
- (void)calculateRouteDistanceWithStartAnno:(MAAnimatedAnnotation *)startAnno endAnno:(MAAnimatedAnnotation *)endAnno calculateBlock:(CalculateRouteDistanceBlock)block {
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:startAnno.coordinate.latitude longitude:startAnno.coordinate.longitude];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:endAnno.coordinate.latitude longitude:endAnno.coordinate.longitude];
    [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint] endPoints:@[endPoint] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySinglePrioritiseDistance];
    
    self.calculateRouteDistanceBlock = block;
}

/**
 选择路径
 
 @param index 路径索引
 */
- (void)selectRouteWithIndex:(NSInteger)index {
    if (self.routeCount == 0) {
        return;
    }
    if (index >= self.routeCount) {
        index = 0;
    }
    self.currentPathIndex = index;
    [self presentCurrentCourse];
}

/**
 选中当前标签

 @param index 标签index
 */
- (JKMapAnnotationView *)selectAnnotationWithIndex:(NSInteger)index {
    //如果始终显示弹出视图
    if (self.isAlwaysShowCallOutView) {
        return nil;
    }
    if (index == self.selectAnnoIndex) {
        return nil;
    }
    JKMapAnnotation *ann = self.mapAnnotationArray[index];
    //如果是未使能
    if (ann.annotationType == DisEnableType || ann.annotationType == UserLocType) {
        return nil;
    }
    ann.isShowCallOutView = YES;
    ann.annotationType = SelectType;
    JKMapAnnotationView *mapAnnotationView = [self viewWithTag:index+JKViewTagInterval];
    mapAnnotationView.annotation = ann;
    if (self.selectAnnoIndex >= 0 && self.preSelMapAnnotationView) {
        JKMapAnnotation *preSelAnnotation = self.mapAnnotationArray[self.selectAnnoIndex];
        preSelAnnotation.isShowCallOutView = NO;
        preSelAnnotation.annotationType = DefaultType;
        self.preSelMapAnnotationView.annotation = preSelAnnotation;
    }
    self.preSelMapAnnotationView = mapAnnotationView;
    self.selectAnnoIndex = index;
    
    if (self.selectAnnotationViewBlock) {
        self.selectAnnotationViewBlock(mapAnnotationView);
    }
    
    return mapAnnotationView;
}

/**
 获取标签视图
 
 @param index    索引
 @return 标签视图
 */
- (JKMapAnnotationView *)getMapAnnotationView:(NSInteger)index {
    return (JKMapAnnotationView *)[self viewWithTag:index+JKViewTagInterval];
}

- (void)moveWithStartAnnotation:(JKMapAnnotation *)anno allAnnotations:(NSArray <JKMapAnnotation *>*)annos animationCount:(NSInteger)count duration:(CGFloat)duration completeCallback:(void(^)(BOOL isFinished))completeCallback {
    
    CLLocationCoordinate2D coordinates[annos.count];
    for (int i = 0; i < annos.count; i++) {
        coordinates[i].latitude = annos[i].coordinate.latitude;
        coordinates[i].longitude = annos[i].coordinate.longitude;
    }
    NSInteger animateCount = count;
    if (animateCount == 0) {
        animateCount = annos.count;
    }
    [anno addMoveAnimationWithKeyCoordinates:coordinates count:animateCount withDuration:duration withName:nil completeCallback:completeCallback];
}

#pragma mark - tool

/**
 * brief 根据传入的annotation来展现：保持中心点不变的情况下，展示所有传入annotation
 * @param annotations annotation
 * @param insets 填充框，用于让annotation不会靠在地图边缘显示
 */
- (void)showsAnnotations:(NSArray *)annotations edgePadding:(UIEdgeInsets)insets {
    MAMapRect rect = MAMapRectZero;
    for (MAPointAnnotation *annotation in annotations) {
        
        ///annotation相对于中心点的对角线坐标
        CLLocationCoordinate2D diagonalPoint = CLLocationCoordinate2DMake(self.centerCoordinate.latitude - (annotation.coordinate.latitude - self.centerCoordinate.latitude),self.centerCoordinate.longitude - (annotation.coordinate.longitude - self.centerCoordinate.longitude));
        
        MAMapPoint annotationMapPoint = MAMapPointForCoordinate(annotation.coordinate);
        MAMapPoint diagonalPointMapPoint = MAMapPointForCoordinate(diagonalPoint);
        
        ///根据annotation点和对角线点计算出对应的rect（相对于中心点）
        MAMapRect annotationRect = MAMapRectMake(MIN(annotationMapPoint.x, diagonalPointMapPoint.x), MIN(annotationMapPoint.y, diagonalPointMapPoint.y), ABS(annotationMapPoint.x - diagonalPointMapPoint.x), ABS(annotationMapPoint.y - diagonalPointMapPoint.y));
        
        rect = MAMapRectUnion(rect, annotationRect);
    }
    [self setVisibleMapRect:rect edgePadding:insets animated:YES];
}

/* 所有点的驾车路径规划搜索. */
- (void)searchRoutePlanningDriveWithStart:(MAPointAnnotation *)startAnnotation destination:(MAPointAnnotation *)destinationAnnotation wayAnnotations:(NSArray *)wayAnnotations {
    //起点
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:startAnnotation.coordinate.latitude longitude:startAnnotation.coordinate.longitude];
    //没有选中的起点，则不进行路线规划
    if(!startPoint) {
        return;
    }
    //设置全局起始点
    self.startAnnotation = startAnnotation;
    //终点
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:destinationAnnotation.coordinate.latitude longitude:destinationAnnotation.coordinate.longitude];
    //没有选中的终点，则不进行路线规划
    if(!endPoint) {
        return;
    }
    //设置全局终点
    self.destinationAnnotation = destinationAnnotation;
    
    //设置途经点
    NSMutableArray *points = [NSMutableArray array];
    if (wayAnnotations && wayAnnotations.count > 0) {
        //途径地
        for(JKMapAnnotation *item in wayAnnotations) {
            //如果未使能则忽略
            if(item.annotationType == DisEnableType) {
                continue;
            }
            AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:item.coordinate.latitude longitude:item.coordinate.longitude];
            [points addObject:point];
        }
        self.wayAnnotations = wayAnnotations;
    }
    
    //发起路径规划请求
    AMapDrivingRouteSearchRequest *searchRequest = [[AMapDrivingRouteSearchRequest alloc] init];
    searchRequest.requireExtension = NO;
    searchRequest.strategy = 2;
    searchRequest.origin = startPoint;
    searchRequest.destination = endPoint;
    if (points.count > 0) {
        searchRequest.waypoints = points;
    }
    [self.drivingSearchTotal AMapDrivingRouteSearch:searchRequest];
}

/* 所有点的驾车路径规划搜索 */
- (void)searchRoutePlanningDrive {
    if (!self.startAnnotation || !self.destinationAnnotation) {
        return;
    }
    //如果开启用户定位，则以用户为起始点
    if (_shouldShowUserLoction && _userLocationCoordinate.latitude != 0 && _userLocationCoordinate.longitude != 0) {
        self.startAnnotation = self.userLocation;
    }
    [self searchRoutePlanningDriveWithStart:self.startAnnotation destination:self.destinationAnnotation wayAnnotations:self.wayAnnotations];
}

/* 展示当前路线方案. */
- (void)presentCurrentCourse {
    if (!self.route || self.route.paths.count == 0) {
        return;
    }
    //先清除所有路径
    [self.naviRoute removeFromMapView];
    MANaviAnnotationType type = MANaviAnnotationTypeDrive;
    //起点
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude];
    //终点
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude];
    
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentPathIndex] withNaviType:type showTraffic:YES startPoint:startPoint endPoint:endPoint];
    [self.naviRoute addToMapView:self];
    
    /* 缩放地图使其适应polylines的展示. */
    [self setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:UIEdgeInsetsMake(80, 30, 30, 30)
                           animated:YES];
}

#pragma mark - <MAMapViewDelegate>
/**
 * @brief 位置或者设备方向更新后，会调用此函数
 * @param mapView 地图View
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    //更新车辆的朝向
    if(!updatingLocation) {
        MAAnnotationView *userLocationView = [mapView viewForAnnotation:mapView.userLocation];
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading - self.rotationDegree;
            userLocationView.imageView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
        }];
        return;
    }
    self.userLocationCoordinate = userLocation.coordinate;
}

/**
 * @brief 根据overlay生成对应的Renderer
 * @param mapView 地图View
 * @param overlay 指定的overlay
 * @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 8;
        polylineRenderer.lineDash = YES;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {
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
    
    if ([overlay isKindOfClass:[MAMultiPolyline class]]) {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

/**
 * @brief 根据anntation生成对应的View
 * @param mapView 地图View
 * @param annotation 指定的标注
 * @return 生成的标注View
 */
- (JKMapAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    
    if(annotation && [annotation isKindOfClass:[JKMapAnnotation class]]) {
        JKMapAnnotation *mapAnnotation = (JKMapAnnotation *)annotation;
        JKMapAnnotationView *annotationView = (JKMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:JKMapMidWayIdentifier];
        if(!annotationView) {
            annotationView = [[JKMapAnnotationView alloc] initWithAnnotation:mapAnnotation reuseIdentifier:JKMapMidWayIdentifier];
        }
        annotationView.annotation = mapAnnotation;
        annotationView.tag = mapAnnotation.tag;
        return annotationView;
    }
    return (nil);
}

/**
 *  单击地图底图调用此接口
 *
 *  @param mapView    地图View
 *  @param coordinate 点击位置经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self.selectAnnoIndex >= 0 && !self.isAlwaysShowCallOutView) {
        JKMapAnnotation *preSelAnnotation = (JKMapAnnotation *)self.preSelMapAnnotationView.annotation;
        preSelAnnotation.isShowCallOutView = NO;
        preSelAnnotation.annotationType = DefaultType;
        self.preSelMapAnnotationView.annotation = preSelAnnotation;
        self.selectAnnoIndex = -1;
    }
}

/*!
 @brief 当选中一个annotation views时调用此接口
 @param mapView 地图View
 @param view 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    //如果始终显示弹出视图
    if (self.isAlwaysShowCallOutView) {
        return;
    }
    if([view.annotation isKindOfClass:[JKMapAnnotation class]]) {
        JKMapAnnotationView *mapAnnotationView = (JKMapAnnotationView *)view;
        //选中当前，取消前一个选中标签
        if (mapAnnotationView.tag-JKViewTagInterval != self.selectAnnoIndex) {
            JKMapAnnotation *ann = (JKMapAnnotation *)mapAnnotationView.annotation;
            //如果是未使能
            if (ann.annotationType == DisEnableType || ann.annotationType == UserLocType) {
                return;
            }
            ann.isShowCallOutView = YES;
            ann.annotationType = SelectType;
            mapAnnotationView.annotation = ann;
            if (self.selectAnnoIndex >= 0 && self.preSelMapAnnotationView) {
                JKMapAnnotation *preSelAnnotation = self.mapAnnotationArray[self.selectAnnoIndex];
                preSelAnnotation.isShowCallOutView = NO;
                preSelAnnotation.annotationType = DefaultType;
                self.preSelMapAnnotationView.annotation = preSelAnnotation;
            }
            self.preSelMapAnnotationView = mapAnnotationView;
            self.selectAnnoIndex = mapAnnotationView.tag-JKViewTagInterval;
            
            if (self.selectAnnotationViewBlock) {
                self.selectAnnotationViewBlock(mapAnnotationView);
            }
        }
    }
}

#pragma mark - <AMapSearchDelegate>
/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    //路径规划失败，ZJSLoadCargoMapNavFailedRetryDelayTimeInt 秒后重试
    [self performSelector:@selector(searchRoutePlanningDrive) withObject:nil afterDelay:5.0f];
}

/**
 *  路径规划查询回调
 *
 *  @param request  发起的请求，具体字段参考 AMapRouteSearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapRouteSearchResponse 。
 */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    if (!response || response.count == 0) {
        return;
    }
    self.routeCount = response.count;
    self.route = response.route;
    [self presentCurrentCourse];
    
    if (self.planRouteBlock) {
        self.planRouteBlock(response.route);
    }
}

@end
