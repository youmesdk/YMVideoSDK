//
//  YMFrameCallback.h
//  youme_voice_engine
//
//  Created by mac on 2017/8/15.
//  Copyright © 2017年 Youme. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMFrameCallback <NSObject>
//audio frame callback
- (void)onAudioFrameCallback: (NSString*)userId data:(void*) data len:(int)len timestamp:(uint64_t)timestamp;
- (void)onAudioFrameMixedCallback: (void*)data len:(int)len timestamp:(uint64_t)timestamp;
- (void)onVideoFrameCallback: (NSString*)userId data:(void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp;
- (void)onVideoFrameMixedCallback: (void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp;

@end
