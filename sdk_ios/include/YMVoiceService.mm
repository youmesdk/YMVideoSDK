//
//  YMVoiceService.m
//  YmTalkTestRef
//
//  Created by pinky on 2017/5/27.
//  Copyright © 2017年 Youme. All rights reserved.
//


#import "YMVoiceService.h"
#import "IYouMeVoiceEngine.h"
#import "YMEngineService.h"

@implementation MemberChangeOC


@end

class YouMeVoiceImp : public IYouMeEventCallback, public IRestApiCallback,public IYouMeMemberChangeCallback, public IYouMePcmCallback, public IYouMeChannelMsgCallback, public IYouMeVideoCallback , public IYouMeAVStatisticCallback
{
public:
    virtual void onEvent(const YouMeEvent event, const YouMeErrorCode error, const char * room, const char * param) override ;
    virtual void onPcmData(int channelNum, int samplingRateHz, int bytesPerSample, void* data, int dataSizeInByte)override;
    
    virtual  void onRequestRestAPI( int requestID, const YouMeErrorCode &iErrorCode, const  char* strQuery, const  char*  strResult )override;
    
    virtual void onMemberChange( const  char* channel, std::list<MemberChange>& listMemberChange , bool bUpdate)override;
	
	virtual void onBroadcast(const YouMeBroadcast bc, const  char* channel, const  char* param1, const char* param2, const  char* strContent)override;
    virtual void frameRender(int renderId, int nWidth, int nHeight, int nRotationDegree, int nBufSize, const void * buf) override;
    
    virtual void onAVStatistic( YouMeAVStatisticType type,  const char* userID,  int value ) override  ;

};

void YouMeVoiceImp::onEvent(const YouMeEvent event, const YouMeErrorCode error, const char * room, const char * param)
{
    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }
    if(event == YOUME_EVENT_JOIN_OK){
        IYouMeVoiceEngine::getInstance()->setVideoCallback(this);
    }
    else if(event == YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP)
    {
        //合流窗口变黑，七牛需求
        [[YMEngineService getInstance] hangupMixOverlayVideo:[NSString stringWithCString:param encoding:NSUTF8StringEncoding]];
    }
    [delegate onYouMeEvent:event errcode:error
                    roomid:[NSString stringWithCString:room encoding:NSUTF8StringEncoding]
                     param:[NSString stringWithCString:param encoding:NSUTF8StringEncoding]];

}

void YouMeVoiceImp::onPcmData(int channelNum, int samplingRateHz, int bytesPerSample, void* data, int dataSizeInByte)
{
    //todo:暂不暴露
}

void YouMeVoiceImp::onRequestRestAPI( int requestID, const YouMeErrorCode &iErrorCode, const  char* strQuery, const  char*  strResult )
{
    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }
    
    NSString* query = [NSString stringWithUTF8String:strQuery];
    NSString* result = [NSString stringWithUTF8String:strResult];

    [delegate onRequestRestAPI:requestID iErrorCode:iErrorCode  query:query  result:result ];
}

void YouMeVoiceImp::onMemberChange( const char* channel, std::list<MemberChange>& listMemberChange,bool bUpdate )
{

    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }

    
    NSString* channelID  = [NSString stringWithUTF8String: channel ];
    
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:10];
    std::list<MemberChange>::iterator it = listMemberChange.begin();
    for(; it != listMemberChange.end(); ++it ){
        MemberChangeOC* change = [MemberChangeOC new];
        change.userID =  [NSString stringWithUTF8String: it->userID ];
        change.isJoin = it->isJoin;
        
        [arr addObject: change ];
    }
    [delegate onMemberChange:channelID changeList:arr isUpdate:bUpdate];
}

void YouMeVoiceImp::onBroadcast(const YouMeBroadcast bc, const  char* channel, const  char* param1, const  char* param2, const  char* strContent)
{
    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }

    
    NSString* channelID  = [NSString stringWithUTF8String: channel ];
    NSString* p1  = [NSString stringWithUTF8String: param1 ];
    NSString* p2  = [NSString stringWithUTF8String: param2];
    NSString* content  = [NSString stringWithUTF8String: strContent ];
	
    [delegate onBroadcast:bc strChannelID:channelID strParam1:p1 strParam2:p2 strContent:content ];
}

void YouMeVoiceImp::frameRender(int renderId, int nWidth, int nHeight, int nRotationDegree, int nBufSize, const void * buf){
    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }
    [delegate frameRender:renderId nWidth:nWidth nHeight:nHeight  nRotationDegree:nRotationDegree  nBufSize:nBufSize buf:buf  ];
    
}

