//
//  NaviViewController.m
//  地图定位及语言播报
//
//  Created by 叶振龙 on 16/5/16.
//  Copyright © 2016年 叶振龙. All rights reserved.
//

#import "NaviViewController.h"
#import "MapNavigationManager.h"

@interface NaviViewController ()
@property (weak, nonatomic) IBOutlet UITextField *start;
@property (weak, nonatomic) IBOutlet UITextField *end;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *naviActionButton;

@end

@implementation NaviViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.start resignFirstResponder];
    [self.end resignFirstResponder];
}

- (IBAction)startTextField_DidEndOnExit:(id)sender {
    [self.end becomeFirstResponder];
}
- (IBAction)endTextField_DidEndOnExit:(id)sender {
    [sender resignFirstResponder];
    
    [self.naviActionButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)naviAction:(UIButton *)sender {
    
    if (_cityLabel.text.length == 0 || _start.text.length == 0 || _end.text.length == 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"重要提示" message:@"起点和终点不能为空" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alertView show];
        
    }
    
    [MapNavigationManager showSheetWithCity:_cityLabel.text start:_start.text end:_end.text];
}



@end
