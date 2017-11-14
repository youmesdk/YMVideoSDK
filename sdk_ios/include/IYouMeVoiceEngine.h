/**
 @file IYouMeVoiceEngine.h
 @brief 游密音频通话引擎接口
 
 该文件主要用于定义游密音频通话引擎的接口
 
 @version 1.0 Copyright(c) 2015-2020 YOUME All rights reserved.
 @author YOUME

 */
 
#ifndef cocos2d_x_sdk_IYouMeVoiceEngine_h
#define cocos2d_x_sdk_IYouMeVoiceEngine_h
#include <string>

#include "IYouMeEventCallback.h"
#include "IYouMeVideoCallback.h"
#include "YouMeConstDefine.h"

#ifdef WIN32
#ifdef YOUMEDLL_EXPORTS
#define YOUMEDLL_API __declspec(dllexport)
#else
#define YOUMEDLL_API __declspec(dllimport)
#endif
#else
#define YOUMEDLL_API __attribute ((visibility("default")))
#endif
class YOUMEDLL_API IYouMeVoiceEngine
{
public:
    /**
     *  功能描述:获取引擎实例指针
     *
     *  @return 引擎实例指针
     */
    static IYouMeVoiceEngine *getInstance ();
    
    /**
     *  功能描述:销毁引擎实例，释放内存
     *
     *  @return 无
     */
    static void destroy ();

public:
    /**
     *  功能描述:初始化引擎
     *
     *  @param pCommonCallback:通用回调类地址，需要继承IYouMeCommonCallback并实现其中的回调函数
     *  @param pConferenceCallback:会议回调类地址，需要继承IYouMeConferenceCallback并实现其中的回调函数
     *  @param strAPPKey:在申请SDK注册时得到的App Key，也可凭账号密码到http://gmx.dev.net/createApp.html查询
     *  @param strAPPSecret:在申请SDK注册时得到的App Secret，也可凭账号密码到http://gmx.dev.net/createApp.html查询
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode init (IYouMeEventCallback * pEventCallback, const char* pAPPKey, const char* pAPPSecret,
                         YOUME_RTC_SERVER_REGION serverRegionId, const char* pExtServerRegionName);

    /**
     *  功能描述:设置身份验证的token
     *  @param pToken: 身份验证用token，设置为NULL或者空字符串，清空token值。
     *  @return 无
     */
    void setToken( const char* pToken );
    
    /**
     *  功能描述:反初始化引擎
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */

    YouMeErrorCode unInit ();

	/**
	*  功能描述:判断是否初始化完成
	*
	*  @return true——完成，false——还未完成
	*/
	// 是否初始化成功
	bool isInited();

    /**
     *  功能描述: 设置用户自定义Log路径
     *  @param pFilePath Log文件的路径
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setUserLogPath(const char* pFilePath);
    
    /**
     *  功能描述:设置服务器区域
     *  @param region: YOUME_RTC_SERVER_REGION枚举可选的服务器区域
     *  @return 无
     */
    void setServerRegion(YOUME_RTC_SERVER_REGION regionId, const char* extRegionName, bool bAppend);
    
    /**
     *  功能描述:设置是否用扬声器输出
     *
     *  @param bOutputToSpeaker:true——使用扬声器，false——使用听筒
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode setOutputToSpeaker (bool bOutputToSpeaker);
    
    /**
     *  功能描述:设置扬声器静音
     *
     *  @param bOn:true——静音，false——取消静音
     *  @return 无
     */
    void setSpeakerMute (bool bOn);

    /**
     *  功能描述:获取扬声器静音状态
     *
     *  @return true——静音，false——没有静音
     */
    bool getSpeakerMute ();

    /**
     *  功能描述:获取麦克风静音状态
     *
     *  @return true——静音，false——没有静音
     */
    bool getMicrophoneMute ();

    /**
     *  功能描述:设置麦克风静音
     *
     *  @param bOn:true——静音，false——取消静音
     *  @return 无
     */
    void setMicrophoneMute (bool mute);
    
    /**
     *  功能描述:设置是否通知其他人自己的开关麦克风和扬声器的状态
     *
     *  @param bAutoSend:true——通知，false——不通知
     *  @return 无
     */
    void setAutoSendStatus( bool bAutoSend );

