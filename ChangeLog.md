# ChangeLog汇总

# 版本3.0.0.213
##修改内容
1. iOS ffmpeg独立为`libffmpeg3.3.a` ，包含：libavcodec libavformat libavutil
2. Adnroid 支持arm64-v8a
3. Bugfix：音频重采样避免音量降低
4. Bugfix：安卓录音避免部分机型声音断续
5. Bugfix：修改魅蓝noto3 渲染轻微变形问题
6. Bugfix：视频连麦中离开频道可能崩溃人问题
7. Bugfix：反初始化后调用isInRoom 会崩溃的问题修复
8. Bugfix：远端音量计算间隔从200ms改为300ms
9. 优化：kFilterBilinear  改为 kFilterLinear 以换取性能，iphone 7减少 3%左右cpu
10. Demo 添加bugly监控

## 接口变更
无。

# 版本3.0.0.183
## 修改内容：
1. 数据上报服务器补充
2. 完善start/stop Input的通知
3. 增加有人被踢出房间的通知
4. 修改码率上下限设置及当前码率获取接口
5. 新增setExternalInputMode接口，用于设置是否使用由外部输入音视频数据的模式，对于七牛来说建议在init之前做为第一个接口调用
6. 增加了是否在房间中的查询接口
7. 增加了是否初始化成功的查询接口
8. 优化了回声消除模块，可抑制啸叫的发生

## 接口变更
### IOS
#### 码率上下限设置
取消原来的码率设置接口，修改为上下限设置。

```Objective-c
/**
 *  功能描述: 设置视频数据上行的码率的上下限。
 *  @param maxBitrate: 最大码率，单位kbit/s.  0无效
 *  @param minBitrate: 最小码率，单位kbit/s.  0无效
 
 *  @return None
 *
 *  @warning:需要在进房间之前设置
 */
- (void) setVideoCodeBitrate:(unsigned int) maxBitrate  minBitrate:(unsigned int ) minBitrate;
```

#### 获取当前码率接口
取消原来的基准码率获取接口，改为当前码率获取。

```Objective-c
/**
 *  功能描述: 获取视频数据上行的当前码率。
 *
 *  @return 视频数据上行的当前码率
 */
- (unsigned int) getCurrentVideoCodeBitrate;
```

#### 有人被踢出房间的通知

```Objective-c
    YOUME_EVENT_OTHERS_BE_KICKED             = 67,   ///< 房间里其他人被踢出房间
```

```Objective-c
    //param为被踢出者的userid
    - (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode roomid:(NSString *)roomid param:(NSString *)param;

```

#### 设置是否由外部输入音视频
用于设置是否使用由外部输入音视频数据的模式，对于七牛来说建议在init之前做为第一个接口调用

```Objective-c
/**
 *  功能描述:   设置是否由外部输入音视频
 *  @param bInputModeEnabled: true:外部输入模式，false:SDK内部采集模式
 */
- (void)setExternalInputMode:(bool)bInputModeEnabled;
```

#### 是否在房间中

```Objective-c
/**
 *  功能描述:查询是否在某个语音频道内
 *
 *  @param strChannelID:要查询的频道ID
 *
 *  @return true——在频道内，false——没有在频道内
 */
- (bool) isInChannel:(NSString*) strChannelID;
```

#### 是否初始化成功
```Objective-c
/**
 *  功能描述:判断是否初始化完成
 *
 *  @return true——完成，false——还未完成
 */
- (bool) isInited;
```

### Android
#### 码率上下限设置
取消原来的码率设置接口，修改为上下限设置。

```java
	/**
	 *  功能描述: 设置视频数据上行的码率的上下限。
	 *  @param maxBitrate: 最大码率，单位kbit/s.  0无效
	 *  @param minBitrate: 最小码率，单位kbit/s.  0无效

	 *  @return None
	 *
	 *  @warning:需要在进房间之前设置
	 */
	public static native void setVideoCodeBitrate(  int maxBitrate,   int minBitrate);
```

#### 获取当前码率接口
取消原来的基准码率获取接口，改为当前码率获取。

```java
	/**
	 *  功能描述: 获取视频数据上行的当前码率。
	 *
	 *  @return 视频数据上行的当前码率
	 */
	public static native int getCurrentVideoCodeBitrate( );
```

#### 有人被踢出房间的通知
踢人者也可以收到

