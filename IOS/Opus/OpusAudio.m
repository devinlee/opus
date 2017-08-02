#import "OpusAudio.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Opus.h"

#define AUDIO_QUEUE_BUFFERS_NUMBER 3  //定义3个缓冲区
#define DEFAULT_BUFFER_DURATION_SECONDS 0.04   //调整这个值使得录音的缓冲区大小
#define OPUS_FRAME_SIZE 320
#define OPUS_COMPLEXITY 4
#define OPUS_FRAME_SAMPLE_RATE 8000
#define OPUS_BITRATE_BPS 8000
#define FRAME_ENCODE_SIZE 40

@interface OpusAudio()
{
    AudioQueueRef _recordAudioQueue;//录音音频输入队列
    AudioQueueRef _playAudioQueue;//播放音频输入队列
    AudioStreamBasicDescription _audioDescription;//音频输入数据format
    AudioQueueBufferRef _recordAudioQueueBuffers[AUDIO_QUEUE_BUFFERS_NUMBER];//音频输入缓冲区
    AudioQueueBufferRef _playAudioQueueBuffers[AUDIO_QUEUE_BUFFERS_NUMBER]; //音频缓存
    Opus *_opusClass;
    NSMutableArray *_encodeArray;
    NSMutableArray *_decodeArray;
    NSLock *_sysnLock;
    OSStatus _osState;
    BOOL _playAudioQueueBufferUsed[AUDIO_QUEUE_BUFFERS_NUMBER];//判断音频缓存是否在使用
}

@property (nonatomic, assign) BOOL isRecording;
@property (atomic, assign) Opus *opus;
@property (atomic, assign) NSMutableArray *encodes;
@property (atomic, assign) NSMutableArray *decodes;

@end

@implementation OpusAudio
- (id)init
{
    self = [super init];
    if(self)
    {
        _sysnLock = [[NSLock alloc]init];
        _encodeArray=[[NSMutableArray alloc] init];
        self.encodes=_encodeArray;
        _decodeArray=[[NSMutableArray alloc] init];
        self.decodes=_decodeArray;
        [self setupAudioFormat];//设置录音的format数据
        _opusClass=[[Opus alloc] init:OPUS_FRAME_SAMPLE_RATE withBitrateBps:OPUS_BITRATE_BPS withComplexity:OPUS_COMPLEXITY withFrameSize:OPUS_FRAME_SIZE];
        self.opus=_opusClass;
    }
    return self;
}

- (void)setupAudioFormat
{
    memset(&_audioDescription, 0, sizeof(_audioDescription));//重置
    _audioDescription.mSampleRate = OPUS_FRAME_SAMPLE_RATE;//设置采样率
    _audioDescription.mChannelsPerFrame = 1;//设置通道数
    _audioDescription.mFormatID = kAudioFormatLinearPCM;//设置format
    _audioDescription.mFramesPerPacket = 1;
    _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    _audioDescription.mBitsPerChannel = 16;//每个通道里，一帧采集的bit数目
    _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
    _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;//每个数据包的bytes总数，每桢的bytes数*每个数据包的桢数
}

- (void)startAudioRecord
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
    
    [_encodeArray removeAllObjects];
    [_decodeArray removeAllObjects];
    AudioQueueNewInput(&_audioDescription, recordAudioQueueInputCallback, (__bridge void *)(self), NULL, NULL, 0, &_recordAudioQueue);//初始化音频输入队列
    //计算估算的缓存区大小
    int frames = (int)ceil(DEFAULT_BUFFER_DURATION_SECONDS * _audioDescription.mSampleRate);
    int bufferByteSize = frames * _audioDescription.mBytesPerFrame;
    NSLog(@"缓冲区大小:%d",bufferByteSize);
    
    //创建缓冲器
    for (int i = 0; i < AUDIO_QUEUE_BUFFERS_NUMBER; ++i)
    {
        AudioQueueAllocateBuffer(_recordAudioQueue, bufferByteSize, &_recordAudioQueueBuffers[i]);
        AudioQueueEnqueueBuffer(_recordAudioQueue, _recordAudioQueueBuffers[i], 0, NULL);
    }
    
    // 开始录音
    AudioQueueStart(_recordAudioQueue, NULL);
    self.isRecording = YES;
}

void recordAudioQueueInputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    OpusAudio *opusAudio = (__bridge OpusAudio*)inUserData;
    if (inNumPackets > 0)
    {
        NSMutableData *pcmData = [[NSMutableData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if (pcmData && pcmData.length>0)
        {
            NSLog(@"pcmData 1: %1d", (int)pcmData.length);
            if (pcmData.length<OPUS_FRAME_SIZE*2)
            {//处理长度小于缓存区最小大小的情况,此处是补00
                Byte byte[] = {0x00};
                NSData * zeroData = [[NSData alloc] initWithBytes:byte length:1];
                for (NSUInteger i = pcmData.length; i < OPUS_FRAME_SIZE*2; i++) {
                    [pcmData appendData:zeroData];
                }
            }
            
            NSData *encoderOut = [opusAudio.opus encode:pcmData];
            [opusAudio.encodes addObject:encoderOut];
            NSLog(@"pcmData 2: %1d encLen:%2d", (int)pcmData.length, (int)encoderOut.length);
        }
    }
    
    if (opusAudio.isRecording)
    {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)stopAudioRecord
{
    if (self.isRecording)
    {
        self.isRecording = NO;
        AudioQueueStop(_recordAudioQueue, true);
        AudioQueueDispose(_recordAudioQueue, true);
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    }
}

- (int) getDecodeLength
{
    if(_encodeArray!=nil && _encodeArray!=NULL && _encodeArray.count>0)
    {
        return (int)_encodeArray.count*FRAME_ENCODE_SIZE;
    }
    return 0;
}

- (void)getAudioBuffer:(Byte*) outEncodeBytes
{
    if(_encodeArray!=nil && _encodeArray!=NULL && _encodeArray.count>0)
    {
        NSLog(@"OpusAudio getAudioBuffer 2 encodes: %1d", (int)_encodeArray.count);
//        NSData *encodeBytes = _encodeArray[0];
//        int itemLen=(int)encodeBytes.length;
        int totalByteLen=(int)_encodeArray.count*FRAME_ENCODE_SIZE;
//        Byte *allEncodeBytes = (Byte*)malloc(totalByteLen);
        for(NSInteger i=0;i<_encodeArray.count;i++)
        {
            NSData *encodeNSData = _encodeArray[i];
            memcpy(outEncodeBytes + (i*FRAME_ENCODE_SIZE)*sizeof(Byte),encodeNSData.bytes, FRAME_ENCODE_SIZE*sizeof(Byte));
        }
        self.decodeLength=totalByteLen;
//        return allEncodeBytes;
    }
//    return NULL;
}

- (void)playAudio: (Byte *)audioBuffer withLength:(int)length
{
    if(audioBuffer==NULL || audioBuffer==nil)
    {
        return;
    }
    AudioQueueNewOutput(&_audioDescription, playAudioQueueOutputCallback, (__bridge void * _Nullable)(self), nil, 0, 0, &_playAudioQueue);// 使用player的内部线程播放 新建输出
    AudioQueueSetParameter(_playAudioQueue, kAudioQueueParam_Volume, 1.0);// 设置音量
    
    // 初始化需要的缓冲区
    for (int i = 0; i < AUDIO_QUEUE_BUFFERS_NUMBER; i++)
    {
        _playAudioQueueBufferUsed[i] = false;
        //计算估算的缓存区大小
        int frames = (int)ceil(DEFAULT_BUFFER_DURATION_SECONDS * _audioDescription.mSampleRate);
        int bufferByteSize = frames * _audioDescription.mBytesPerFrame;
        _osState = AudioQueueAllocateBuffer(_playAudioQueue, bufferByteSize, &_playAudioQueueBuffers[i]);
    }
    
    _osState = AudioQueueStart(_playAudioQueue, NULL);
    if (_osState != noErr) {
        NSLog(@"play AudioQueueStart Error");
    }
    
    [_sysnLock lock];
    [_decodeArray removeAllObjects];
    int maxIndex = length / FRAME_ENCODE_SIZE;
    if(length % FRAME_ENCODE_SIZE>0)
    {
        maxIndex+=1;
    }

    int currIndex=0;
    while(true)
    {
        Byte *currBytes = (Byte*)malloc(FRAME_ENCODE_SIZE);
        memcpy(currBytes, audioBuffer+(currIndex*FRAME_ENCODE_SIZE)*sizeof(Byte), FRAME_ENCODE_SIZE*sizeof(Byte));
        NSData *currEncode=[[NSData alloc] initWithBytes:currBytes length:FRAME_ENCODE_SIZE];
        currIndex++;
        
        NSData *desPcm=[self.opus decode:currEncode];
        int decodeLen = (int)desPcm.length;
        NSLog(@"解码前数据长度：%d", decodeLen);
        free(currBytes);
        currEncode=nil;
        
        int i = 0;
        while (true)
        {
            if (!_playAudioQueueBufferUsed[i])
            {
                _playAudioQueueBufferUsed[i] = true;
                break;
            }
            else
            {
                i++;
                if (i >= AUDIO_QUEUE_BUFFERS_NUMBER)
                {
                    i = 0;
                }
            }
        }
        
        _playAudioQueueBuffers[i] -> mAudioDataByteSize =  (unsigned int)decodeLen;
        memcpy(_playAudioQueueBuffers[i] -> mAudioData, desPcm.bytes, decodeLen);//把bytes的头地址开始的len字节给mAudioData
        AudioQueueEnqueueBuffer(_playAudioQueue, _playAudioQueueBuffers[i], 0, NULL);
        if(currIndex>=maxIndex)
        {
            break;
        }
    }
//    free(audioBuffer);
    audioBuffer=nil;
    [_sysnLock unlock];
}

void playAudioQueueOutputCallback(void* inUserData,AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
    
    OpusAudio* player = (__bridge OpusAudio*)inUserData;
    [player resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    
    for (int i = 0; i < AUDIO_QUEUE_BUFFERS_NUMBER; i++)
    {
        // 将这个buffer设为未使用
        if (audioQueueBufferRef == _playAudioQueueBuffers[i])
        {
            _playAudioQueueBufferUsed[i] = false;
        }
    }
}

- (void)resetPlay
{
    if (_playAudioQueue != nil)
    {
        AudioQueueReset(_playAudioQueue);
    }
}

- (void)destroy
{
    if (_playAudioQueue != nil)
    {
        AudioQueueStop(_playAudioQueue,true);
        _playAudioQueue = nil;
    }
    _sysnLock = nil;
    if(_opusClass!=nil)
    {
        [_opusClass destroy];
        _opusClass=nil;
    }
}
@end