void YouMeVoiceImp::onAVStatistic( YouMeAVStatisticType type,  const char* userID,  int value )
{
    id<VoiceEngineCallback> delegate = [YMVoiceService getInstance].delegate;
    if( delegate  == nil ){
        return ;
    }
    NSString* strUserID = [NSString stringWithUTF8String:userID];

    
    [delegate onAVStatistic:type userID:strUserID value:value ];
}


static YMVoiceService *sharedInstance = nil;

@interface YMVoiceService(){
YouMeVoiceImp*  imp;
}
@end

extern void SetServerMode(SERVER_MODE serverMode);

@implementation YMVoiceService
//公共接口
+ (YMVoiceService *)getInstance
{
    @synchronized (self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [self alloc];
            
            sharedInstance->imp = new YouMeVoiceImp();
        }
    }
    
    return sharedInstance;
}

+ (void)destroy
{
    delete sharedInstance->imp;
}


- (void)setTestServer:(bool) isTest{
    if(isTest)
    {
        SetServerMode(SERVER_MODE_TEST);
    }else
    {
        SetServerMode(SERVER_MODE_FORMAL);
    }
}

-(int) createRender:(NSString*) userId{
    return IYouMeVoiceEngine::getInstance()->createRender([userId UTF8String]);
    
}
-(int) deleteRender:(int) renderId{
    return IYouMeVoiceEngine::getInstance()->deleteRender(renderId);
}

- (void)setExternalInputMode:(bool)bInputModeEnabled
{
    IYouMeVoiceEngine::getInstance()->setExternalInputMode(bInputModeEnabled);
}

- (int)initSDK:(id<VoiceEngineCallback>)delegate  appkey:(NSString*)appKey  appSecret:(NSString*)appSecret
        regionId:(YOUME_RTC_SERVER_REGION)regionId  serverRegionName:(NSString*) serverRegionName
{
    self.delegate = delegate;
    IYouMeVoiceEngine::getInstance()->setMemberChangeCallback( self->imp );
    IYouMeVoiceEngine::getInstance()->setRestApiCallback( self->imp );
    IYouMeVoiceEngine::getInstance()->setNotifyCallback( self->imp );
    IYouMeVoiceEngine::getInstance()->setAVStatisticCallback( self->imp );
	
    return IYouMeVoiceEngine::getInstance()->init( self->imp, [appKey UTF8String], [appSecret UTF8String],
                                                  ( YOUME_RTC_SERVER_REGION )regionId , [serverRegionName UTF8String]);
}


- (int)unInit
{
    return IYouMeVoiceEngine::getInstance ()->unInit ();
}

- (void) setPCMCallback:(bool)isOpen{
    if(isOpen){
        IYouMeVoiceEngine::getInstance()->setPcmCallback( self->imp );
    }else{
        IYouMeVoiceEngine::getInstance()->setPcmCallback( NULL );
    }
}

//开启测试服
//-(void)setTestServer:(bool)isTest
//{
//    return IYouMeVoiceEngine::getInstance()->setTestServer(isTest);
//}

-(void)setServerRegion:(YOUME_RTC_SERVER_REGION)serverRegionId regionName:(NSString*)regionName bAppend:(bool)bAppend
{
    return IYouMeVoiceEngine::getInstance()->setServerRegion( ( YOUME_RTC_SERVER_REGION )serverRegionId, [regionName UTF8String], bAppend);
}

//设置是否输出到扬声器，bOutputToSpeaker:true——扬声器，false——听筒，默认为true
- (YouMeErrorCode)setOutputToSpeaker:(bool)bOutputToSpeaker
{
    return IYouMeVoiceEngine::getInstance ()->setOutputToSpeaker(bOutputToSpeaker);
}

//设置扬声器静音,mute:true——静音，false——取消静音
-(void)setSpeakerMute:(bool)mute
{
    return IYouMeVoiceEngine::getInstance()->setSpeakerMute(mute);
}

//获取扬声器静音状态,return true——静音，false——没有静音
-(bool)getSpeakerMute
{
    return IYouMeVoiceEngine::getInstance()->getSpeakerMute();
}

//获取麦克风静音状态,return true——静音，false——没有静音
-(bool)getMicrophoneMute
{
    return IYouMeVoiceEngine::getInstance()->getMicrophoneMute();
}

//设置麦克风静音,mute:true——静音，false——取消静音
-(void)setMicrophoneMute:(bool)mute
{
    return IYouMeVoiceEngine::getInstance()->setMicrophoneMute(mute);
}


