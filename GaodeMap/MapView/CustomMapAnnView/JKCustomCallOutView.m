//
//  GaodeMap
//
//  Created by JayKing on 17/6/23.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import "JKCustomCallOutView.h"

/**
 *  @brief  角高度
 */
static CGFloat const JKCallOutViewConerHeight  = 4.0f;


@implementation JKCustomCallOutView

@synthesize textLabel = _textLabel;

#pragma mark - life cycle
/**
 *  @brief  初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.textLabel];
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
    self.textLabel.height = self.height - JKCallOutViewConerHeight;
    self.textLabel.centerX = self.width / 2.0f;
    self.textLabel.top = 0;
}

- (void)drawRect:(CGRect)rect {
    //角宽
    CGFloat cornerWidth = JKCallOutViewConerHeight;
    //角高
    CGFloat cornerHeight = 2.0f;
    //填充路径
    CGRect fillRect = UIEdgeInsetsInsetRect(self.textLabel.frame, UIEdgeInsetsMake(1.0f, -6.0f, 1.0f, -6.0f));
    //最小x
    CGFloat minx = CGRectGetMinX(fillRect);
    //最小y
    CGFloat miny = CGRectGetMinY(fillRect);
    //x中值
    CGFloat midx = CGRectGetMidX(fillRect);
    //最大x
    CGFloat maxx = CGRectGetMaxX(fillRect);
    //最大y
    CGFloat maxy = CGRectGetMaxY(fillRect);
    
    //创建路径，带角的线框
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(minx + cornerHeight, miny)];
    [path moveToPoint:CGPointMake(maxx - cornerHeight, miny)];
    [path addQuadCurveToPoint:CGPointMake(maxx, miny + cornerHeight) controlPoint:CGPointMake(maxx, miny)];
    [path addLineToPoint:CGPointMake(maxx, maxy - cornerHeight)];
    [path addQuadCurveToPoint:CGPointMake(maxx - cornerHeight, maxy) controlPoint:CGPointMake(maxx, maxy)];
    [path addLineToPoint:CGPointMake(midx + cornerWidth, maxy)];
    [path addLineToPoint:CGPointMake(midx, maxy + cornerWidth)];
    [path addLineToPoint:CGPointMake(midx - cornerWidth, maxy)];
    [path addLineToPoint:CGPointMake(minx + cornerHeight, maxy)];
    [path addQuadCurveToPoint:CGPointMake(minx, maxy - cornerHeight) controlPoint:CGPointMake(minx, maxy)];
    [path addLineToPoint:CGPointMake(minx, miny + cornerHeight)];
    [path addQuadCurveToPoint:CGPointMake(minx + cornerHeight, miny) controlPoint:CGPointMake(minx, miny)];
    //封闭路径
    [path closePath];
    
    //绘图设备上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //获取失败则停止向下处理
    if(!ctx) {
        return;
    }
    
    //推入栈
    UIGraphicsPushContext(ctx);
    
    //设置填充颜色
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    //填充
    CGContextFillPath(ctx);
    
    //设置填充颜色
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    //添加路径
    CGContextAddPath(ctx, path.CGPath);
    //填充路径
    CGContextFillPath(ctx);
    
    //线宽
    CGContextSetLineWidth(ctx, 1.0f / [UIScreen mainScreen].scale);
    //设置线条颜色
    CGContextSetStrokeColorWithColor(ctx, UIColorFromRGB(0xaaaaaa).CGColor);
    //添加路径
    CGContextAddPath(ctx, path.CGPath);
    //画线
    CGContextStrokePath(ctx);
    //推出栈
    UIGraphicsPopContext();
}
#pragma mark -

#pragma mark - getter
- (NSString *)text {
    return (self.textLabel.text);
}

- (UILabel *)textLabel {
    if(!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = UIColorFromRGB(0x222222);
        _textLabel.font = [UIFont systemFontOfSize:12.0f];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return (_textLabel);
}
#pragma mark -

#pragma mark - setter
/**
 *  @brief  设置文本
 */
- (void)setText:(NSString *)text {
    self.textLabel.text = text;
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}];
    self.textLabel.width = ceilf(textSize.width);
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
#pragma mark -

@end
