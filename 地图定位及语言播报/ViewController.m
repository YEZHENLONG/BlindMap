//
//  ViewController.m
//  地图定位及语言播报
//
//  Created by 叶振龙 on 2/16/16.
//  Copyright © 2016 叶振龙. All rights reserved.
//

#import "ViewController.h"
#import "NaviViewController.h"

@interface ViewController () <MAMapViewDelegate, AMapLocationManagerDelegate, IFlySpeechSynthesizerDelegate>


@property (nonatomic, strong) AMapLocationManager *mgr;

@property (nonatomic, strong) UIButton *mapTypeButton;
@property (nonatomic, strong) UIButton *showTrafficButton;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) NaviViewController *naviVc;
@property (nonatomic, assign) BOOL timeReport;
@property (nonatomic, strong) NSTimer *myTimer;// 定时播报
@property (nonatomic, assign) BOOL onceVoice;
@end


@implementation ViewController



- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self apiKeyValue];
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    
    [self.mgr startUpdatingLocation];

    _mapView.showsUserLocation = YES;
    
    [_mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES]; //地图跟着位置移动
    
    [self setTranfficButton];
    [self setTypeButton];
    [self setLocationButton];
    [self setLocationNameLabel];
    [self setGPSNavi];
    [self settimeBroadcasting];
    
    _onceVoice = YES;
    [self xunFeiVoice1];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self xunFeiVoice];
        });
    
}



- (void)apiKeyValue{
    // 高德地图模块
    [MAMapServices sharedServices].apiKey = @"6fd3bd40d0268260adaad7d7ae83506f";
    [AMapLocationServices sharedServices].apiKey = @"6fd3bd40d0268260adaad7d7ae83506f";
    // 讯飞语音模块
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", @"56c8716d" ];
    [IFlySpeechUtility createUtility:initString];
}

- (void)onCompleted:(IFlySpeechError *)error{
    
}


- (void)setLocationNameLabel{
    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.textAlignment = UITextAlignmentCenter;
    self.resultLabel.backgroundColor = [UIColor grayColor];
    self.resultLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:self.resultLabel];
    
    self.resultLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 水平居中
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:self.view.frame.size.width];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:self.resultLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:70];
    
    [self.view addConstraints:@[btnY, btnW, btnH]];
}

- (void)setLocationButton{
    UIButton *locationBtn = [[UIButton alloc] init];
    [locationBtn addTarget:self action:@selector(locationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed:@"dingwei"];
    [locationBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.view addSubview:locationBtn];
    
    locationBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *btnX = [NSLayoutConstraint constraintWithItem:locationBtn attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:locationBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-100];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:locationBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:40];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:locationBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    
    [self.view addConstraints:@[btnX, btnY, btnW, btnH]];
}

- (void)locationBtnClick:(UIButton *)btn{
    [_mapView setUserTrackingMode: MAUserTrackingModeFollowWithHeading animated:YES]; //地图跟着位置移动
    [self xunFeiVoice];
}

- (void)xunFeiVoice{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // 创建合成对象，为单例模式
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    //设置语音合成的参数
    //语速,取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    //音量;取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表
    [_iFlySpeechSynthesizer setParameter:@" xiaoyan " forKey: [IFlySpeechConstant VOICE_NAME]];
    //音频采样率,目前支持的采样率有 16000 和 8000
    [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    //asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iFlySpeechSynthesizer setParameter:@" tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    //启动合成会话
    [_iFlySpeechSynthesizer startSpeaking:appDelegate.pmName];
}

- (void)xunFeiVoice1{
    
    // 创建合成对象，为单例模式
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    //设置语音合成的参数
    //语速,取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];
    //音量;取值范围 0~100
    [_iFlySpeechSynthesizer setParameter:@"50" forKey: [IFlySpeechConstant VOLUME]];
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表
    [_iFlySpeechSynthesizer setParameter:@" vixy " forKey: [IFlySpeechConstant VOICE_NAME]];
    //音频采样率,目前支持的采样率有 16000 和 8000
    [_iFlySpeechSynthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];
    //asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iFlySpeechSynthesizer setParameter:@" tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    
    
    if (_onceVoice) {
        NSString *string = @"欢迎使用My Map，一款为眼睛残疾人士提供的地图应用。您可以尝试触摸屏幕左方高度在距离Home键两厘米处手动实时播报当前地理位置，也可以点击同样高度的右方屏幕选择定时播报服务，播报间隔为三分钟一次。";
        //启动合成会话
        [_iFlySpeechSynthesizer startSpeaking:string];
        _onceVoice = NO;
    }else{
        NSString *string = @"定时播报开启";
        [_iFlySpeechSynthesizer startSpeaking:string];
    }
    
    
}


- (void)settimeBroadcasting{
    
    self.timeReport = NO;
    
    UIButton *reportBtn = [[UIButton alloc] init];
    [reportBtn addTarget:self action:@selector(settimeBroadcastingAction:) forControlEvents:UIControlEventTouchUpInside];
    [reportBtn setTitle:@"定时播报" forState:UIControlStateNormal];
    [reportBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reportBtn setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:reportBtn];
    
    reportBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *btnX = [NSLayoutConstraint constraintWithItem:reportBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:reportBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:532];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:reportBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:80];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:reportBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    [self.view addConstraints:@[btnX, btnY, btnW, btnH]];
}