-(void) setOtherMicMute:(NSString *)strUserID  mute:(bool) mute
{
    IYouMeVoiceEngine::getInstance()->setOtherMicMute( [strUserID UTF8String], mute);
}
-(void) setOtherSpeakerMute: (NSString *)strUserID  mute:(bool) mute
{
    IYouMeVoiceEngine::getInstance()->setOtherSpeakerMute([strUserID UTF8String],mute);
}
-(void) setListenOtherVoice: (NSString *)strUserID  isOn:(bool) isOn
{
    IYouMeVoiceEngine::getInstance()->setListenOtherVoice([strUserID UTF8String],isOn);
}

//获取当前音量大小
- (unsigned int)getVolume
{
    return IYouMeVoiceEngine::getInstance ()->getVolume ();
}

//设置音量
- (void)setVolume:(unsigned int)uiVolume
{
    IYouMeVoiceEngine::getInstance ()->setVolume(uiVolume);
}

-(void)setAutoSendStatus:(bool)bAutoSend{
    IYouMeVoiceEngine::getInstance ()->setAutoSendStatus( bAutoSend );
}

//多人语音接口

//加入音频会议
- (YouMeErrorCode)joinChannelSingleMode:(NSString *)strUserID channelID:(NSString *)strChannelID userRole:(YouMeUserRole)userRole
{
    return IYouMeVoiceEngine::getInstance()->joinChannelSingleMode([strUserID UTF8String],[strChannelID UTF8String], userRole);
}

- (YouMeErrorCode_t) joinChannelSingleMode:(NSString *)strUserID channelID:(NSString *)strChannelID userRole:(YouMeUserRole_t)userRole  joinAppKey:(NSString*) strJoinAppKey
{
    return IYouMeVoiceEngine::getInstance()->joinChannelSingleMode([strUserID UTF8String],[strChannelID UTF8String], userRole, [strJoinAppKey UTF8String]);
}

- (YouMeErrorCode)joinChannelMultiMode:(NSString *)strUserID channelID:(NSString *)strChannelID
{
    return IYouMeVoiceEngine::getInstance()->joinChannelMultiMode([strUserID UTF8String],[strChannelID UTF8String]);
}

- (YouMeErrorCode) speakToChannel:(NSString *)strChannelID{
    return IYouMeVoiceEngine::getInstance()->speakToChannel( [ strChannelID UTF8String ]);
}

//退出音频会议
- (YouMeErrorCode)leaveChannelMultiMode:(NSString *)strChannelID
{
    
    return IYouMeVoiceEngine::getInstance ()->leaveChannelMultiMode ([strChannelID UTF8String]);
}

- (YouMeErrorCode)leaveChannelAll
{
    
    return IYouMeVoiceEngine::getInstance ()->leaveChannelAll ();
}

//是否使用移动网络,默认不用
- (void)setUseMobileNetworkEnabled:(bool)bEnabled
{
    IYouMeVoiceEngine::getInstance ()->setUseMobileNetworkEnabled (bEnabled);
}

- (bool) getUseMobileNetworkEnabled{
    return IYouMeVoiceEngine::getInstance ()->getUseMobileNetworkEnabled();
}

- (void)setToken:(NSString*) token
{
    IYouMeVoiceEngine::getInstance()->setToken( [token UTF8String ]);
}

- (YouMeErrorCode)playBackgroundMusic:(NSString *)path   repeat:(bool)repeat
{
    return IYouMeVoiceEngine::getInstance ()->playBackgroundMusic([path UTF8String], repeat );
}

- (YouMeErrorCode)pauseBackgroundMusic
{
    return IYouMeVoiceEngine::getInstance()->pauseBackgroundMusic();
}

- (YouMeErrorCode)resumeBackgroundMusic
{
    return IYouMeVoiceEngine::getInstance()->resumeBackgroundMusic();
}

- (YouMeErrorCode)stopBackgroundMusic
{
    return IYouMeVoiceEngine::getInstance()->stopBackgroundMusic();
}

- (YouMeErrorCode)setBackgroundMusicVolume:(unsigned int)bgVolume
{
    return IYouMeVoiceEngine::getInstance()->setBackgroundMusicVolume(bgVolume);
}

//获取SDK版本号
- (int)getSDKVersion
{
    return IYouMeVoiceEngine::getInstance ()->getSDKVersion();
}

//  功能描述: 设置是否将麦克风声音旁路到扬声器输出，可以为主播等提供监听自己声音和背景音乐的功能
- (YouMeErrorCode)setHeadsetMonitorOn:(bool)enabled
{
    return IYouMeVoiceEngine::getInstance()->setHeadsetMonitorOn(enabled);
}

