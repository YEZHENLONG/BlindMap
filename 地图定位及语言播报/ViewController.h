//
//  ViewController.h
//  地图定位及语言播报
//
//  Created by 叶振龙 on 2/16/16.
//  Copyright © 2016 叶振龙. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <iflyMSC/IFlySpeechSynthesizerDelegate.h>
#import <iflyMSC/IFlySpeechSynthesizer.h>
#import <iflyMSC/iflyMSC.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
//#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

@interface ViewController : UIViewController
{
    MAMapView *_mapView;
    IFlySpeechSynthesizer *_iFlySpeechSynthesizer;
}
@end

