//
//  Test.m
//  Opus
//
//  Created by Devin Lee on 2017/7/30.
//  Copyright © 2017年 devin. All rights reserved.
//

#import "TestRecord.h"
#import <AVFoundation/AVFoundation.h>

@interface TestRecord()
{
    NSString *filePath;
}
@property (nonatomic, strong) AVAudioSession *avAudioSession;
@property (nonatomic, strong) AVAudioRecorder *avAudioRecorder;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址

@end

@implementation TestRecord

//-(id)init:(NSString *)name withAge:(NSInteger)age
//{
//    self=[super init];
//    if(self!=nil)
//    {
//        _name=name;
//        _age=age;
//    }
//    
//    return self;
//}
//
//-(void)test
//{
//    NSLog(@"test void");
//}
//
//-(void)showInfo
//{
//    [self test];
//    NSLog(@"showInfo void");
//}
-(id)init
{
    self=[super init];
    _avAudioSession=[AVAudioSession sharedInstance];
    NSError *sessionError;
    [_avAudioSession setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if(_avAudioSession==nil)
    {
        NSLog(@"创建 AVAudioSession 出错:%@", [sessionError description]);
    }
    else
    {
        [_avAudioSession setActive:YES error:nil];
    }
    self.avAudioSession=_avAudioSession;
    NSDictionary *recordSetting=[[NSDictionary alloc] initWithObjectsAndKeys:
                                 //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                 [NSNumber numberWithFloat:8000.0],AVSampleRateKey,
                                 // 音频格式
                                 [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                 //采样位数  8、16、24、32 默认为16
                                 [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                 // 音频通道数 1 或 2
                                 [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                 //录音质量
                                 [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                 nil];
    
    //1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingString:@"/RRecord.wav"];
    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    _avAudioRecorder=[[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:recordSetting error:nil];
    
    return self;
}

- (void)startRecord
{
    NSLog(@"开始录音");
    if (_avAudioRecorder) {
        _avAudioRecorder.meteringEnabled = YES;
        [_avAudioRecorder prepareToRecord];
        [_avAudioRecorder record];
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
    }
}

- (void)stopRecord
{
    NSLog(@"停止并播放录音");
    
    if ([self.avAudioRecorder isRecording]) {
        [self.avAudioRecorder stop];
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        NSLog(@"录了文件大小为 %1f",[[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0);
        
        [self.avAudioRecorder stop];
        if ([self.avAudioPlayer isPlaying])return;
        self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFileUrl error:nil];
        NSLog(@"%li",self.avAudioPlayer.data.length/1024);
        [self.avAudioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.avAudioPlayer play];
    }else{
        NSLog(@"录音文件不存在");
    }
}

@end