```java
    public static final int  YOUME_EVENT_OTHERS_BE_KICKED             = 67;   ///< 房间里其他人被踢出房间
```

```java
    //param为被踢出者的userid
    public  void onEvent (int event, int error, String room, Object param);

```

#### 设置是否由外部输入音视频
用于设置是否使用由外部输入音视频数据的模式，对于七牛来说建议在init之前做为第一个接口调用

```java
    /**
     * 功能描述:   设置是否由外部输入音视频
     * @param bInputModeEnabled: true:外部输入模式，false:SDK内部采集模式
     */
    public static native void setExternalInputMode( boolean bInputModeEnabled );
```

#### 是否在房间中

```java
   /**
	*  功能描述:查询是否在某个语音频道内
	*
	*  @param pChannelID:要查询的频道ID
	*
	*  @return true——在频道内，false——没有在频道内
	*/
	public static native boolean isInChannel( String strChannelID );
```
#### 是否初始化成功
```java
   /**
	*  功能描述:判断是否初始化完成
	*
	*  @return true——完成，false——还未完成
	*/
	public static native boolean isInited();
```


# 版本3.0.0.172
## 修改内容：
1. iosDemo添加rtmp直播推流
2. 修正耳机插拔永远都回调拔出事件的bug
3. Android增加开始/结束视频推数据事件
4. 修复高音质下用aecm时无声的问题
5. iosDemo他人视频改为按长宽比例显示，并放大显示区域
6. 避免record采样率比playback采样率高时产生noise
7. 设置视频无渲染帧等待超时时间
8. 修复两个客户端进入同一房间，会收不到对方视频数据，或者过30秒才收到的问题
9. 增加语音音频数据UDP通路是否通畅检查
10. 加入房间，增加Appkey的额外设置
11. 增加上行音频丢包率
12. 修复反初始化可能需要等待5s的问题
13. 增加Android的so名字修改接口
14. 修改多个设置接口可以在init调用之后立刻调用。

## 接口变更
### IOS 
#### 设置加入房间用的AppKey接口

```Objective-c
/**
 *  功能描述:加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
 *
 *  @param strUserID: 用户ID，要保证全局唯一
 *  @param strChannelID: 频道ID，要保证全局唯一
 *  @param eUserRole: 用户角色，用于决定讲话/播放背景音乐等权限
 *  @param strJoinAppKey: 加入房间用额外的appkey
 *
 *  @return 错误码，详见YouMeConstDefine.h定义
 */
- (YouMeErrorCode_t) joinChannelSingleMode:(NSString *)strUserID channelID:(NSString *)strChannelID userRole:(YouMeUserRole_t)userRole  joinAppKey:(NSString*) strJoinAppKey ;

```

#### 音视频数据通路是否通畅回调
定时检查，时间间隔内（目前为5秒），有发送数据，服务器却没说收到，会报BLOCK。


```Objective-c
    YOUME_EVENT_MEDIA_DATA_ROAD_PASS          = 211,    ///音视频数据通路连通，定时检测，一开始收到数据会收到PASS事件，之后变化的时候会发送
    YOUME_EVENT_MEDIA_DATA_ROAD_BLOCK         = 212,    ///音视频数据通路不通
```

```Objective-c
    - (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode roomid:(NSString *)roomid param:(NSString *)param;

```

#### 设置视频无帧渲染的等待超时时间
（YOUME_EVENT_OTHERS_VIDEO_SHUT_DOWN）
```Objective-c
    /**
     *  功能描述: 设置视频无帧渲染的等待超时时间，超过这个时间会给上层回调
     *  @param timeout: 超时时间，单位为毫秒
     */
    void setVideoNoFrameTimeout(int timeout);
```

### Android
#### 设置加入房间用的AppKey接口

```java
	/**
	 *  功能描述:加入语音频道（单频道模式，每个时刻只能在一个语音频道里面）
	 *
	 *  @param strUserID: 用户ID，要保证全局唯一
	 *  @param strRoomID: 频道ID，要保证全局唯一
	 *  @param userRole: 用户角色，用于决定讲话/播放背景音乐等权限
	 *  @param strJoinAppKey: 加入房间用额外的appkey
	 *
	 *  @return 错误码，详见YouMeConstDefine.h定义
	 */
	public static native int joinChannelSingleModeWithAppKey (String strUserID, String strRoomID, int userRole, String strJoinAppKey );
```

