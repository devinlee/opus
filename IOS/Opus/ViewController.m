//
//  ViewController.m
//  Opus
//
//  Created by Devin Lee on 2017/7/30.
//  Copyright © 2017年 devin. All rights reserved.
//

#import "ViewController.h"
#import "AudioQueueRecord.h"
#import "AudioQueuePlay.h"
//#import "TestRecord.h"

@interface ViewController ()
{
    AudioQueueRecord *audioQueueRecord;
    AudioQueuePlay *audioQueuePlay;
//    TestRecord *testRecord;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* btn1 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn1.frame=CGRectMake(100, 100, 100, 50);
    [btn1 setTitle:@"开始录音" forState:UIControlStateNormal];
    btn1.tag=101;
    [btn1 addTarget:self action:@selector(onBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];

    UIButton* btn2 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn2.tag=102;
    btn2.frame=CGRectMake(100, 160, 100, 50);
    [btn2 setTitle:@"结束录音" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(onBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

    audioQueueRecord=[[AudioQueueRecord alloc] init];
    audioQueuePlay=[[AudioQueuePlay alloc] init];
    
//    testRecord=[[TestRecord alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onBtnEvent:(UIButton*) btn
{
    switch (btn.tag) {
        case 101:
            NSLog(@"开始录音");
            [audioQueueRecord startRecording];
//            [testRecord  startRecord];
            break;
        case 102:
            NSLog(@"结束录音并播放");
//            [testRecord stopRecord];
            
            [audioQueueRecord stopRecording];
            
            
            NSMutableArray *_data = [audioQueueRecord getData];
            for (NSInteger i=0; i<_data.count; i++) {
                [audioQueuePlay playWithData:_data[i]];
            }
            break;
    }
}

@end
