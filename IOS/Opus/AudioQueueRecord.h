#import <Foundation/Foundation.h>
#import "Opus.h"

@interface AudioQueueRecord : NSObject
@property (atomic, assign) NSMutableArray *pcmDatas;
- (id)init:(Opus *) opusClass withSampleRate:(int)sampleRate;
- (void)startRecording;
- (void)stopRecording;
@end
