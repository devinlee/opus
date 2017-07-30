//
//  Test.h
//  Opus
//
//  Created by Devin Lee on 2017/7/30.
//  Copyright © 2017年 devin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestRecord : NSObject
{
//    NSString *_name;
//    NSInteger _age;
}

//-(id)init:(NSString *)name withAge:(NSInteger)age;

-(id)init;
-(void)startRecord;
-(void)stopRecord;

@end