#### 音视频数据通路是否通畅回调
定时检查，时间间隔内（目前为5秒），有发送数据，服务器却没说收到，会报BLOCK。

```java
	public static final int YOUME_EVENT_MEDIA_DATA_ROAD_PASS          = 211;    ///音视频数据通路连通，定时检测，一开始收到数据会收到PASS事件，之后变化的时候会发送
	public static final int YOUME_EVENT_MEDIA_DATA_ROAD_BLOCK         = 212;    ///音视频数据通路不通
```

```java
    public  void onEvent (int event, int error, String room, Object param);
```

#### 设置视频无帧渲染的等待超时时间
（YOUME_EVENT_OTHERS_VIDEO_SHUT_DOWN）
```java
    /**
     *  功能描述: 设置无视频帧渲染的等待超时时间
     *  @param timeout:单位毫秒
     */
     //api.setVideoNoFrameTimeout
    public static native void setVideoNoFrameTimeout(int timeout);
```

#### 设置so名字
```java
//YouMeManager.setSOName
public static boolean  setSOName( String str )
```


# 版本3.0.0.164
## 修改内容：
1. 修改某些分辨率，ios硬编码， android硬解码 会有绿边的问题，解决和七牛SDK录音冲突问题；
2. 增加硬编码开关
3. 增加码率设置接口
4. IOS， Android， Demo增加参数设置页面。（ 点击页面右上角“参数”按钮，需在第一次进入房间前修改。）
5. inputVideo，inputAudio增加在进入房间后才有效的保护。
6. 增加视频分辨率放大支持（支持传输分辨率大于采集分辨率）
7. 提高视频分辨率质量
8. 修复low quality的时候 ios 上面录音断音的问题
9. 增加开始导入视频通知，第一次调用 inputVideoFrame 时会通知房间内其它用户 YOUME_EVENT_OTHERS_VIDEO_INPUT_START 事件
10. 增加停止导入视频接口 stopInputVideoFrame，调用会通知房间内其它用户 YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP 事件，并重置开始导入视频的状态

## 接口变更
### IOS
#### 设置及获取视频码率

``` Objective-c
/**
 *  功能描述: 设置视频数据上行的基准码率
 *  @param bitrate: 单位kbit/s
 *
 *  @return None
 *x
 *  @note: 设置的是基准码率，如果网络较差，可能在此基础上进行动态调整。
 *  @warning:需要在进房间之前设置
 */
- (void) setVideoCodeBitrate:(unsigned int) bitrate;

/**
 *  功能描述: 获取视频数据上行的基准码率，没有进行设置的情况下，返回0，由SDK内部自行决定基准码率。
 *
 *  @return 视频数据上行的基准码率, 默认为0
 */
- (unsigned int) getVideoCodeBitrate;
```

#### 设置和获取是否允许硬编码

``` Objective-c
/**
 *  功能描述: 设置视频数据是否同意开启硬编硬解
 *  @param bEnable: true:开启，false:不开启
 *
 *  @return None
 *
 *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
 *  @warning:需要在进房间之前设置
 */
- (void) setVideoHardwareCodeEnable:(bool) bEnable;

/**
 *  功能描述: 获取视频数据是否同意开启硬编硬解
 *  @return true:开启，false:不开启， 默认为true;
 *
 *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
 */
- (bool) getVideoHardwareCodeEnable;

```

#### 停止导入视频

``` Objective-c
/**
*  功能描述: 停止导入视频
*  @param None
*
*  @return None
*
*  @note: 停止导入视频，房间内其它用户会收到 YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP 通知
*  @warning:需要在进房间之后设置
*/
- (void)stopInputVideoFrame;
```
回调：

``` Objective-c
- (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode roomid:(NSString *)roomid param:(NSString *)param;
```
回调参数:

    `event` = YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP
    `param`  = userID 


### Android
#### 设置及获取视频码率

``` java
/**
	 *  功能描述: 设置视频数据上行的基准码率
	 *  @param bitrate: 单位kbit/s
	 *
	 *  @return None
	 *
	 *  @note: 设置的是基准码率，如果网络较差，可能在此基础上进行动态调整。
	 *  @warning:需要在进房间之前设置
	 */
	public static native void setVideoCodeBitrate( int bitrate );

	/**
	 *  功能描述: 获取视频数据上行的基准码率，没有进行设置的情况下，返回0，由SDK内部自行决定基准码率。
	 *
	 *  @return 视频数据上行的基准码率, 默认为0
	 */
	public static native int getVideoCodeBitrate( );
```

