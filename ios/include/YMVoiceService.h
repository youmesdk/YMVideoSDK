//
//  YMVoiceService.h
//  YmTalkTestRef
//
//  Created by pinky on 2017/5/27.
//  Copyright © 2017年 Youme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceEngineCallback.h"



@interface YMVoiceService : NSObject
@property (nonatomic, retain) id<VoiceEngineCallback> delegate;

//公共接口
+ (YMVoiceService *)getInstance;
+ (void)destroy;

- (void)setTestServer:(bool) isTest;

/**
 *  功能描述:初始化引擎
 *
 *  @param delegate:回调地址
 *  @param appkey:在申请SDK注册时得到的App Key，也可凭账号密码到http://gmx.dev.net/createApp.html查询
 *  @param appSecret:在申请SDK注册时得到的App Secret，也可凭账号密码到http://gmx.dev.net/createApp.html查询
 *  @param region:可选的服务器区域
 *  @param serverRegionName:
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t)initSDK:(id<VoiceEngineCallback>)delegate  appkey:(NSString*)appKey  appSecret:(NSString*)appSecret
        regionId:(YOUME_RTC_SERVER_REGION_t)regionId
           serverRegionName:(NSString*) serverRegionName;

/**
 *  功能描述:设置身份验证的token
 *  @param token: 身份验证用token，设置空字符串，清空token值。
 *  @return 无
 */
- (void)setToken:(NSString*) token;

/**
 *  功能描述:反初始化引擎
 *
 *  @return 错误码
 */
- (YouMeErrorCode_t)unInit;

/**
 *  功能描述:设置服务器区域
 *  @param region: 可选的服务器区域
 *  @return 无
 */
-(void)setServerRegion:(YOUME_RTC_SERVER_REGION_t)serverRegionId regionName:(NSString*)regionName bAppend:(bool)bAppend;

/**
 *  功能描述:设置是否用扬声器输出
 *
 *  @param bOutputToSpeaker:true——使用扬声器，false——使用听筒
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t)setOutputToSpeaker:(bool)bOutputToSpeaker;

/**
 *  功能描述:设置扬声器静音
 *
 *  @param mute:true——静音，false——取消静音
 *  @return 无
 */
-(void)setSpeakerMute:(bool)mute;

/**
 *  功能描述:获取扬声器静音状态
 *
 *  @return true——静音，false——没有静音
 */
-(bool)getSpeakerMute;

/**
 *  功能描述:获取麦克风静音状态
 *
 *  @return true——静音，false——没有静音
 */
-(bool)getMicrophoneMute;

/**
 *  功能描述:设置麦克风静音
 *
 *  @param mute:true——静音，false——取消静音
 *  @return 无
 */
-(void)setMicrophoneMute:(bool)mute;

-(int) createRender:(NSString*) userId;
-(int) deleteRender:(int) renderId;

/**
 *  功能描述:设置是否通知其他人自己的开关麦克风和扬声器的状态
 *
 *  @param bAutoSend:true——通知，false——不通知
 *  @return 无
 */
-(void)setAutoSendStatus:(bool)bAutoSend;

/**
 *  功能描述:获取音量大小,此音量值为程序内部的音量，与系统音量相乘得到程序使用的实际音量
 *
 *  @return 音量值[0,100]
 */
- (unsigned int)getVolume;
/**
 *  功能描述:增加音量，音量数值加1
 *
 *  @return 无
 */
- (void)setVolume:(unsigned int)uiVolume;

/**
 *  功能描述:启用/禁用移动网络
 *
 *  @param bEnabled:true-可以启用，false-禁用，默认禁用
 *
 *  @return 无
 */
- (void)setUseMobileNetworkEnabled:(bool)bEnabled;

/**
 *  功能描述:是否可使用移动网络
 *
 *  @return true-可以使用，false-禁用
 */
- (bool) getUseMobileNetworkEnabled;

//多人语音接口
/**
 *  功能描述:加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
 *
 *  @param strUserID: 用户ID，要保证全局唯一
 *  @param strChannelID: 频道ID，要保证全局唯一
 *  @param userRole: 用户角色，用于决定讲话/播放背景音乐等权限
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t) joinChannelSingleMode:(NSString *)strUserID channelID:(NSString *)strChannelID userRole:(YouMeUserRole_t)userRole;

/**
 *  功能描述：加入语音频道（多频道模式，可以同时在多个语音频道里面）
 *
 *  @param strUserID: 用户ID，要保证全局唯一
 *  @param strChannelID: 频道ID，要保证全局唯一
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t) joinChannelMultiMode:(NSString *)strUserID channelID:(NSString *)strChannelID;

/**
 *  功能描述：对指定频道说话
 *
 *  @param strChannelID: 频道ID，要保证全局唯一
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t) speakToChannel:(NSString *)strChannelID;

//退出音频会议
/**
 *  功能描述:退出多频道模式下的某个语音频道
 *
 *  @param strChannelID:频道ID，要保证全局唯一
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t)leaveChannelMultiMode:(NSString *)strChannelID;

/**
 *  功能描述:退出所有语音频道
 *
 *  @return 错误码
 */
