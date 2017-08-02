#import <Foundation/Foundation.h>

@interface OpusAudio : NSObject
@property (atomic, assign) int decodeLength;
- (id)init;
- (void)startAudioRecord;
- (void)stopAudioRecord;
- (int) getDecodeLength;
- (void)getAudioBuffer:(Byte*) outEncodeBytes;
- (void)playAudio: (Byte *)audioBuffer withLength:(int)length;
- (void)resetPlay;
- (void)destroy;
@end
