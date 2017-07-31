#import "AudioQueuePlay.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Opus.h"

#define QUEUE_BUFFER_SIZE 3      //队列缓冲个数
#define kDefaultBufferDurationSeconds 0.02   //调整这个值使得录音的缓冲区大小

@interface AudioQueuePlay() {
    AudioQueueRef audioQueue;                                 //音频播放队列
    AudioStreamBasicDescription _audioDescription;
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE]; //音频缓存
    BOOL audioQueueBufferUsed[QUEUE_BUFFER_SIZE];             //判断音频缓存是否在使用
    NSLock *sysnLock;
    OSStatus osState;
}
@property (atomic, assign) Opus *opus;
@property (atomic, assign) double bufferDurationSeconds;
@end

@implementation AudioQueuePlay

- (id)init:(Opus *) opusClass withSampleRate:(int)sampleRate
{
    self = [super init];
    if (self) {
        sysnLock = [[NSLock alloc]init];
        self.opus=opusClass;
        self.bufferDurationSeconds = kDefaultBufferDurationSeconds;
        
        // 播放PCM使用
        if (_audioDescription.mSampleRate <= 0)
        {//设置音频参数
            _audioDescription.mSampleRate = sampleRate;//采样率
            _audioDescription.mFormatID = kAudioFormatLinearPCM;
            _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;//保存音频数据的方式的说明，如可以根据大端字节序或小端字节序，浮点数或整数以及不同体位去保存数据
            _audioDescription.mChannelsPerFrame = 1;//1单声道 2双声道
            _audioDescription.mFramesPerPacket = 1;//每一个packet一侦数据,每个数据包下的桢数，即每个数据包里面有多少桢
            _audioDescription.mBitsPerChannel = 16;//每个采样点16bit量化 语音每采样点占用位数
            _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
            _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;//每个数据包的bytes总数，每桢的bytes数*每个数据包的桢数
        }
        AudioQueueNewOutput(&_audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, 0, 0, &audioQueue);// 使用player的内部线程播放 新建输出
        AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);// 设置音量
        
        // 初始化需要的缓冲区
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++)
        {
            audioQueueBufferUsed[i] = false;
            //计算估算的缓存区大小
            int frames = (int)ceil(self.bufferDurationSeconds * _audioDescription.mSampleRate);
            int bufferByteSize = frames * _audioDescription.mBytesPerFrame;
            osState = AudioQueueAllocateBuffer(audioQueue, bufferByteSize, &audioQueueBuffers[i]);
            printf("第 %d 个AudioQueueAllocateBuffer 初始化结果 %d (0表示成功)，缓冲区大小 %d", i + 1, osState, bufferByteSize);
        }
        
        osState = AudioQueueStart(audioQueue, NULL);
        if (osState != noErr) {
            printf("AudioQueueStart Error");
        }
    }
    return self;
}

- (void)resetPlay {
    if (audioQueue != nil)
    {
        AudioQueueReset(audioQueue);
    }
}

- (void)playWithData:(NSData *)data
{
    [sysnLock lock];
    NSLog(@"解码前数据长度：%d", (int)data.length);
    NSData *desPcm=[self.opus decode:data];
    int desLen = (int)desPcm.length;
    NSLog(@"解码前数据长度：%d", desLen);
    
    int i = 0;
    while (true) {
        if (!audioQueueBufferUsed[i]) {
            audioQueueBufferUsed[i] = true;
            break;
        }else {
            i++;
            if (i >= QUEUE_BUFFER_SIZE) {
                i = 0;
            }
        }
    }
    
    audioQueueBuffers[i] -> mAudioDataByteSize =  (unsigned int)desLen;
    memcpy(audioQueueBuffers[i] -> mAudioData, desPcm.bytes, desLen);//把bytes的头地址开始的len字节给mAudioData
//  free(desPcm.bytes);
    AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffers[i], 0, NULL);
    [sysnLock unlock];
}

// ************************** 回调 **********************************

// 回调回来把buffer状态设为未使用
static void AudioPlayerAQInputCallback(void* inUserData,AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
    
    AudioQueuePlay* player = (__bridge AudioQueuePlay*)inUserData;
    
    [player resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        // 将这个buffer设为未使用
        if (audioQueueBufferRef == audioQueueBuffers[i]) {
            audioQueueBufferUsed[i] = false;
        }
    }
}

// ************************** 内存回收 **********************************

- (void)dealloc {
    
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue,true);
    }
    audioQueue = nil;
    sysnLock = nil;
}

@end