- (YouMeErrorCode_t)leaveChannelAll;



/**
 *  功能描述:获取SDK 版本号
 *
 *
 *  @return 整形数字版本号
 */
- (int)getSDKVersion;

/**
 *  功能描述:控制其他人的麦克风开关
 *
 *  @param strUserID:用户ID，要保证全局唯一
 *  @param mute: true 静音对方的麦克风，false 取消静音对方麦克风
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
-(void) setOtherMicMute:(NSString *)strUserID  mute:(bool) mute;

/**
 *  功能描述:控制其他人的扬声器开关
 *
 *  @param strUserID:用户ID，要保证全局唯一
 *  @param mute: true 静音对方的扬声器，false 取消静音对方扬声器
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
-(void) setOtherSpeakerMute: (NSString *)strUserID  mute:(bool) mute;

/**
 *  功能描述:选择消除其他人的语音
 *
 *  @param strUserID:用户ID，要保证全局唯一
 *  @param isOn: false屏蔽对方语音，true取消屏蔽
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
-(void) setListenOtherVoice: (NSString *)strUserID  isOn:(bool) isOn;

/**
 *  功能描述: 播放背景音乐，并允许选择混合到扬声器输出麦克风输入
 *  @param pFilePath 音乐文件的路径
 *  @param repeat 是否重复播放
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)playBackgroundMusic:(NSString *)path  repeat:(bool)repeat;

/**
 *  功能描述: 如果当前正在播放背景音乐的话，暂停播放
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)pauseBackgroundMusic;

/**
 *  功能描述: 如果当前背景音乐处于暂停状态的话，恢复播放
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)resumeBackgroundMusic;

/**
 *  功能描述: 如果当前正在播放背景音乐的话，停止播放
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)stopBackgroundMusic;

/**
 *  功能描述: 设置背景音乐播放的音量
 *  @param vol 背景音乐的音量，范围 0-100
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setBackgroundMusicVolume:(unsigned int)bgVolume;

/**
 *  功能描述: 设置是否用耳机监听自己的声音，当不插耳机时，这个设置不起作用
 *  @param enabled, true 监听，false 不监听
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setHeadsetMonitorOn:(bool)enabled;

/**
 *  功能描述: 设置是否开启主播混响模式
 *  @param enabled, true 开启，false 关闭
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setReverbEnabled:(bool)enabled;

/**
 *  功能描述: 设置是否开启语音检测回调
 *  @param enabled, true 开启，false 关闭
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setVadCallbackEnabled:(bool)enabled;

/**
 *  功能描述: 设置是否开启讲话音量回调, 并设置相应的参数
 *  @param maxLevel, 音量最大时对应的级别，最大可设100。根据实际需要设置小于100的值可以减少回调的次数。
 *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
 *                   设 0 表示关闭回调。
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) setMicLevelCallback:(int) maxLevel;

/**
 *  功能描述: 设置是否开启远端说话人音量回调, 并设置相应的参数
 *  @param maxLevel, 音量最大时对应的级别，最大可设100。
 *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
 *                   设 0 表示关闭回调。
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) setFarendVoiceLevelCallback:(int) maxLevel;

/**
 *  功能描述: 设置当麦克风静音时，是否释放麦克风设备
 *  @param enabled,
 *      true 当麦克风静音时，释放麦克风设备，此时允许第三方模块使用麦克风设备录音。在Android上，语音通过媒体音轨，而不是通话音轨输出。
 *      false 不管麦克风是否静音，麦克风设备都会被占用。
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) setReleaseMicWhenMute:(bool) enabled;

/**
 *  功能描述: 暂停通话，释放麦克风等设备资源
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)pauseChannel;

/**
 *  功能描述: 恢复通话
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)resumeChannel;

/**
 *  功能描述: 设置当前录音的时间戳
 *  @return  None
 */
- (void) setRecordingTimeMs:(unsigned int)timeMs;

/**
 *  功能描述: 设置当前播放的时间戳
 *  @return  None
 */
- (void) setPlayingTimeMs:(unsigned int)timeMs;




