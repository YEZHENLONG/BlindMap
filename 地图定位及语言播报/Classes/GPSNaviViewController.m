//
//  GPSNaviViewController.m
//  officialDemoNavi
//
//  Created by LiuX on 14-9-1.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "GPSNaviViewController.h"

@interface GPSNaviViewController () <AMapNaviViewControllerDelegate>

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic, strong) AMapNaviPoint* startPoint;
@property (nonatomic, strong) AMapNaviPoint* endPoint;

@end

@implementation GPSNaviViewController

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        _startPoint = [AMapNaviPoint locationWithLatitude:39.993862 longitude:116.473155];
        _endPoint   = [AMapNaviPoint locationWithLatitude:39.983456 longitude:116.315495];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNaviViewController];
    [self configSubViews];
}

#pragma mark - Init & Construct

- (void)initNaviViewController
{
    if (_naviViewController == nil)
    {
        _naviViewController = [[AMapNaviViewController alloc] initWithDelegate:self];
    }
}

- (void)configSubViews
{
    UILabel *startPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 20)];
    
    startPointLabel.textAlignment = NSTextAlignmentCenter;
    startPointLabel.font = [UIFont systemFontOfSize:14];
    startPointLabel.text = [NSString stringWithFormat:@"起 点：%f, %f", _startPoint.latitude, _startPoint.longitude];
    
    [self.view addSubview:startPointLabel];
    
    UILabel *endPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, 320, 20)];
    
    endPointLabel.textAlignment = NSTextAlignmentCenter;
    endPointLabel.font = [UIFont systemFontOfSize:14];
    endPointLabel.text = [NSString stringWithFormat:@"终 点：%f, %f", _endPoint.latitude, _endPoint.longitude];
    
    [self.view addSubview:endPointLabel];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    startBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    startBtn.layer.borderWidth  = 0.5;
    startBtn.layer.cornerRadius = 5;
    
    [startBtn setFrame:CGRectMake(60, 160, 200, 30)];
    [startBtn setTitle:@"实时导航" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [startBtn addTarget:self action:@selector(startGPSNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:startBtn];
}

#pragma mark - Button Action

- (void)startGPSNavi:(id)sender
{
    // 算路
    [self calculateRoute];
}

- (void)calculateRoute
{
    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];
    
    [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];
}

#pragma mark - AMapNaviManager Delegate

- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    [super naviManager:naviManager didPresentNaviViewController:naviViewController];
    
    [self.naviManager startGPSNavi];
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super naviManagerOnCalculateRouteSuccess:naviManager];
    
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
}

#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

- (void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController
{
    if (self.naviViewController.viewShowMode == AMapNaviViewShowModeCarNorthDirection)
    {
        self.naviViewController.viewShowMode = AMapNaviViewShowModeMapNorthDirection;
    }
    else
    {
        self.naviViewController.viewShowMode = AMapNaviViewShowModeCarNorthDirection;
    }
}

- (void)naviViewControllerTurnIndicatorViewTapped:(AMapNaviViewController *)naviViewController
{
    [self.naviManager readNaviInfoManual];
}

@end
