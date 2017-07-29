#include <jni.h>
#include <string.h>
#include <android/log.h>

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include <time.h>
#if (!defined WIN32 && !defined _WIN32) || defined(__MINGW32__)
#include <unistd.h>
#else
#include <process.h>
#define getpid _getpid
#endif
#include "opus_multistream.h"
#include "opus.h"
#include "../src/opus_private.h"

int opus_num;
int pcm_num;
OpusEncoder *enc=NULL;
OpusDecoder *dec=NULL;
jint FRAME_SIZE;
jint COMPRESSION_RATE;

extern "C"
JNIEXPORT jint JNICALL Java_devin_opus_Opus_test(JNIEnv *env, jobject thiz)
{
    return 1;
}

extern "C"
JNIEXPORT jboolean JNICALL Java_devin_opus_Opus_init(JNIEnv *env, jobject thiz, jint frame_sample_rate, jint bitrate_bps, jint complexity, jint frame_size)
{
    int error;
    FRAME_SIZE=frame_size;
    COMPRESSION_RATE=FRAME_SIZE/complexity;
    int channels=1;
    int application=OPUS_APPLICATION_AUDIO;

    int bandwidth = OPUS_AUTO;
    int use_vbr = 0;
    int cvbr=1;
    int packet_loss_perc=0;

    enc = opus_encoder_create(frame_sample_rate, channels, application, &error);
    dec = opus_decoder_create(frame_sample_rate, channels, &error);

    opus_encoder_ctl(enc, OPUS_SET_BITRATE((opus_int32)bitrate_bps));
    opus_encoder_ctl(enc, OPUS_SET_BANDWIDTH(bandwidth));
    opus_encoder_ctl(enc, OPUS_SET_VBR(use_vbr));
    opus_encoder_ctl(enc, OPUS_SET_VBR_CONSTRAINT(cvbr));
    opus_encoder_ctl(enc, OPUS_SET_COMPLEXITY(complexity));
    opus_encoder_ctl(enc, OPUS_SET_PACKET_LOSS_PERC(packet_loss_perc));
    return true;
}

extern "C"
JNIEXPORT jint JNICALL Java_devin_opus_Opus_encode(JNIEnv *env, jobject thiz,jshortArray src_in,jbyteArray encoder_out)
{
    opus_int32 max_data_bytes=2500;
    const opus_int16* pcm_data_encoder=env->GetShortArrayElements(src_in, 0);
    jbyte* opus_data_encoder=env->GetByteArrayElements(encoder_out, 0);
    opus_num=opus_encode(enc,pcm_data_encoder,FRAME_SIZE,(unsigned char*)opus_data_encoder,max_data_bytes);
    env->ReleaseShortArrayElements(src_in, (jshort*)pcm_data_encoder, 0);
    env->ReleaseByteArrayElements(encoder_out, opus_data_encoder, 0);
    if(env->ExceptionCheck())
    {
        return - 1;
    }
    return opus_num;
}

extern "C"
JNIEXPORT jint JNICALL Java_devin_opus_Opus_decode(JNIEnv *env, jobject thiz,jbyteArray encoder_in,jshortArray decoder_out, jint encoder_in_size)
{
    opus_int16* pcm_data_decoder=env->GetShortArrayElements(decoder_out, 0);
    jbyte* opus_data_decoder=env->GetByteArrayElements(encoder_in, 0);
    pcm_num=opus_decode(dec,(unsigned char*)opus_data_decoder,encoder_in_size,pcm_data_decoder,FRAME_SIZE,0);

    env->ReleaseShortArrayElements(decoder_out, pcm_data_decoder, 0);
    env->ReleaseByteArrayElements(encoder_in, opus_data_decoder, 0);
    if(env->ExceptionCheck())
    {
        return - 1;
    }
    return pcm_num;
}

extern "C"
JNIEXPORT jboolean JNICALL Java_devin_opus_Opus_destroy(JNIEnv *env, jobject thiz)
{
    opus_encoder_destroy(enc);
    opus_decoder_destroy(dec);
    return true;
}