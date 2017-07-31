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
#import "Opus.h"

#define OPUS_FRAME_SIZE 320
#define OPUS_COMPLEXITY 8
#define OPUS_FRAME_SAMPLE_RATE 16000
#define OPUS_BITRATE_BPS 16000

@interface ViewController ()
{
    AudioQueueRecord *audioQueueRecord;
    AudioQueuePlay *audioQueuePlay;
    Opus *_opus;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
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

    _opus=[[Opus alloc] init:OPUS_FRAME_SAMPLE_RATE withBitrateBps:OPUS_BITRATE_BPS withComplexity:OPUS_COMPLEXITY withFrameSize:OPUS_FRAME_SIZE];
    audioQueueRecord=[[AudioQueueRecord alloc] init:_opus withSampleRate:OPUS_FRAME_SAMPLE_RATE];
    audioQueuePlay=[[AudioQueuePlay alloc] init:_opus withSampleRate:OPUS_FRAME_SAMPLE_RATE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) onBtnEvent:(UIButton*) btn
{
    switch (btn.tag) {
        case 101:
            NSLog(@"开始录音");
            [audioQueueRecord startRecording];
            break;
        case 102:
            NSLog(@"结束录音并播放");
            [audioQueueRecord stopRecording];
            NSMutableArray *pcmDatas = [audioQueueRecord pcmDatas];
            for (int i=0; i<pcmDatas.count; i++)
            {
                [audioQueuePlay playWithData:pcmDatas[i]];
            }
            break;
    }
}

@end
