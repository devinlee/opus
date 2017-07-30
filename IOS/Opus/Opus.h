//
//  Opus.h
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Opus : NSObject
-(id)init:(int)frameSampleRate withBitrateBps:(int)bitrateBps withComplexity:(int)complexity withFrameSize:(int)frameSize;
-(int)encode:(NSMutableData *)srcIn withEncoderOut:(NSMutableData *) encoderOut;
-(int)decode:(NSMutableData *)encoderIn withDecoderOut:(NSMutableData *)decoderOut withEncoderInSize:(int)encoderInSize;
-(void)destroy;
@end
