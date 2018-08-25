//
//  GaodeMap
//
//  Created by JayKing on 17/6/23.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDAutoLayout.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface JKCustomCallOutView : UIView

/**
 *  @brief  文本
 */
@property (strong, nonatomic, readonly) UILabel *textLabel;

@property (strong, nonatomic) NSString *text;

@end
