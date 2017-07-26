//
//  MapVC.m
//  GaodeMap
//
//  Created by JayKing on 17/6/21.
//  Copyright © 2017年 JayKing. All rights reserved.
//

#import "MapVC.h"
#import "JKMapView.h"
#import "JKMapAnnotation.h"
#import "JKGPSNaviViewController.h"

@interface MapVC ()

@property (strong, nonatomic) JKMapView *mapView;

@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) NSMutableArray <JKMapAnnotation *> *anns;

@property (strong, nonatomic) JKMapAnnotation *startAnnotation;

@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"高德地图";
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    [self initView];
}

- (void)doneAction {
//    _index++;
//    if (_index > 3) {
//        _index = 0;
//    }
//    [self.mapView selectAnnotationWithIndex:_index];
//    
//    [self.mapView moveWithStartAnnotation:self.startAnnotation allAnnotations:self.anns animationCount:0 duration:5 completeCallback:^(BOOL isFinished) {
//        NSLog(@"跑完了");
//    }];

    JKGPSNaviViewController *vc = [[JKGPSNaviViewController alloc] init];
    vc.endCoordinate = CLLocationCoordinate2DMake(30.663063, 114.310681);
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initView {
    self.mapView = [[JKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    
    CLLocationCoordinate2D coordinates[4] = {
        {30.631248, 114.276761},
        {30.663063, 114.310681},
        {30.626773, 114.300908},
        {30.658590, 114.316430}
    };
    
    self.anns = [NSMutableArray array];
    for (int i = 0; i < 4; ++i)
    {
        JKMapAnnotation *annotation = [[JKMapAnnotation alloc] initWithType:DefaultType];
        annotation.coordinate = coordinates[i];
        annotation.index    = [NSString stringWithFormat:@"%d", i];
//        annotation.title = [NSString stringWithFormat:@"标题：%d", i];
//        annotation.isShowCallOutView = YES;
        annotation.defaultImage = @"annotation_1";
        annotation.selectImage = @"annotation_2";
        annotation.disEnableImage = @"annotation_3";
        annotation.userLocImage = @"car";
        [self.anns addObject:annotation];
    }
//    self.mapView.isAlwaysShowCallOutView = YES;
    self.mapView.shouldShowUserLoction = NO;
    self.mapView.mapAnnotationArray = [self.anns copy];
    
    
    NSMutableArray *wayAnnos = [NSMutableArray arrayWithArray:self.anns];
    [wayAnnos removeLastObject];
//
    JKMapAnnotation *startAnno = [[JKMapAnnotation alloc] initWithType:UserLocType];
    startAnno.coordinate = CLLocationCoordinate2DMake(30.633000, 114.280000);
    startAnno.isShowCallOutView = YES;
    startAnno.defaultImage = @"annotation_1";
    startAnno.selectImage = @"annotation_2";
    startAnno.disEnableImage = @"annotation_3";
    startAnno.userLocImage = @"car";
    [self.mapView searchRoutePlanningDriveWithStart:startAnno destination:self.anns.lastObject wayAnnotations:wayAnnos];
    
    self.startAnnotation = [[JKMapAnnotation alloc] initWithType:UserLocType];
    self.startAnnotation.coordinate = CLLocationCoordinate2DMake(30.639000, 114.280000);
    self.startAnnotation.title = @"我是老司机";
    self.startAnnotation.isShowCallOutView = YES;
    self.startAnnotation.defaultImage = @"annotation_1";
    self.startAnnotation.selectImage = @"annotation_2";
    self.startAnnotation.disEnableImage = @"annotation_3";
    self.startAnnotation.userLocImage = @"car";
    [self.mapView addAnnotation:self.startAnnotation];
    
    __weak typeof(self) weak_self = self;
    self.mapView.selectAnnotationViewBlock = ^(JKMapAnnotationView *mapAnnotationView){
        [weak_self.mapView calculateRouteDistanceWithStartAnno:weak_self.startAnnotation endAnno:weak_self.anns[mapAnnotationView.tag - JKViewTagInterval] calculateBlock:^(NSString *distance, NSString *takeTime) {
            if (![mapAnnotationView.annotation isKindOfClass:[JKMapAnnotation class]]) {
                return;
            }
            JKMapAnnotation *anno = (JKMapAnnotation *)mapAnnotationView.annotation;
            anno.title = [NSString stringWithFormat:@"距离%@, 大约%@", distance, takeTime];
            anno.isShowCallOutView = YES;
            mapAnnotationView.annotation = anno;
        }];
    };
    
    [self.mapView selectAnnotationWithIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc {
    _mapView.delegate = nil;
    _mapView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