    /**
     *  功能描述:获取音量大小,此音量值为程序内部的音量，与系统音量相乘得到程序使用的实际音量
     *
     *  @return 音量值[0,100]
     */
    unsigned int getVolume ();

    /**
     *  功能描述:增加音量，音量数值加1
     *
     *  @return 无
     */
    void setVolume (const unsigned int &uiVolume);

    /**
     *  功能描述:是否可使用移动网络
     *
     *  @return true-可以使用，false-禁用
     */
    bool getUseMobileNetworkEnabled ();

    /**
     *  功能描述:启用/禁用移动网络
     *
     *  @param bEnabled:true-可以启用，false-禁用，默认禁用
     *
     *  @return 无
     */
    void setUseMobileNetworkEnabled (bool bEnabled);


    //---------------------多人语音接口---------------------//

    /**
     *  功能描述:加入语音频道
     *
     * @param strUserID:用户ID，要保证全局唯一
     *  @param strRoomID:频道ID，要保证全局唯一
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */

    /**
     *  功能描述:加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
     *
     *  @param pUserID: 用户ID，要保证全局唯一
     *  @param pChannelID: 频道ID，要保证全局唯一
     *  @param eUserRole: 用户角色，用于决定讲话/播放背景音乐等权限
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode joinChannelSingleMode(const char* pUserID, const char* pChannelID, YouMeUserRole_t eUserRole);

    
    /**
     *  功能描述：加入语音频道（多频道模式，可以同时在多个语音频道里面）
     *
     *  @param pUserID: 用户ID，要保证全局唯一
     *  @param pChannelID: 频道ID，要保证全局唯一
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode joinChannelMultiMode(const char* pUserID, const char* pChannelID);
    
    /**
     *  功能描述:加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
     *
     *  @param pUserID: 用户ID，要保证全局唯一
     *  @param pChannelID: 频道ID，要保证全局唯一
     *  @param eUserRole: 用户角色，用于决定讲话/播放背景音乐等权限
     *  @param pJoinAppKey: 加入房间用额外的appkey
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode joinChannelSingleMode(const char* pUserID, const char* pChannelID, YouMeUserRole_t eUserRole, const char* pJoinAppKey);
    
    /**
     *  功能描述：对指定频道说话
     *
     *  @param pChannelID: 频道ID，要保证全局唯一
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode speakToChannel(const char* pChannelID);
    
    /**
     *  功能描述:退出多频道模式下的某个语音频道
     *
     *  @param pChannelID:频道ID，要保证全局唯一
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode leaveChannelMultiMode (const char* pChannelID);
    
    /**
     *  功能描述:退出所有语音频道
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode leaveChannelAll ();
    
	/**
	*  功能描述:切换身份(仅支持单频道模式，进入房间以后设置)
	*
	*  @param eUserRole: 用户身份
	*
	*  @return 错误码，详见YouMeConstDefine.h定义
	*/
	YouMeErrorCode setUserRole(YouMeUserRole_t eUserRole);

	/**
	*  功能描述:获取身份(仅支持单频道模式)
	*
	*  @return 身份定义，详见YouMeConstDefine.h定义
	*/
	YouMeUserRole_t getUserRole();


	/**
	*  功能描述:查询是否在某个语音频道内
	*
	*  @param pChannelID:要查询的频道ID
	*
	*  @return true——在频道内，false——没有在频道内
	*/
	// 
	bool isInChannel(const char* pChannelID);

    /**
     *  功能描述:查询频道的用户列表
     *  @param channelID:要查询的频道ID
     *  @param maxCount:想要获取的最大数量，-1表示获取全部
     *  @param notifyMemChagne: 其他用户进出房间时，是否要收到通知
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode getChannelUserList( const char*  channelID, int maxCount, bool notifyMemChange );
    
    /**
     *  功能描述:控制其他人的麦克风开关
     *
     *  @param pUserID:用户ID，要保证全局唯一
     *  @param mute: true 静音对方的麦克风，false 取消静音对方麦克风
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode setOtherMicMute (const char* pUserID,bool mute);
    
    /**
     *  功能描述:控制其他人的扬声器开关
     *
     *  @param pUserID:用户ID，要保证全局唯一
     *  @param mute: true 静音对方的扬声器，false 取消静音对方扬声器
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode setOtherSpeakerMute (const char* pUserID,bool mute);
    
    /**
     *  功能描述:选择消除其他人的语音
     *
     *  @param pUserID:用户ID，要保证全局唯一
     *  @param on: false屏蔽对方语音，true取消屏蔽
     *
     *  @return 错误码，详见YouMeConstDefine.h定义
     */
    YouMeErrorCode setListenOtherVoice (const char* pUserID, bool on );