//  功能描述: 设置主播是否开启混响模式
- (YouMeErrorCode)setReverbEnabled:(bool)enabled
{
    return IYouMeVoiceEngine::getInstance()->setReverbEnabled(enabled);
}

- (YouMeErrorCode)setVadCallbackEnabled:(bool)enabled
{
    return IYouMeVoiceEngine::getInstance()->setVadCallbackEnabled(enabled);
}

- (YouMeErrorCode) setMicLevelCallback:(int) maxLevel{
    return IYouMeVoiceEngine::getInstance()->setMicLevelCallback(maxLevel);
}

- (YouMeErrorCode) setFarendVoiceLevelCallback:(int) maxLevel{
    return IYouMeVoiceEngine::getInstance()->setFarendVoiceLevelCallback(maxLevel);
}

- (YouMeErrorCode) setReleaseMicWhenMute:(bool) enabled{
    return IYouMeVoiceEngine::getInstance()->setReleaseMicWhenMute(enabled);
}

- (void) setRecordingTimeMs:(unsigned int)timeMs
{
    return IYouMeVoiceEngine::getInstance()->setRecordingTimeMs(timeMs);
}

- (void) setPlayingTimeMs:(unsigned int)timeMs
{
    return IYouMeVoiceEngine::getInstance()->setPlayingTimeMs(timeMs);
}


- (YouMeErrorCode)pauseChannel
{
    return IYouMeVoiceEngine::getInstance ()->pauseChannel();
}


- (YouMeErrorCode_t)requestRestApi:(NSString*) strCommand strQueryBody:(NSString*) strQueryBody requestID:(int*)requestID{
    return IYouMeVoiceEngine::getInstance()->requestRestApi( [strCommand UTF8String], [strQueryBody UTF8String], requestID   );
}

- (YouMeErrorCode) getChannelUserList:(NSString*) channelID maxCount:(int)maxCount notifyMemChange:(bool)notifyMemChange {
    return IYouMeVoiceEngine::getInstance()->getChannelUserList([channelID UTF8String], maxCount, notifyMemChange );
}

- (YouMeErrorCode)resumeChannel
{
    return IYouMeVoiceEngine::getInstance ()->resumeChannel();
}

- (YouMeErrorCode_t) setGrabMicOption:(NSString*) channelID mode:(int)mode maxAllowCount:(int)maxAllowCount maxTalkTime:(int)maxTalkTime voteTime:(unsigned int)voteTime
{
	return IYouMeVoiceEngine::getInstance ()->setGrabMicOption([channelID UTF8String], mode, maxAllowCount, maxTalkTime, voteTime);
}

- (YouMeErrorCode_t) startGrabMicAction:(NSString*) channelID strContent:(NSString*) pContent
{
	return IYouMeVoiceEngine::getInstance ()->startGrabMicAction([channelID UTF8String], [pContent UTF8String]);
}

- (YouMeErrorCode_t) stopGrabMicAction:(NSString*) channelID strContent:(NSString*) pContent
{
	return IYouMeVoiceEngine::getInstance ()->stopGrabMicAction([channelID UTF8String], [pContent UTF8String]);
}

- (YouMeErrorCode_t) requestGrabMic:(NSString*) channelID score:(int)score isAutoOpenMic:(bool)isAutoOpenMic strContent:(NSString*) pContent
{
	return IYouMeVoiceEngine::getInstance ()->requestGrabMic([channelID UTF8String], score, isAutoOpenMic, [pContent UTF8String]);
}

- (YouMeErrorCode_t) releaseGrabMic:(NSString*) channelID
{
	return IYouMeVoiceEngine::getInstance ()->releaseGrabMic([channelID UTF8String]);
}

- (YouMeErrorCode) setInviteMicOption:(NSString*) channelID waitTimeout:(int)waitTimeout maxTalkTime:(int)maxTalkTime
{
	return IYouMeVoiceEngine::getInstance ()->setInviteMicOption([channelID UTF8String], waitTimeout, maxTalkTime);
}

- (YouMeErrorCode) requestInviteMic:(NSString*) channelID strUserID:(NSString*)pUserID strContent:(NSString*) pContent
{
	return IYouMeVoiceEngine::getInstance ()->requestInviteMic([channelID UTF8String], [pUserID UTF8String], [pContent UTF8String]);
}

- (YouMeErrorCode) responseInviteMic:(NSString*) pUserID isAccept:(bool)isAccept strContent:(NSString*) pContent
{
	return IYouMeVoiceEngine::getInstance ()->responseInviteMic([pUserID UTF8String], isAccept, [pContent UTF8String]);
}

