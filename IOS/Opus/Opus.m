//
//  Opus.m
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//
#import "include/opus/opus.h"
#import "Opus.h"

@interface Opus(){
    int FRAME_SIZE;
    int COMPRESSION_RATE;
    OpusEncoder *encoder;
    OpusDecoder *decoder;
    int opusNum;
    int pcmNum;
}
@end

@implementation Opus
-(id)init:(int)frameSampleRate withBitrateBps:(int)bitrateBps withComplexity:(int)complexity withFrameSize:(int)frameSize
{
    self=[super init];
    if (self) {
        int error;
        FRAME_SIZE=frameSize;
        COMPRESSION_RATE=FRAME_SIZE/complexity;
        int channels=1;
        int application=OPUS_APPLICATION_AUDIO;
        
        int bandwidth = OPUS_AUTO;
        int use_vbr = 0;
        int cvbr=1;
        int packet_loss_perc=0;
        
        encoder = opus_encoder_create(frameSampleRate, channels, application, &error);
        decoder = opus_decoder_create(frameSampleRate, channels, &error);
        
        opus_encoder_ctl(encoder, OPUS_SET_BITRATE((opus_int32)bitrateBps));
        opus_encoder_ctl(encoder, OPUS_SET_BANDWIDTH(bandwidth));
        opus_encoder_ctl(encoder, OPUS_SET_VBR(use_vbr));
        opus_encoder_ctl(encoder, OPUS_SET_VBR_CONSTRAINT(cvbr));
        opus_encoder_ctl(encoder, OPUS_SET_COMPLEXITY(complexity));
        opus_encoder_ctl(encoder, OPUS_SET_PACKET_LOSS_PERC(packet_loss_perc));
    }
    return self;
}

-(int)encode:(NSMutableData *)srcIn withEncoderOut:(NSMutableData *) encoderOut
{
//    opus_int32 max_data_bytes=2500;
//    const opus_int16* pcm_data_encoder=env->GetShortArrayElements(src_in, 0);
//    jbyte* opus_data_encoder=env->GetByteArrayElements(encoder_out, 0);
//    opus_num=opus_encode(enc,pcm_data_encoder,FRAME_SIZE,(unsigned char*)opus_data_encoder,max_data_bytes);
//    env->ReleaseShortArrayElements(src_in, (jshort*)pcm_data_encoder, 0);
//    env->ReleaseByteArrayElements(encoder_out, opus_data_encoder, 0);
//    if(env->ExceptionCheck())
//    {
//        return - 1;
//    }
//    return opusNum;
    
    
//    int nbBytes;
    unsigned char decodedData[FRAME_SIZE];
//    NSMutableData *decodedData = [NSMutableData dataWithCapacity:FRAME_SIZE];
    
//    short input_frame[FRAME_SIZE];
//    memset((Byte*)input_frame,0,FRAME_SIZE*2);
    
//    memcpy(input_frame, srcIn.bytes, FRAME_SIZE * sizeof(short));
    
    opusNum = opus_encode(encoder, srcIn.bytes, FRAME_SIZE, decodedData, FRAME_SIZE);
    [encoderOut appendBytes:decodedData length:opusNum];
    
    return opusNum;
}

-(int)decode:(NSMutableData *)encoderIn withDecoderOut:(NSMutableData *)decoderOut withEncoderInSize:(int)encoderInSize
{
//    opus_int16* pcm_data_decoder=GetShortArrayElements(decoderOut, 0);
//    unsigned char* opus_data_decoder=GetByteArrayElements(encoderIn, 0);
//    pcmNum=opus_decode(dec,(unsigned char*)opus_data_decoder,encoderInSize,pcm_data_decoder,FRAME_SIZE,0);
//    
//    env->ReleaseShortArrayElements(decoderOut, pcm_data_decoder, 0);
//    env->ReleaseByteArrayElements(encoderIn, opus_data_decoder, 0);
//    if(env->ExceptionCheck())
//    {
//        return - 1;
//    }
//    return pcmNum;
    
    
//    if ( ! codecOpenedTimes)
//        return 0;
    

    unsigned char cbits[encoderInSize];
    memcpy(cbits, encoderIn.bytes, encoderInSize);
    opus_int16 pcm[FRAME_SIZE];
    
    opusNum = opus_decode(decoder, cbits, encoderInSize, pcm, FRAME_SIZE, 0);
    [decoderOut appendBytes:pcm length:opusNum];
    
    return opusNum;
}

-(void)destroy
{
    opus_encoder_destroy(encoder);
    opus_decoder_destroy(decoder);
}
@end
