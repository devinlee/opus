//
//  TestPlayer2.h
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestPlayer2 : NSObject
// 播放的数据流数据
- (void)playWithData:(NSData *)data;
// 声音播放出现问题的时候可以重置一下
- (void)resetPlay;
// 停止播放
- (void)stop;
@end
