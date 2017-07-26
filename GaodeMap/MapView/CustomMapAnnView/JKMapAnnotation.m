//
//  ZJSLoadCargoAnnotation.m
//  ZJS-DRIVER
//
//  Created by so on 16/8/4.
//  Copyright © 2016年 zall. All rights reserved.
//

#import "JKMapAnnotation.h"

@implementation JKMapAnnotation

/**
 *  @brief  便利方法
 */
- (instancetype)initWithType:(AnnotationType)annotationType {
    self = [super init];
    if(self) {
        self.annotationType = annotationType;
        self.defaultIndexColor = [UIColor lightGrayColor];
        self.selectIndexColor = [UIColor whiteColor];
        self.disEnableIndexColor = [UIColor whiteColor];
        return self;
    }
    return nil;
}

@end