- (void)settimeBroadcastingAction:(UIButton *)btn{
    if (!self.timeReport) {
        self.timeReport = YES;
        
        [self xunFeiVoice1];
        
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        self.myTimer = [NSTimer timerWithTimeInterval:30.0 target:self selector:@selector(xunFeiVoice) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.myTimer forMode:NSDefaultRunLoopMode];
        
    }else{
        self.timeReport = NO;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.myTimer invalidate];
    }
    
}

- (void)setGPSNavi{
    UIButton *naviBtn = [[UIButton alloc] init];
    [naviBtn addTarget:self action:@selector(GPSNaviClick:) forControlEvents:UIControlEventTouchUpInside];
    [naviBtn setTitle:@"导航" forState:UIControlStateNormal];
    [naviBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [naviBtn setFont:[UIFont systemFontOfSize:20]];
    [self.view addSubview:naviBtn];
    
    naviBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *btnX = [NSLayoutConstraint constraintWithItem:naviBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-50];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:naviBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:180];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:naviBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:80];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:naviBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    [self.view addConstraints:@[btnX, btnY, btnW, btnH]];
}

- (void)GPSNaviClick:(UIButton *)btn{
    if (self.naviVc == nil) {
        self.naviVc = [[NaviViewController alloc] init];
    }
    [self.navigationController pushViewController:self.naviVc animated:YES];
}

- (void)setTypeButton{
    UIButton *typeBtn = [[UIButton alloc] init];
    [typeBtn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    [typeBtn setTitle:@"卫星地图" forState:UIControlStateNormal];
    // 设置按钮控件在普通状态下的字体颜色
    [typeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [typeBtn setFont:[UIFont systemFontOfSize:20]];
    
    [self.view addSubview:typeBtn];
    
    typeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *btnX = [NSLayoutConstraint constraintWithItem:typeBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-50];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:typeBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:130];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:typeBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:80];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:typeBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    [self.view addConstraints:@[btnX, btnY, btnW, btnH]];
}

- (void)typeBtnClick:(UIButton *)btn{
    if (_mapView.mapType != MAMapTypeSatellite) {
        _mapView.mapType = MAMapTypeSatellite;
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    }else{
        _mapView.mapType = MAMapTypeStandard;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }
}


- (void)setTranfficButton{
    // 创建按钮控件
    UIButton *btn = [[UIButton alloc] init];
    
    [btn addTarget:self action:@selector(tranfficBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn setTitle:@"路况" forState:UIControlStateNormal];
    // 设置按钮控件在普通状态下的字体颜色
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setFont:[UIFont systemFontOfSize:20]];
    
    // 将设置好的按钮空间添加到当前view中
    [self.view addSubview:btn];
    
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *btnX = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-50];
    NSLayoutConstraint *btnY = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:80];
    NSLayoutConstraint *btnW = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:80];
    NSLayoutConstraint *btnH = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:40];
    
    [self.view addConstraints:@[btnX, btnY, btnW, btnH]];
}


- (void)tranfficBtnClick:(UIButton *)btn{
    
    if (_mapView.showTraffic == NO) {
        _mapView.showTraffic = YES;
//        UIImage *image = [UIImage imageNamed:@"lukuangon"];
//        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    }else{
        _mapView.showTraffic = NO;
//        UIImage *image = [UIImage imageNamed:@"lukuangoff"];
//        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];


    }
}


- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
    if (updatingLocation) {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            // 将之前的内容清空
            self.resultLabel.text = @"";
            
            // 判断是否有结果
            if (placemarks.count == 0 || error != nil) return;
            
            // placemarks里面存放CLPlacemark对象
            for (CLPlacemark *pm in placemarks) {
                // 3.显示信息在结果Label上
                self.resultLabel.text = pm.name;
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                appDelegate.pmName = pm.name;

        }

        }];
    }
}



- (AMapLocationManager *)mgr{
    if (_mgr == nil) {
        _mgr = [[AMapLocationManager alloc] init];
        _mgr.delegate = self;
        _mgr.distanceFilter = 20;
        _mgr.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return _mgr;
}

#pragma mark - 懒加载
- (CLGeocoder *)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
