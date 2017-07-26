//
//  ZallMapView.h
//  GaodeMap
//
//  Created by JayKing on 17/6/21.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "JKMapAnnotation.h"
#import "MANaviRoute.h"
#import "JKMapAnnotationView.h"
#import <AMapNaviKit/AMapNaviKit.h>

static NSInteger const JKViewTagInterval = 1000;

//地图标签选中回调
typedef void(^SelectAnnotationViewBlock)(JKMapAnnotationView *annotationView);
//路径规划回调
typedef void(^PlanRouteBlock)(AMapRoute *route);
//计算路径距离回调 distance:米或公里，takeTime：xx小时xx分钟
typedef void(^CalculateRouteDistanceBlock)(NSString *distance, NSString *takeTime);

//自定义高德地图封装
@interface JKMapView : MAMapView <MAMapViewDelegate, AMapSearchDelegate, AMapNaviDriveManagerDelegate>

/**
 路径规划回调block
 */
@property (strong, nonatomic) PlanRouteBlock planRouteBlock;

/**
 选中标签回调block
 */
@property (strong, nonatomic) SelectAnnotationViewBlock selectAnnotationViewBlock;

/**
 //计算路径距离回调block
 */
@property (strong, nonatomic) CalculateRouteDistanceBlock calculateRouteDistanceBlock;

/**
 传入的标签集合
 */
@property (copy, nonatomic) NSArray<JKMapAnnotation *> *mapAnnotationArray;

/**
 用户定位图片
 */
@property (strong, nonatomic) NSString *userLocImageName;

/**
 是否显示用户定位
 */
@property (assign, nonatomic) BOOL shouldShowUserLoction;

/**
 是否始终显示弹出视图
 */
@property (assign, nonatomic) BOOL isAlwaysShowCallOutView;

/**
 选中当前标签
 
 @param index 标签index
 */
- (JKMapAnnotationView *)selectAnnotationWithIndex:(NSInteger)index;

/**
 获取标签视图

 @param index    索引
 @return 标签视图
 */
- (JKMapAnnotationView *)getMapAnnotationView:(NSInteger)index;


/**
 路径规划

 @param startAnnotation 起始点
 @param destinationAnnotation 终点
 @param wayAnnotations 途经点
 */
- (void)searchRoutePlanningDriveWithStart:(MAPointAnnotation *)startAnnotation destination:(MAPointAnnotation *)destinationAnnotation wayAnnotations:(NSArray *)wayAnnotations;

/**
 *  @brief  计算出路径距离和时间
 */
- (void)calculateRouteDistanceWithStartAnno:(MAAnimatedAnnotation *)startAnno endAnno:(MAAnimatedAnnotation *)endAnno calculateBlock:(CalculateRouteDistanceBlock)block;

/**
 选择路径

 @param index 路径索引
 */
- (void)selectRouteWithIndex:(NSInteger)index;

/**
 标签平滑

 @param anno 起始标签
 @param annos 所有经过的标签
 @param count 动画组数，传入0则为annos.count
 @param duration 移动时间
 @param completeCallback 结束回调
 */
- (void)moveWithStartAnnotation:(JKMapAnnotation *)anno allAnnotations:(NSArray <JKMapAnnotation *>*)annos animationCount:(NSInteger)count duration:(CGFloat)duration completeCallback:(void(^)(BOOL isFinished))completeCallback;

@end
