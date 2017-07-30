#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioQueueRecord.h"
#import "Opus.h"

#define RECORDER_NOTIFICATION_CALLBACK_NAME @"recorderNotificationCallBackName"
#define kNumberAudioQueueBuffers 3  //定义了三个缓冲区
#define kDefaultBufferDurationSeconds 0.02   //调整这个值使得录音的缓冲区大小
#define kDefaultSampleRate 16000   //定义采样率为8000

#define OPUS_FRAME_SIZE 320
#define OPUS_COMPLEXITY 8
#define OPUS_FRAME_SAMPLE_RATE 16000
#define OPUS_BITRATE_BPS 16000


@interface AudioQueueRecord()
{
    //音频输入队列
    AudioQueueRef _audioQueue;
    
    //音频输入数据format
    AudioStreamBasicDescription _recordFormat;
    
    //音频输入缓冲区
    AudioQueueBufferRef _audioBuffers[kNumberAudioQueueBuffers];
    
    Opus *_opus2;
    
    NSMutableArray *_pcmDatas2;
}

@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) int sampleRate;
@property (atomic, assign) double bufferDurationSeconds;
@property (atomic, assign) NSMutableArray *pcmDatas;
@property (atomic, assign) Opus *opus;
@end

@implementation AudioQueueRecord
- (id)init
{
    self = [super init];
    if (self) {
        _opus2=[[Opus alloc] init:OPUS_FRAME_SAMPLE_RATE withBitrateBps:OPUS_BITRATE_BPS withComplexity:OPUS_COMPLEXITY withFrameSize:OPUS_FRAME_SIZE];
        _pcmDatas2=[[NSMutableArray alloc] init];
        
        self.opus=_opus2;
        self.pcmDatas=_pcmDatas2;
        self.sampleRate = kDefaultSampleRate;
        self.bufferDurationSeconds = kDefaultBufferDurationSeconds;

//        设置录音的format数据
        [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:self.sampleRate];
    }
    return self;
}

-(void)startRecording
{
    NSError *error = nil;
    //设置audio session的category
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    
    //启用audio session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }
    _recordFormat.mSampleRate = self.sampleRate;
    //初始化音频输入队列
    AudioQueueNewInput(&_recordFormat, inputBufferHandler2, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    //计算估算的缓存区大小
    int frames = (int)ceil(self.bufferDurationSeconds * _recordFormat.mSampleRate);
    int bufferByteSize = frames * _recordFormat.mBytesPerFrame;
    NSLog(@"缓冲区大小:%d",bufferByteSize);
    
    //创建缓冲器
    for (int i = 0; i < kNumberAudioQueueBuffers; ++i){
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
    }
    
    // 开始录音
    AudioQueueStart(_audioQueue, NULL);
    self.isRecording = YES;
}

-(void)stopRecording
{
    if (self.isRecording) {
        
        self.isRecording = NO;
        //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

// 设置录音格式
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(NSInteger)sampeleRate
{
    //重置下
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    //设置采样率，这里先获取系统默认的测试下 //TODO:
    //采样率的意思是每秒需要采集的帧数
    _recordFormat.mSampleRate = sampeleRate;//[[AVAudioSession sharedInstance] sampleRate];
    //设置通道数,这里先使用系统的测试下 //TODO:
    _recordFormat.mChannelsPerFrame = 1;//(UInt32)[[AVAudioSession sharedInstance] inputNumberOfChannels];
    //    NSLog(@"sampleRate:%f,通道数:%d",_recordFormat.mSampleRate,_recordFormat.mChannelsPerFrame);
    //设置format，怎么称呼不知道。
    _recordFormat.mFormatID = inFormatID;
    if (inFormatID == kAudioFormatLinearPCM)
    {
        //这个屌属性不知道干啥的。，
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //每个通道里，一帧采集的bit数目
        _recordFormat.mBitsPerChannel = 16;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mFramesPerPacket = 1;
    }
}

-(NSMutableArray *)getData
{
    return self.pcmDatas;
}

void inputBufferHandler2(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
        AudioQueueRecord *recorder = (__bridge AudioQueueRecord*)inUserData;
        if (inNumPackets > 0) {
            NSMutableData *pcmData = [[NSMutableData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
            if (pcmData&&pcmData.length>0) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:RECORDER_NOTIFICATION_CALLBACK_NAME object:pcmData];
                NSMutableData *encoderOut=[[NSMutableData alloc] initWithCapacity:OPUS_FRAME_SIZE];
                int encLen = [recorder.opus encode:pcmData withEncoderOut:encoderOut];
                [recorder.pcmDatas addObject:encoderOut];
                NSLog(@"pcmData: %1d", encLen);
            }
        }
    
        if (recorder.isRecording) {
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        }
}
@end
