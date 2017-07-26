//
//  ZJSLoadCargoAnnotation.h
//  ZJS-DRIVER
//
//  Created by JeoKing on 17/6/28.
//  Copyright © 2017年 zall. All rights reserved.
//

#import <MAMapKit/MAAnnotation.h>
#import <MAMapKit/MAMapKit.h>

typedef NS_ENUM(NSUInteger, AnnotationType) {
    DefaultType = 0, //默认类型
    SelectType,      //选中类型
    DisEnableType,   //未使能类型，无法点击选中
    UserLocType,     //用户坐标类型，无法点击选中
};


/**
 地图标签model
 */
@interface JKMapAnnotation : MAAnimatedAnnotation

/**
 *  标注view中心坐标
 */
//@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 *  标题
 */
//@property (nonatomic, copy) NSString *title;

/**
 *  副标题
 */
//@property (nonatomic, copy) NSString *subtitle;

/**
 *  编号
 */
@property (nonatomic, copy) NSString *index;

/**
 *  默认字体颜色
 */
@property (nonatomic, copy) UIColor *defaultIndexColor;

/**
 *  选中字体颜色
 */
@property (nonatomic, copy) UIColor *selectIndexColor;

/**
 *  未使能字体颜色
 */
@property (nonatomic, copy) UIColor *disEnableIndexColor;

/**
 *  默认图片名称
 */
@property (nonatomic, copy) NSString *defaultImage;

/**
 *  选中图片名称
 */
@property (nonatomic, copy) NSString *selectImage;

/**
 *  未使能图片名称
 */
@property (nonatomic, copy) NSString *disEnableImage;

/**
 *  用户定位标签图片
 */
@property (nonatomic, copy) NSString *userLocImage;

/**
 *  地图标签tag
 */
@property (nonatomic, assign) NSInteger tag;

/**
 *  是否显示弹出标题
 */
@property (nonatomic, assign) BOOL isShowCallOutView;

/**
 *  @brief  类型
 */
@property (nonatomic, assign) AnnotationType annotationType;

/**
 初始化

 @param annotationType 类型 默认DefaultType
 @return self
 */
- (instancetype)initWithType:(AnnotationType)annotationType;

@end
