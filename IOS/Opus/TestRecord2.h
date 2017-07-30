//
//  TestRecord2.h
//  Opus
//
//  Created by Devin Lee on 2017/7/31.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestRecord2 : NSObject
{
}
-(id)init;
-(void)startRecord;
-(void)stopRecord;
-(NSMutableArray *)getData;
@end
