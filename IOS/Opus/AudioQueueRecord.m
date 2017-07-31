#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioQueueRecord.h"
#import "Opus.h"

#define RECORDER_NOTIFICATION_CALLBACK_NAME @"recorderNotificationCallBackName"
#define kNumberAudioQueueBuffers 3  //定义3个缓冲区
#define kDefaultBufferDurationSeconds 0.02   //调整这个值使得录音的缓冲区大小

@interface AudioQueueRecord()
{
    AudioQueueRef _audioQueue;//音频输入队列
    AudioStreamBasicDescription _recordFormat;//音频输入数据format
    AudioQueueBufferRef _audioBuffers[kNumberAudioQueueBuffers];//音频输入缓冲区
    NSMutableArray *_pcmDataArray;
}

@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) int sampleRate;
@property (atomic, assign) double bufferDurationSeconds;
@property (atomic, assign) Opus *opus;
@end

@implementation AudioQueueRecord
- (id)init:(Opus *) opusClass withSampleRate:(int)sampleRate
{
    self = [super init];
    if (self)
    {
        self.opus=opusClass;
        _pcmDataArray=[[NSMutableArray alloc] init];
        self.pcmDatas=_pcmDataArray;
        self.sampleRate = sampleRate;
        self.bufferDurationSeconds = kDefaultBufferDurationSeconds;
        [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:self.sampleRate];//设置录音的format数据
    }
    return self;
}

- (void)startRecording
{
    NSError *error = nil;
    BOOL ret = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!ret) {
        NSLog(@"设置声音环境失败");
        return;
    }
    
    //启用Audio Session
    ret = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (!ret)
    {
        NSLog(@"启动失败");
        return;
    }
    _recordFormat.mSampleRate = self.sampleRate;
    AudioQueueNewInput(&_recordFormat, inputBufferHandler2, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);//初始化音频输入队列
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

- (void)stopRecording
{
    if (self.isRecording)
    {
        self.isRecording = NO;
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

// 设置录音格式
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(NSInteger)sampeleRate
{
    memset(&_recordFormat, 0, sizeof(_recordFormat));//重置
    _recordFormat.mSampleRate = sampeleRate;//设置采样率
    _recordFormat.mChannelsPerFrame = 1;//设置通道数
    _recordFormat.mFormatID = inFormatID;//设置format
    if (inFormatID == kAudioFormatLinearPCM)
    {
        _recordFormat.mFramesPerPacket = 1;
        _recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        _recordFormat.mBitsPerChannel = 16;//每个通道里，一帧采集的bit数目
        _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
        _recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame * _recordFormat.mFramesPerPacket;//每个数据包的bytes总数，每桢的bytes数*每个数据包的桢数
    }
}

void inputBufferHandler2(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
        AudioQueueRecord *recorder = (__bridge AudioQueueRecord*)inUserData;
        if (inNumPackets > 0)
        {
            NSMutableData *pcmData = [[NSMutableData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
            if (pcmData && pcmData.length>0)
            {
                if (pcmData.length<640)
                {//处理长度小于缓存区最小大小的情况,此处是补00
                    Byte byte[] = {0x00};
                    NSData * zeroData = [[NSData alloc] initWithBytes:byte length:1];
                    for (NSUInteger i = pcmData.length; i < 640; i++) {
                        [pcmData appendData:zeroData];
                    }
                }
                
                NSData *encoderOut = [recorder.opus encode:pcmData];
                [recorder.pcmDatas addObject:encoderOut];
                NSLog(@"pcmData: %1d encLen:%2d", (int)pcmData.length, (int)encoderOut.length);
            }
        }
    
        if (recorder.isRecording)
        {
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        }
}
@end