	/**
	* 功能描述: 视频数据输入(七牛接口，房间内其它用户会收到YOUME_EVENT_OTHERS_VIDEO_INPUT_START事件)
	* @param data 视频帧数据
	* @param len 视频数据大小
	* @param width 视频图像宽
	* @param height 视频图像高
	* @param fmt 视频格式
    * @param rotation 视频角度
    * @param mirror 镜像
	* @param timestamp 时间戳
	* @return YOUME_SUCCESS - 成功
	*         其他 - 具体错误码
	*/
	YouMeErrorCode inputVideoFrame(void* data, int len, int width, int	height, int fmt, int rotation, int mirror, uint64_t timestamp);
    
    /**
     * 功能描述: 视频数据输入(七牛接口，房间内其它用户会收到YOUME_EVENT_OTHERS_VIDEO_INPUT_START事件)
     * @param data 视频帧数据(ios:CVPixelBufferRef, android:textureid);
     * @param width 视频图像宽
     * @param height 视频图像高
     * @param fmt 视频格式
     * @param rotation 视频角度
     * @param mirror 镜像
     * @param timestamp 时间戳
     * @return YOUME_SUCCESS - 成功
     *         其他 - 具体错误码
     */
    YouMeErrorCode inputPixelBuffer(void* data, int width, int height, int fmt, int rotation, int mirror, uint64_t timestamp);

    
    /**
     * 功能描述: 停止视频数据输入(七牛接口，在inputVideoFrame之后调用，房间内其它用户会收到YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP事件)
     * @return YOUME_SUCCESS - 成功
     *         其他 - 具体错误码
     */
    YouMeErrorCode stopInputVideoFrame();
    
    /**
     *  功能描述: (七牛接口)将提供的音频数据混合到麦克风或者扬声器的音轨里面。
     *  @param data 指向PCM数据的缓冲区
     *  @param len  音频数据的大小
     *  @param timestamp 时间搓
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode inputAudioFrame(void* data, int len, uint64_t timestamp);

    /**
     *  功能描述: 播放背景音乐，并允许选择混合到扬声器输出麦克风输入
     *  @param pFilePath 音乐文件的路径
     *  @param bRepeat 是否重复播放
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode playBackgroundMusic(const char* pFilePath, bool bRepeat);

    /**
     *  功能描述: 如果当前正在播放背景音乐的话，暂停播放
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode pauseBackgroundMusic();
    
    /**
     *  功能描述: 如果当前背景音乐处于暂停状态的话，恢复播放
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode resumeBackgroundMusic();
    
    /**
     *  功能描述: 如果当前正在播放背景音乐的话，停止播放
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode stopBackgroundMusic();

	/**
	*  功能描述:背景音乐是否在播放
	*
	*  @return true——正在播放，false——没有播放
	*/
	bool isBackgroundMusicPlaying();

