//
//  SecondViewController.h
//  UITest2Bar
//
//  Created by pinky on 2017/9/28.
//  Copyright © 2017年 youme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface ParamViewController : UIViewController
{
@public
    ParamSetting* params;
    BOOL bInited;
}

- (IBAction)onClickFinish:(id)sender;


@property (retain, nonatomic) IBOutlet UITextField *tf_width;
@property (retain, nonatomic) IBOutlet UITextField *tf_height;
@property (retain, nonatomic) IBOutlet UITextField *tf_interval;
@property (retain, nonatomic) IBOutlet UITextField *tf_bitrate;
@property (retain, nonatomic) IBOutlet UITextField *tf_farendLevel;

@property (retain, nonatomic) IBOutlet UISwitch *tf_open_hw;
@property (retain, nonatomic) IBOutlet UISwitch *tf_high_audio;

@property (weak, nonatomic) IBOutlet UISwitch *push_stream;


@end