- (YouMeErrorCode) stopInviteMic
{
	return IYouMeVoiceEngine::getInstance ()->stopInviteMic();
}

- (int)openVideoEncoder:(NSString *)path
{
    return IYouMeVoiceEngine::getInstance ()->openVideoEncoder([path UTF8String]);
}

// Camera capture
- (YouMeErrorCode)startCapture{
    return IYouMeVoiceEngine::getInstance ()->startCapture();
}

- (YouMeErrorCode)stopCapture{
    return IYouMeVoiceEngine::getInstance ()->stopCapture();
}

- (YouMeErrorCode)setVideoLocalResolutionWidth:(int)width height:(int)height{
    return IYouMeVoiceEngine::getInstance ()->setVideoLocalResolution(width, height);
}

- (YouMeErrorCode)setCaptureFrontCameraEnable:(bool)enable{
    return IYouMeVoiceEngine::getInstance ()->setCaptureFrontCameraEnable(enable);
}

- (YouMeErrorCode)switchCamera{
    return IYouMeVoiceEngine::getInstance ()->switchCamera();
}

- (YouMeErrorCode)resetCamera{
    return IYouMeVoiceEngine::getInstance ()->resetCamera();
}

- (YouMeErrorCode_t) sendMessage:(NSString*) channelID  strContent:(NSString*) strContent requestID:(int*)requestID{
    return IYouMeVoiceEngine::getInstance ()->sendMessage( [channelID UTF8String], [strContent UTF8String], requestID );
}

- (YouMeErrorCode_t) kickOtherFromChannel:(NSString*) userID  channelID:(NSString*)channelID lastTime:(int)lastTime
{
    return IYouMeVoiceEngine::getInstance ()->kickOtherFromChannel( [userID UTF8String], [channelID UTF8String], lastTime  );
}

- (void) setLogLevel:(YOUME_LOG_LEVEL_t) level
{
    return IYouMeVoiceEngine::getInstance ()->setLogLevel( level );
}
- (YouMeErrorCode_t) setSampleRate:(YOUME_SAMPLE_RATE_t)sampleRate
{
    return IYouMeVoiceEngine::getInstance ()->setSampleRate( sampleRate );
}

- (YouMeErrorCode_t)setVideoNetResolutionWidth:(int)width height:(int)height {
    return IYouMeVoiceEngine::getInstance ()->setVideoNetResolution( width, height );
}

- (YouMeErrorCode_t)setVideoNetResolutionLowWidth:(int)width height:(int)height {
    return IYouMeVoiceEngine::getInstance ()->setVideoNetResolutionLow( width, height );
}

- (void) setAVStatisticInterval:(int) interval
{
    return IYouMeVoiceEngine::getInstance()->setAVStatisticInterval( interval );
}

- (void) setAudioQuality:(YOUME_AUDIO_QUALITY_t)quality
{
    return IYouMeVoiceEngine::getInstance ()->setAudioQuality( quality );
}

- (void) setVideoCodeBitrate:(unsigned int) maxBitrate  minBitrate:(unsigned int ) minBitrate
{
    return IYouMeVoiceEngine::getInstance ()->setVideoCodeBitrate( maxBitrate, minBitrate );
}

- (unsigned int) getCurrentVideoCodeBitrate
{
    return IYouMeVoiceEngine::getInstance ()->getCurrentVideoCodeBitrate();
}

- (void) setVideoHardwareCodeEnable:(bool) bEnable
{
    return IYouMeVoiceEngine::getInstance ()->setVideoHardwareCodeEnable( bEnable );
}

- (bool) getVideoHardwareCodeEnable
{
    return IYouMeVoiceEngine::getInstance ()->getVideoHardwareCodeEnable();
}

- (void) setVideoNoFrameTimeout:(int) timeout
{
    return IYouMeVoiceEngine::getInstance ()->setVideoNoFrameTimeout(timeout);
}

- (bool) isInited
{
    return IYouMeVoiceEngine::getInstance()->isInited();
}


- (YouMeErrorCode_t) setUserRole:(YouMeUserRole_t) eUserRole
{
    return IYouMeVoiceEngine::getInstance()->setUserRole( eUserRole );
}

- (YouMeUserRole_t) getUserRole
{
    return IYouMeVoiceEngine::getInstance()->getUserRole();
}


- (bool) isInChannel:(NSString*) strChannelID
{
    return IYouMeVoiceEngine::getInstance()->isInChannel( [strChannelID UTF8String]);
}

- (bool) isBackgroundMusicPlaying
{
    return IYouMeVoiceEngine::getInstance()->isBackgroundMusicPlaying();
}

@end