/**
 *  功能描述:Rest API , 向服务器请求额外数据
 *  @param requestID: 回传id,回调的时候传回，标识消息
 *  @param strCommand: 请求的命令字符串
 *  @param strQueryBody: 请求需要的数据,json格式，内容参考restAPI
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)requestRestApi:(NSString*) strCommand strQueryBody:(NSString*) strQueryBody requestID:(int*)requestID;

/**
 *  功能描述:查询频道的用户列表
 *  @param channelID:要查询的频道ID
 *  @param maxCount:想要获取的最大数量，-1表示获取全部
 *  @param notifyMemChagne: 其他用户进出房间时，是否要收到通知
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t) getChannelUserList:(NSString*) channelID maxCount:(int)maxCount notifyMemChange:(bool)notifyMemChange ;


//---------------------抢麦接口---------------------//
/**
* 功能描述:    抢麦相关设置（抢麦活动发起前调用此接口进行设置）
* @param pChannelID: 抢麦活动的频道id
* @param mode: 抢麦模式（1:先到先得模式；2:按权重分配模式）
* @param maxAllowCount: 允许能抢到麦的最大人数
* @param maxTalkTime: 允许抢到麦后使用麦的最大时间（秒）
* @param voteTime: 抢麦仲裁时间（秒），过了X秒后服务器将进行仲裁谁最终获得麦（仅在按权重分配模式下有效）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) setGrabMicOption:(NSString*) channelID mode:(int)mode maxAllowCount:(int)maxAllowCount maxTalkTime:(int)maxTalkTime voteTime:(unsigned int)voteTime;

/**
* 功能描述:    发起抢麦活动
* @param pChannelID: 抢麦活动的频道id
* @param pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) startGrabMicAction:(NSString*) channelID strContent:(NSString*) pContent;

/**
* 功能描述:    停止抢麦活动
* @param pChannelID: 抢麦活动的频道id
* @param pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) stopGrabMicAction:(NSString*) channelID strContent:(NSString*) pContent;

/**
* 功能描述:    发起抢麦请求
* @param pChannelID: 抢麦的频道id
* @param score: 积分（权重分配模式下有效，游戏根据自己实际情况设置）
* @param isAutoOpenMic: 抢麦成功后是否自动开启麦克风权限
* @param pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) requestGrabMic:(NSString*) channelID score:(int)score isAutoOpenMic:(bool)isAutoOpenMic strContent:(NSString*) pContent;

/**
* 功能描述:    释放抢到的麦
* @param pChannelID: 抢麦活动的频道id
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) releaseGrabMic:(NSString*) channelID;


//---------------------连麦接口---------------------//
/**
* 功能描述:    连麦相关设置（角色是频道的管理者或者主播时调用此接口进行频道内的连麦设置）
* @param pChannelID: 连麦的频道id
* @param waitTimeout: 等待对方响应超时时间（秒）
* @param maxTalkTime: 最大通话时间（秒）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) setInviteMicOption:(NSString*) channelID waitTimeout:(int)waitTimeout maxTalkTime:(int)maxTalkTime;

/**
* 功能描述:    发起与某人的连麦请求（主动呼叫）
* @param pUserID: 被叫方的用户id
* @param pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) requestInviteMic:(NSString*) channelID strUserID:(NSString*)pUserID strContent:(NSString*) pContent;

/**
* 功能描述:    对连麦请求做出回应（被动应答）
* @param pUserID: 主叫方的用户id
* @param isAccept: 是否同意连麦
* @param pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) responseInviteMic:(NSString*) pUserID isAccept:(bool)isAccept strContent:(NSString*) pContent;

/**
* 功能描述:    停止连麦
* @return   YOUME_SUCCESS - 成功
*          其他 - 具体错误码
*/
- (YouMeErrorCode_t) stopInviteMic;

/**
 * 功能描述:   启动摄像头采集
 * @return   YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)startCapture;

/**
 * 功能描述:   停止摄像头采集
 * @return   YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)stopCapture;

/**
 * 功能描述:   设置摄像头采集参数
 * @return   YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setCaptureFps:(int)nFps Width:(int)nWidth Height:(int)nHeight;

/**
 * 功能描述:   是否启动前置摄像头
 * @return   YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setCaptureFrontCameraEnable:(bool)enable;

/**
 * 功能描述:   向房间广播消息
 * @param channelID: 广播房间
 * @param strContent: 广播内容-文本串
 * @param requestID:返回消息标识，回调的时候会回传该值
 * @return   YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) sendMessage:(NSString*) channelID  strContent:(NSString*) strContent  requestID:(int*) requestID;

/**
 *  功能描述: 把某人踢出房间
 *  @param  userID: 被踢的用户ID
 *  @param  channelID: 从哪个房间踢出
 *  @param  lastTime: 踢出后，多长时间内不允许再次进入
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) kickOtherFromChannel:(NSString*) userID  channelID:(NSString*)channelID   lastTime:(int) lastTime;

/**
 *  功能描述: 设置日志等级
 *  @param level: 日志等级
 */
- (void) setLogLevel:(YOUME_LOG_LEVEL_t) level;

/**
 *  功能描述: 设置语音采样率
 *  @param sampleRate: 采样率
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) setSampleRate:(YOUME_SAMPLE_RATE_t)sampleRate ;

/**
 *  功能描述: 设置视频网络传输过程的分辨率
 *  @param width:宽
 *  @param height:
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t)setVideoNetResolutionWidth:( int) width height:(int)height ;

/**
 *  功能描述: 设置音视频统计数据时间间隔
 *  @param interval:时间间隔
 */
- (void) setAVStatisticInterval:(int) interval ;

/**
 *  功能描述: 设置Audio的传输质量
 *  @param quality: 0:low 1:high
 *
 *  @return None
 */
- (void) setAudioQuality:(YOUME_AUDIO_QUALITY_t)quality;

@end

