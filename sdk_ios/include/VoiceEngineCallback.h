//
//  VoiceEngineCallback.h
//  VoiceTest
//
//  Created by kilo on 16/7/12.
//  Copyright © 2016年 kilo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YouMeConstDefine.h"

@interface MemberChangeOC: NSObject
//用户ID
@property (nonatomic, retain) NSString* userID ;
//true,表示加入，false表示离开
@property (nonatomic, assign) bool  isJoin;
@end

@protocol VoiceEngineCallback <NSObject>
- (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode roomid:(NSString *)roomid param:(NSString *)param;

//RestAPI回调
- (void)onRequestRestAPI: (int)requestID iErrorCode:(YouMeErrorCode_t) iErrorCode  query:(NSString*) strQuery  result:(NSString*) strResult ;

//获取频道用户列表回调
- (void)onMemberChange:(NSString*) channelID changeList:(NSArray*) changeList isUpdate:(bool) isUpdate ;

//房间内广播消息回调
- (void)onBroadcast:(YouMeBroadcast_t)bc strChannelID:(NSString*)channelID strParam1:(NSString*)param1 strParam2:(NSString*)param2 strContent:(NSString*)content;

- (void)frameRender:(int) renderId  nWidth:(int) nWidth  nHeight:(int) nHeight  nRotationDegree:(int) nRotationDegree nBufSize:(int) nBufSize buf:(const void *) buf ;

- (void) onAVStatistic:(YouMeAVStatisticType_t)type  userID:(NSString*)userID  value:(int) value ;

@end
