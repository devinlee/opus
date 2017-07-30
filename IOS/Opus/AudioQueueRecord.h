#import <Foundation/Foundation.h>

@interface AudioQueueRecord : NSObject
-(id)init;
-(void)startRecording;
-(void)stopRecording;
-(NSMutableArray *)getData;
@end
