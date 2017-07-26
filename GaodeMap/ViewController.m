//
//  ViewController.m
//  GaodeMap
//
//  Created by JayKing on 17/6/21.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import "ViewController.h"
#import "MapVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"高德地图测试";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"高德地图" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 100, 20);
    btn.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [btn addTarget:self action:@selector(gotoMap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)gotoMap {
    MapVC *mapVC = [[MapVC alloc] init];
    [self.navigationController pushViewController:mapVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
