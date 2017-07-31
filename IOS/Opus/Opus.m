#import "include/opus/opus.h"
#import "Opus.h"

@implementation Opus
{
    int FRAME_SIZE;
    OpusEncoder *encoder;
    OpusDecoder *decoder;
}

- (id)init:(int)frameSampleRate withBitrateBps:(int)bitrateBps withComplexity:(int)complexity withFrameSize:(int)frameSize
{
    int error;
    FRAME_SIZE=frameSize;
    int channels = 1;
    
    encoder = opus_encoder_create(frameSampleRate, channels, OPUS_APPLICATION_VOIP, &error);
    decoder = opus_decoder_create(frameSampleRate, channels, &error);
    
    opus_encoder_ctl(encoder, OPUS_SET_BITRATE(bitrateBps));
    opus_encoder_ctl(encoder, OPUS_SET_BANDWIDTH(OPUS_AUTO));
    opus_encoder_ctl(encoder, OPUS_SET_VBR(0));
    opus_encoder_ctl(encoder, OPUS_SET_VBR_CONSTRAINT(1));
    opus_encoder_ctl(encoder, OPUS_SET_COMPLEXITY(complexity));
    opus_encoder_ctl(encoder, OPUS_SET_PACKET_LOSS_PERC(0));
    opus_encoder_ctl(encoder, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));
    return self;
}

- (NSData *)opusEncode:(short *)pcmBuffer length:(int)lengthOfShorts
{
    unsigned char encodeData[lengthOfShorts];
    int encodeLen = opus_encode(encoder, pcmBuffer, FRAME_SIZE, encodeData, 2500);
    NSMutableData *decodedData = [NSMutableData data];
    [decodedData appendBytes:encodeData length:encodeLen];
    return decodedData;
}

- (int)opusDecode:(unsigned char *)encodedBytes length:(int)lengthOfBytes output:(short*)decodedBuffer
{
    int decodeLen = opus_decode(decoder,encodedBytes,lengthOfBytes,decodedBuffer,FRAME_SIZE,0);
    return decodeLen;
}

- (NSData*)encode:(NSData*)pcmData
{
    return  [self opusEncode:(short *)pcmData.bytes length:(int)pcmData.length/sizeof(short)];
}

- (NSData*)decode:(NSData*)encodedPcmData
{
    short decodedBuffer[FRAME_SIZE];
    int decodedLen = sizeof(short) * [self opusDecode:(Byte *)encodedPcmData.bytes length:(int)encodedPcmData.length output:decodedBuffer];
    NSData* pcmData = [NSData dataWithBytes:(Byte *)decodedBuffer length:decodedLen];
    return pcmData;
}

- (void)destroy
{
    if(encoder!=NULL)
    {
        opus_encoder_destroy(encoder);
    }
    if(decoder!=NULL)
    {
        opus_decoder_destroy(decoder);
    }
}
@end