#### 设置和获取是否允许硬编码
	
``` java
	/**
	 *  功能描述: 设置视频数据是否同意开启硬编硬解
	 *  @param bEnable: true:开启，false:不开启
	 *
	 *  @return None
	 *
	 *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
	 *  @warning:需要在进房间之前设置
	 */
	public static native void setVideoHardwareCodeEnable( boolean bEnable );

	/**
	 *  功能描述: 获取视频数据是否同意开启硬编硬解
	 *  @return true:开启，false:不开启， 默认为true;
	 *
	 *  @note: 实际是否开启硬解，还跟服务器配置及硬件是否支持有关，要全部支持开启才会使用硬解。并且如果硬编硬解失败，也会切换回软解。
	 */
	public static native boolean getVideoHardwareCodeEnable( );
	
```

#### 停止导入视频

``` java
    /**
     *  功能描述: 停止导入视频
     *  @param None
     *
     *  @return None
     *
     *  @note: 停止导入视频，房间内其它用户会收到 YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP 通知
     *  @warning:需要在进房间之后设置
     */
     public static native void stopInputVideoFrame( );
```
回调：

``` java
public void onEvent (int event, int error, String room, Object param)
```

回调参数:
    `event` = YOUME_EVENT_OTHERS_VIDEO_INPUT_START
    `param`  = userID 


# 版本3.0.0.152
## 修改内容：
1. 支持硬编硬解
2. 修复IOS部分机型信号量创建失败的问题
3. 增加硬编解码失败后切换软编码
4. 增加视频上行丢包率统计（UDP，有可能丢）
5. 增加远端音量回调
6. 增加内部动态调整码率帧率
7. 增加了远端音量回调
8. IOSDEMO改为用mix回调播放


## 接口变更

### IOS：
1. 远端音量回调

``` Objective-c
/**
 *  功能描述: 设置是否开启远端说话人音量回调, 并设置相应的参数
 *  @param maxLevel, 音量最大时对应的级别，最大可设100。
 *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
 *                   设 0 表示关闭回调。
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
- (YouMeErrorCode_t) setFarendVoiceLevelCallback:(int) maxLevel;
```
回调：

``` Objective-c
- (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode roomid:(NSString *)roomid param:(NSString *)param;
```
回调参数:

    `event` = YOUME_EVENT_FAREND_VOICE_LEVEL
    `param`  = userID 
    `errcode` = 音量值

### Android:
1. 远端音量回调

``` java
/**
 *  功能描述: 设置是否开启远端语音音量回调, 并设置相应的参数
 *  @param maxLevel, 音量最大时对应的级别，最大可设100。
 *                   比如你只在UI上呈现10级的音量变化，那就设10就可以了。
 *                   设 0 表示关闭回调。
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
public static native int setFarendVoiceLevelCallback(int maxLevel);
```

回调：
``` java
public void onEvent (int event, int error, String room, Object param)
```

回调参数:
    `event` = YOUME_EVENT_FAREND_VOICE_LEVEL
    `param`  = userID 
    `error` = 音量值


# 版本3.0.0.138
## 修改内容：
1. 提供设置传输音频质量的接口
2. 增加Ios硬编码
3. 增加接收方卡顿和丢包率统计
     *   YOUME_AVS_AUDIO_PACKET_LOSS_RATE = 4, //音频丢包率,千分比
     *   YOUME_AVS_VIDEO_PACKET_LOSS_RATE = 5, //视频丢包率,千分比
     *   YOUME_AVS_VIDEO_BLOCK = 6, //视频卡顿,是否发生过卡顿0/1
4. rscode支持动态NPAR
5. 修改OnMemberChange没有主动回调问题
6. 修改OnMemberChange增加isUpdate参数
7. AEC支持32K
8. 增加码率动态设置
9. NS和AGC支持48K采样率处理


## 接口变更：
### IOS:
1. MemberChangte

``` Objective-c
// 增加isUpdate参数，进入房间时的通知为false,进入房间后，其他人进出的通知为true
- (void)onMemberChange:(NSString*) channelID changeList:(NSArray*) changeList isUpdate:(bool) isUpdate
```

2. 增加音频质量接口
   **调用时机:** 初始化成功以后，进入房间之前