    /**
     *  功能描述: 设置背景音乐播放的音量
     *  @param vol 背景音乐的音量，范围 0-100
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setBackgroundMusicVolume(int vol);

    /**
     *  功能描述: 设置是否用耳机监听自己的声音，当不插耳机时，这个设置不起作用
     *  @param enabled, true 监听，false 不监听
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setHeadsetMonitorOn(bool enabled);
    
    /**
     *  功能描述: 设置是否开启主播混响模式
     *  @param enabled, true 开启，false 关闭
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setReverbEnabled(bool enabled);
    
    /**
     *  功能描述: 设置是否开启语音检测回调
     *  @param enabled, true 开启，false 关闭
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setVadCallbackEnabled(bool enabled);

    /**
     *  功能描述: 设置是否开启讲话音量回调, 并设置相应的参数
     *  @param maxLevel, 音量最大时对应的级别，最大可设100。根据实际需要设置小于100的值可以减少回调的次数。
     *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
     *                   设 0 表示关闭回调。
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setMicLevelCallback(int maxLevel);
    
    /**
     *  功能描述: 设置是否开启远端语音音量回调, 并设置相应的参数
     *  @param maxLevel, 音量最大时对应的级别，最大可设100。
     *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
     *                   设 0 表示关闭回调。
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setFarendVoiceLevelCallback(int maxLevel);
    
    /**
     *  功能描述: 设置当麦克风静音时，是否释放麦克风设备
     *  @param enabled,
     *      true 当麦克风静音时，释放麦克风设备，此时允许第三方模块使用麦克风设备录音。在Android上，语音通过媒体音轨，而不是通话音轨输出。
     *      false 不管麦克风是否静音，麦克风设备都会被占用。
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setReleaseMicWhenMute(bool enabled);

    /**
     *  功能描述: 暂停通话，释放麦克风等设备资源
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode pauseChannel();

    /**
     *  功能描述: 恢复通话
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode resumeChannel();
    
    /**
     *  功能描述: 设置当前录音的时间戳
     *  @return  None
     */
    void setRecordingTimeMs(unsigned int timeMs);
    
    /**
     *  功能描述: 设置当前播放的时间戳
     *  @return  None
     */
    void setPlayingTimeMs(unsigned int timeMs);
    
    /**
     *  功能描述: 设置PCM数据回调对象
     *  @return  None
     */
    YouMeErrorCode setPcmCallback(IYouMePcmCallback* pcmCallback);

    /**
     *  功能描述:获取SDK 版本号
     *
     *
     *  @return 整形数字版本号
     */
    int getSDKVersion ();
	
	  /**
     *  功能描述:Rest API , 向服务器请求额外数据
     *  @param requestID: 回传id,回调的时候传回，标识消息
     *  @param strCommand: 请求的命令字符串
     *  @param strQueryBody: 请求需要的数据,json格式，内容参考restAPI
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode  requestRestApi( const char* strCommand , const char* strQueryBody , int* requestID = NULL  );
    
	/**
     *  功能描述:requestRestApi的回调消息
     *  @param cb: requestRestApi的回调， 需要继承IRestApiCallback并实现其中的回调函数
     *
     *  @return None
     */
    void setRestApiCallback(IRestApiCallback* cb );
    
    /**
     *  功能描述:getChannelUserList的回调消息
     *  @param cb: getChannelUserList的回调， 需要继承IYouMeMemberChangeCallback并实现其中的回调函数
     *
     *  @return None
     */
    void setMemberChangeCallback( IYouMeMemberChangeCallback* cb );

	/**
	 * 功能描述:    设置频道内的广播消息回调(抢麦、连麦等）
	 * @param cb: 抢麦、连麦等的广播回调，需要继承IYouMeNotifyCallback并实现其中的回调函数
	 * @return   void: 
	 */
	 void setNotifyCallback(IYouMeChannelMsgCallback* cb);

	//---------------------抢麦接口---------------------//
	 /**
	 * 功能描述:    抢麦相关设置（抢麦活动发起前调用此接口进行设置）
	 * @param const char * pChannelID: 抢麦活动的频道id
	 * @param int mode: 抢麦模式（1:先到先得模式；2:按权重分配模式）
	 * @param int maxAllowCount: 允许能抢到麦的最大人数
	 * @param int maxTalkTime: 允许抢到麦后使用麦的最大时间（秒）
	 * @param unsigned int voteTime: 抢麦仲裁时间（秒），过了X秒后服务器将进行仲裁谁最终获得麦（仅在按权重分配模式下有效）
	 * @return   YOUME_SUCCESS - 成功
	 *          其他 - 具体错误码
	 */
	 YouMeErrorCode setGrabMicOption(const char* pChannelID, int mode, int maxAllowCount, int maxTalkTime, unsigned int voteTime);

	/**
	 * 功能描述:    发起抢麦活动
	 * @param const char * pChannelID: 抢麦活动的频道id
	 * @param const char * pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
	 * @return   YOUME_SUCCESS - 成功
	 *          其他 - 具体错误码
	 */
	YouMeErrorCode startGrabMicAction(const char* pChannelID, const char* pContent);

	/**
	 * 功能描述:    停止抢麦活动
	 * @param const char * pChannelID: 抢麦活动的频道id
	 * @param const char * pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
	 * @return   YOUME_SUCCESS - 成功
	 *          其他 - 具体错误码
	 */
	YouMeErrorCode stopGrabMicAction(const char* pChannelID, const char* pContent);

