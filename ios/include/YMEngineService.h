//
//  NSObject+YMTESt.h
//  youme_voice_engine
//
//  Created by mac on 2017/8/15.
//  Copyright © 2017年 Youme. All rights reserved.
//
#import "YMFrameCallback.h"
#import <Foundation/Foundation.h>

@interface YMEngineService : NSObject
@property (nonatomic, retain) id<YMFrameCallback> delegate;

//公共接口
+ (YMEngineService *)getInstance;
- (void)setDelegate:(id<YMFrameCallback>)delegate;
- (BOOL)inputVideoFrame:(void *)data Len:(int)len Width:(int)width Height:(int)height Fmt:(int)fmt Rotation:(int)rotation Mirror:(int)mirror Timestamp:(uint64_t)timestamp;
- (BOOL)inputAudioFrame:(void *)data Len:(int)len Timestamp:(uint64_t)timestamp;

/*
 * 设置合流后的总体尺寸
 * @param width
 * @param height
 */
- (void)setMixVideoWidth:(int)width Height:(int)height;
/**
 * @param userId
 * @param x       x
 * @param y       y
 * @param z       z              
 * @param width                  
 * @param height                  
 */
- (void)addMixOverlayVideoUserId:(NSString*)userId PosX:(int)x PosY:(int)y PosZ:(int)z Width:(int)width Height:(int)height;

/**
 * remove the specified user's video from the mixing
 * @param userId
 */
- (void)removeMixOverlayVideoUserId:(NSString*)userId;
@end