``` Objective-c
    /**
     *  功能描述: 设置Audio的传输质量
     *  @param quality: 0:low 1:high
     *
     *  @return None
     */
    - (void) setAudioQuality:(YOUME_AUDIO_QUALITY_t)quality;
```

### Android:
1. MemberChange

``` java
 // 增加isUpdate参数，进入房间时的通知为false,进入房间后，其他人进出的通知为true
 public  void onMemberChange(String channelID, MemberChange[] arrChanges, boolean isUpdate  )
```
  
2. 增加音频质量接口
   **调用时机:**初始化成功以后，进入房间之前

``` java
/**
 *  功能描述: 设置语音传输质量
 *  @param quality: 0: low, 1: high
 *  @return YOUME_SUCCESS - 成功
 *          其他 - 具体错误码
 */
public static native void  setAudioQuality(  int quality  );
```

# 版本3.0.0.135
## 变更：
1. inputVideoFrame增加mirror参数（是否镜像）
2. 增加音频码率，视频码率帧率的统计回调。
3. 录音和播放可以支持48K输入输出(目前高于16k不支持回声消除)
4. setVideoNetResolutionWidth支持非标准分辨率
5. 修改一个人在房间的时候没有音频回调问题
6. 修改Rotation为0的情况下，远端视频颠倒问题
7. 修改锁屏之后，扬声器听不到声音的问题。

## 接口变更：
### IOS：

1. 增加音频码率，视频码率帧率的统计回调间隔设置。
   **调用时机：**进入房间之前

``` Objective-c
	- (void) setAVStatisticInterval:(int) interval ;
```
	interval ：单位毫秒，默认为0，为0时不统计。需要在第一次进房间前设置。
	
	
2. 增加音频码率，视频码率帧率的统计回调函数。

``` Objective-c
	// VoiceEngineCallback::
	- (void) onAVStatistic:(YouMeAVStatisticType_t)type  userID:(NSString*)userID  value:(int) value ;
```
 	
3. inputVideoFrame增加mirror参数
 
``` Objective-c
	- (BOOL)inputVideoFrame:(void *)data Len:(int)len Width:(int)width Height:(int)height Fmt:(int)fmt Rotation:(int)rotation Mirror:(int)mirror Timestamp:(uint64_t)timestamp;
```
**mirror：** 输入流是否需要镜像处理， `0`为不镜像，`1`或者`非0`为镜像
	
	
### Android:

1. 增加音频码率，视频码率帧率的统计回调间隔设置。
   **调用时机：** 进入房间之前
``` java
	Public static native void setAVStatisticInterval(int interval);
```
	
	**interval：** 单位毫秒，默认为0，为0时不统计。需要在第一次进房间前设置。

2. 增加音频码率，视频码率帧率的统计回调函数。
	
``` java
	YouMeCallBackInterface::
	Public void onAVStatistic(int avType,String userID,int value);
```

3. inputVideoFrame增加mirror参数
	
``` java
	Public native static boolean inputVideoFrame(byte[] data, int len,int width,int height,int fmt,int rotation,int mirror,long timestamp);
```


# 版本3.0.0.130
## 变更：
### iOS
 
1.  添加了设置分辨率接口:
   **调用时机：** 初始化成功之后，进入房间之前
 
``` Objective-c
	[[YMVoiceService getInstance] setVideoNetResolutionWidth:240 height:320];
```
 
2. 设置音频采样率，默认值是48k，
   **调用时机：** 如果使用非默认值，需要在发送音频前设置：
 
 ``` Objective-c
	[[YMVoiceService getInstance] setSampleRate: SAMPLE_RATE_48 ];
```
 
3. iOS静态库库大小缩减；
4. 自测发现的crash修正，以及网络稳定性优化；
5. Demo右上方添加了混流的渲染；
	混流接口

``` Objective-c
// 设置画布尺寸 
[[YMEngineService getInstance] setMixVideoWidth:320 Height:480]; 
// 指定userid的混合尺寸，必须指定了本地userid才会有混流的回调，因为混流是以本地的视频为参考
[[YMEngineService getInstance] addMixOverlayVideoUserId:@"userid" PosX:0 PosY:0 PosZ:0 Width:320 Height:480]; 
```
 
### Android
1. 添加了音频的3A前处理；
2. 添加移除混流接口（待测试验证）：    
``` java
    VideoMgr.removeMixOverlayVideo();
```