	 /**
	  * 功能描述:    发起抢麦请求
	  * @param const char * pChannelID: 抢麦的频道id
	  * @param int score: 积分（权重分配模式下有效，游戏根据自己实际情况设置）
	  * @param bool isAutoOpenMic: 抢麦成功后是否自动开启麦克风权限
	  * @param const char * pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
	  * @return   YOUME_SUCCESS - 成功
	  *          其他 - 具体错误码
	  */
	 YouMeErrorCode requestGrabMic(const char* pChannelID, int score, bool isAutoOpenMic, const char* pContent);

	 /**
	  * 功能描述:    释放抢到的麦
	  * @param const char * pChannelID: 抢麦活动的频道id
	  * @return   YOUME_SUCCESS - 成功
	  *          其他 - 具体错误码
	  */
	 YouMeErrorCode releaseGrabMic(const char* pChannelID);


	//---------------------连麦接口---------------------//
	 /**
	 * 功能描述:    连麦相关设置（角色是频道的管理者或者主播时调用此接口进行频道内的连麦设置）
	 * @param const char * pChannelID: 连麦的频道id
	 * @param int waitTimeout: 等待对方响应超时时间（秒）
	 * @param int maxTalkTime: 最大通话时间（秒）
	 * @return   YOUME_SUCCESS - 成功
	 *          其他 - 具体错误码
	 */
	 YouMeErrorCode setInviteMicOption(const char* pChannelID, int waitTimeout, int maxTalkTime);

	 /**
	  * 功能描述:    发起与某人的连麦请求（主动呼叫）
	  * @param const char * pUserID: 被叫方的用户id
	  * @param const char * pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
	  * @return   YOUME_SUCCESS - 成功
	  *          其他 - 具体错误码
	  */
	 YouMeErrorCode requestInviteMic(const char* pChannelID, const char* pUserID, const char* pContent);

	 /**
	  * 功能描述:    对连麦请求做出回应（被动应答）
	  * @param const char * pUserID: 主叫方的用户id
	  * @param bool isAccept: 是否同意连麦
	  * @param const char * pContent: 游戏传入的上下文内容，通知回调会传回此内容（目前只支持纯文本格式）
	  * @return   YOUME_SUCCESS - 成功
	  *          其他 - 具体错误码
	  */
	 YouMeErrorCode responseInviteMic(const char* pUserID, bool isAccept, const char* pContent);

	 /**
	  * 功能描述:    停止连麦
	  * @return   YOUME_SUCCESS - 成功
	  *          其他 - 具体错误码
	  */
	 YouMeErrorCode stopInviteMic();
	 
	/**
     * 功能描述:   向房间广播消息
     * @param pChannelID: 广播房间
     * @param pContent: 广播内容-文本串
     * @param requestID:返回消息标识，回调的时候会回传该值
     * @return   YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
	YouMeErrorCode  sendMessage( const char* pChannelID,  const char* pContent, int* requestID );
    
    /**
     * 功能描述:   设置是否由外部输入音视频
     * @param bInputModeEnabled: true:外部输入模式，false:SDK内部采集模式
     */
    void setExternalInputMode( bool bInputModeEnabled );
    
	/**
     *  功能描述: 设置是否开启视频编码器
     *  @param pFilePath: yuv文件的绝对路径
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode openVideoEncoder(const char* pFilePath);
    
    
    /**
     *  功能描述: 创建渲染
     *  @param : userId 用户ID
     *  @return 大于等于0 - renderId
     *          小于0 - 具体错误码
     */
    int createRender(const char * userId);
    
    /**
     *  功能描述: 删除渲染
     *  @param : renderId
     *  @return 等于0 - success
     *          小于0 - 具体错误码
     */
    int deleteRender(int renderId);
    
    /**
     *  功能描述: 屏蔽视频流
     *  @param : userId 用户ID
     *  @param : mask 1 屏蔽, 0 恢复
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode maskVideoByUserId(const char * userId, bool mask);
    
    /***
     * 功能描述：设置视频回调
     * @param cb
     * @return YOUME_SUCCESS  - 成功
     *         其它           - 具体错误码
     */
    YouMeErrorCode setVideoCallback(IYouMeVideoCallback * cb);
    
