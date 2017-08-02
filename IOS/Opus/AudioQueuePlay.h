//
//  AudioQueuePlay.h
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Opus.h"

@interface AudioQueuePlay : NSObject
- (id)init:(Opus *) opusClass withSampleRate:(int)sampleRate;

// 播放并顺带附上数据
- (void)playWithData: (NSData *)data;

// reset
- (void)resetPlay;
@end
