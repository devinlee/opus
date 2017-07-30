//
//  AudioQueuePlay.h
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioQueuePlay : NSObject
// 播放并顺带附上数据
- (void)playWithData: (NSMutableData *)data;

// reset
- (void)resetPlay;
@end