    /**
     *  功能描述: 开始camera capture
     *  @param
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode startCapture();
    
    /**
     *  功能描述: 停止camera capture
     *  @param
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode stopCapture();
    
    /**
     *  功能描述: 设置本地视频渲染回调的分辨率
     *  @param width:宽
     *  @param height:高
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setVideoLocalResolution(int width, int height);
    
    /**
     *  功能描述: 设置是否前置摄像头
     *  @param
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setCaptureFrontCameraEnable(bool enable);
    
    /**
     *  功能描述: 切换前置/后置摄像头
     *  @param
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode switchCamera();
    
    /**
     *  功能描述: 权限检测结束后重置摄像头
     *  @param
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode resetCamera();
    
    
    /**
     *  功能描述: 把某人踢出房间
     *  @param  pUserID: 被踢的用户ID
     *  @param  pChannelID: 从哪个房间踢出
     *  @param  lastTime: 踢出后，多长时间内不允许再次进入
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode kickOtherFromChannel( const char* pUserID, const char* pChannelID , int lastTime );
    
    /**
     *  功能描述: 设置日志等级
     *  @param consoleLevel: 控制台日志等级
     *  @param fileLevel: 文件日志等级
     */
    void setLogLevel( YOUME_LOG_LEVEL consoleLevel, YOUME_LOG_LEVEL fileLevel);
    
    /**
     *  功能描述: 设置语音采样率
     *  @param sampleRate:语音采样率
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setSampleRate( YOUME_SAMPLE_RATE sampleRate );
    
    /**
     *  功能描述: 设置视频网络传输过程的分辨率,高分辨率
     *  @param width:宽
     *  @param height:高
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setVideoNetResolution( int width, int height );
    
    /**
     *  功能描述: 设置视频网络传输过程的分辨率，低分辨率
     *  @param width:宽
     *  @param height:高
     *  @return YOUME_SUCCESS - 成功
     *          其他 - 具体错误码
     */
    YouMeErrorCode setVideoNetResolutionLow( int width, int height );
    
    /**
     *  功能描述: 设置音视频统计数据时间间隔
     *  @param interval:时间间隔
     */
    void setAVStatisticInterval( int interval  );
    
    /**
     *  功能描述: 设置Audio,Video的统计数据的回调接口
     *  @param cb: 需要继承IYouMeAVStatisticCallback并实现其中的回调函数
     *
     *  @return None
     */
    void setAVStatisticCallback( IYouMeAVStatisticCallback* cb );
    
    /**
     *  功能描述: 设置Audio的传输质量
     *  @param quality: 0: low 1: high
     *
     *  @return None
     */
    void setAudioQuality( YOUME_AUDIO_QUALITY quality );
    
    /**
     *  功能描述: 设置视频数据上行的码率的上下限。
     *  @param maxBitrate: 最大码率，单位kbit/s.  0无效
     *  @param minBitrate: 最小码率，单位kbit/s.  0无效
     
     *  @return None
     *
     *  @warning:需要在进房间之前设置
     */
    void setVideoCodeBitrate( unsigned int maxBitrate,  unsigned int minBitrate );
    
    /**
     *  功能描述: 获取视频数据上行的当前码率。
     *
     *  @return 视频数据上行的当前码率
     */
    unsigned int getCurrentVideoCodeBitrate( );
    
    /**
     *  功能描述: 设置视频数据是否同意开启硬编硬解
     *  @param bEnable: true:开启，false:不开启
     *
     *  @return None
     *
     *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
     *  @warning:需要在进房间之前设置
     */
    void setVideoHardwareCodeEnable( bool bEnable );
    
    /**
     *  功能描述: 获取视频数据是否同意开启硬编硬解
     *  @return true:开启，false:不开启， 默认为true;
     *
     *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
     */
    bool getVideoHardwareCodeEnable( );
    
    /**
     *  功能描述: 设置视频无帧渲染的等待超时时间，超过这个时间会给上层回调
     *  @param timeout: 超时时间，单位为毫秒
     */
    void setVideoNoFrameTimeout(int timeout);

#if MAC_OS
public:
#else
private:
#endif
    IYouMeVoiceEngine ();
    ~IYouMeVoiceEngine ();
};


#endif
