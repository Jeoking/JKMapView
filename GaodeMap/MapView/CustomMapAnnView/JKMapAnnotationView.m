//
//  ZJSLoadCargoAnnotationView.m
//  ZJS-DRIVER
//
//  Created by so on 16/8/4.
//  Copyright © 2016年 All rights reserved.
//
#import "JKMapAnnotationView.h"
#import "JKMapAnnotation.h"
#import "JKCustomCallOutView.h"

@interface JKMapAnnotationView ()
/**
 *  @brief  详细视图
 */
@property (strong, nonatomic) JKCustomCallOutView *detailView;
/**
 *  @brief  索引标签
 */
@property (strong, nonatomic, readonly) UILabel *indexLabel;
@end

@implementation JKMapAnnotationView
@synthesize indexLabel = _indexLabel;

#pragma mark - life cycle
/**
 *  @brief  内存释放
 */
- (void)dealloc {
    
}

/**
 *  @brief  初始化方法
 */
- (instancetype)initWithAnnotation:(JKMapAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        self.enabled = YES;
        [self addSubview:self.detailView];
        [self bringSubviewToFront:self.detailView];
        [self addSubview:self.indexLabel];
        [self bringSubviewToFront:self.indexLabel];
    }
    return (self);
}
#pragma mark -

#pragma mark - override
/**
 *  @brief  重新布局
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    self.indexLabel.center = CGPointMake(self.width / 2.0f, self.height / 2.0f - 1.5f);
    self.detailView.height = ceilf(self.detailView.textLabel.font.lineHeight) + 16.0f;
    self.detailView.centerX = self.indexLabel.centerX;
    self.detailView.bottom = self.indexLabel.top - 2.0f;
}

/**
 *  @brief  当从reuse队列里取出时被调用, 子类重新必须调用super
 */
- (void)prepareForReuse {
    [super prepareForReuse];
    self.image = nil;
    self.indexLabel.text = nil;
}
#pragma mark -

#pragma mark - setter
/**
 *  @brief  设置点
 */
- (void)setAnnotation:(id <MAAnnotation>)annotation {
    [super setAnnotation:annotation];
    if(annotation && [annotation isKindOfClass:[JKMapAnnotation class]]) {
        //位置偏移
        CGPoint centerOffset = self.centerOffset;
        centerOffset.y = - self.height / 2.0f + 4.0f;
        self.centerOffset = centerOffset;
        
        JKMapAnnotation *ann = (JKMapAnnotation *)annotation;
        self.indexLabel.text = ann.index;
        self.detailView.text = ann.title;
        self.detailView.hidden = (!ann.isShowCallOutView || ann.title.length == 0);
        switch (ann.annotationType) {
            case DefaultType:
            {
                self.image = [UIImage imageNamed:ann.defaultImage];
                self.indexLabel.textColor = ann.defaultIndexColor;
            }
                break;
            case SelectType:
            {
                self.image = [UIImage imageNamed:ann.selectImage];
                self.indexLabel.textColor = ann.selectIndexColor;
            }
                break;
            case DisEnableType:
            {
                self.image = [UIImage imageNamed:ann.disEnableImage];
                self.indexLabel.textColor = ann.disEnableIndexColor;
            }
                break;
            case UserLocType:
            {
                self.image = [UIImage imageNamed:ann.userLocImage];
                self.indexLabel.textColor = ann.defaultIndexColor;
            }
                break;
            default:
                break;
        }
        [self setNeedsLayout];
    } else {
        self.detailView.hidden = YES;
    }
}
#pragma mark -

#pragma mark - getter

/**
 *  @brief  详情视图
 */
- (JKCustomCallOutView *)detailView {
    if(!_detailView) {
        _detailView = [[JKCustomCallOutView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _detailView.backgroundColor = [UIColor clearColor];
    }
    return (_detailView);
}

/**
 *  @brief  索引标签
 */
- (UILabel *)indexLabel {
    if(!_indexLabel) {
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont systemFontOfSize:14.0f];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
    }
    return (_indexLabel);
}
#pragma mark -

@end
