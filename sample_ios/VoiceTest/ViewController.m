//
//  ViewController.m
//  VoiceTest
//
//  Created by kilo on 16/7/12.
//  Copyright © 2016年 kilo. All rights reserved.
//

#import "ViewController.h"
#import "YMVoiceService.h"
#import "YMEngineService.h"
#import "OpenGLView20.h"
#import "LFLiveKit.h"
#import "libyuv.h"
#import <Bugly/Bugly.h>

#import "ParamViewController.h"

#define MIX_WIDTH 320
#define MIX_HEIGHT 480
//推流地址，观看也是同一个地址，可以用软件 mpv或者VLC 观看
#define PUSH_ADDRESS @"rtmp://185.185.41.21:1935/live/livestream"

inline static NSString *formatedSpeed(float bytes, float elapsed_milli) {
    if (elapsed_milli <= 0) {
        return @"N/A";
    }
    
    if (bytes <= 0) {
        return @"0 KB/s";
    }
    
    float bytes_per_sec = ((float)bytes) * 1000.f /  elapsed_milli;
    if (bytes_per_sec >= 1000 * 1000) {
        return [NSString stringWithFormat:@"%.2f MB/s", ((float)bytes_per_sec) / 1000 / 1000];
    } else if (bytes_per_sec >= 1000) {
        return [NSString stringWithFormat:@"%.1f KB/s", ((float)bytes_per_sec) / 1000];
    } else {
        return [NSString stringWithFormat:@"%ld B/s", (long)bytes_per_sec];
    }
}

@implementation  ParamSetting



@end

@interface ViewController () <ICameraRecordDelegate,LFLiveSessionDelegate>
// OpenGL ES
@property (nonatomic , strong)  OpenGLView20* mGL20View;

@property (nonatomic , strong)  OpenGLView20* mGL20View2;
@property (nonatomic , strong)  OpenGLView20* mGL20View3_mix;

@property (nonatomic , strong) OpenGLView20* mGL20ViewFullScreen;
@property (nonatomic, assign)  int mFullScreenIndex;

@property (atomic,strong) NSMutableArray *userList;
@property (retain, nonatomic) IBOutlet UIView *videoGroup;
@property (retain, nonatomic) CameraCaptureDemo  *cameraCapture;

@property (nonatomic, strong) LFLiveDebug *debugInfo;
@property (nonatomic, strong) LFLiveSession *session;

@property (nonatomic,assign) BOOL startPush;
@end

@implementation ViewController

@synthesize labelState;

NSString* strJoinAppKey = @"YOUME5BE427937AF216E88E0F84C0EF148BD29B691556";

NSString* strAppKey = @"YOUMEBC2B3171A7A165DC10918A7B50A4B939F2A187D0";
NSString* strAppSecret = @"r1+ih9rvMEDD3jUoU+nj8C7VljQr7Tuk4TtcByIdyAqjdl5lhlESU0D+SoRZ30sopoaOBg9EsiIMdc8R16WpJPNwLYx2WDT5hI/HsLl1NJjQfa9ZPuz7c/xVb8GHJlMf/wtmuog3bHCpuninqsm3DRWiZZugBTEj2ryrhK7oZncBAAE=";

//2 主播扬声器没模式,5 离开房间,6 切换服务器
const int ANCHOR_SPEAKER_MODE = 2;
const int NOT_INROOM_MODE = 5;
const int CHANGE_SERVER_MODE = 6;

#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    NSLog(@"liveStateDidChange: %ld", state);
    switch (state) {
        case LFLiveReady:
            NSLog( @"未连接");
            break;
        case LFLivePending:
            NSLog(  @"连接中");
            break;
        case LFLiveStart:
            NSLog( @"已连接");
            break;
        case LFLiveError:
            NSLog( @"连接错误");
            break;
        case LFLiveStop:
            NSLog( @"未连接");
            break;
        default:
            break;
    }
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug *)debugInfo {
    NSLog(@"debugInfo uploadSpeed: %@", formatedSpeed(debugInfo.currentBandwidth, debugInfo.elapsedMilli));
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode {
    NSLog(@"errorCode: %ld", errorCode);
}

- (CVPixelBufferRef)i420FrameToPixelBuffer:(const uint8*)data width:(int)width height:(int)height
{
    if (data == nil) {
        return NULL;
    }
    CVPixelBufferRef pixelBuffer = NULL;
    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSDictionary dictionary], (id)kCVPixelBufferIOSurfacePropertiesKey, nil];
    CVReturn result = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &pixelBuffer);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Failed to create pixel buffer: %d", result);
        return NULL;
    }
    result = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    if (result != kCVReturnSuccess) {
        CFRelease(pixelBuffer);
        NSLog(@"Failed to lock base address: %d", result);
        return NULL;
    }
    uint8 *dstY = (uint8 *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    int dstStrideY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    uint8* dstUV = (uint8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    int dstStrideUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
    
    int ret = I420ToNV12((const uint8*)data, width,
                                    data+(width*height), (width+1) / 2,
                                    data+(width*height) + (width+1) / 2 * ((height+1) / 2), (width+1) / 2,
                                     dstY, dstStrideY, dstUV, dstStrideUV,
                                     width, height);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    if (ret) {
        NSLog(@"Error converting I420 VideoFrame to NV12: %d", result);
        CFRelease(pixelBuffer);
        return NULL;
    }
    
    return pixelBuffer;
}

-(id)init
{
    NSLog(@"init is called.");
    if(self = [super init])
    {
    }
    return self;
}

- (void)dealloc {
//    [_videoGroup release];
//    [_localUserId release];
//    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userList = [NSMutableArray new];
    self.startPush = NO;
   
    [Bugly updateAppVersion:@"外部输入"];
    int sdkNum = [[YMVoiceService getInstance] getSDKVersion];
    [Bugly setUserValue:[NSString stringWithFormat:@"%d",sdkNum] forKey:@"SDKNumber"];
    int main_ver = (sdkNum >> 28) & 0xF;
    int minor_ver = (sdkNum >> 22) & 0x3F;
    int release_number = (sdkNum >> 14) & 0xFF;
    int build_number = sdkNum & 0x00003FFF;
    [Bugly setUserValue:[NSString stringWithFormat:@"video-trunk-%d.%d.%d.%d",main_ver, minor_ver, release_number, build_number] forKey:@"SDKVersion"];
    
    /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
    LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
    videoConfiguration.videoSize = CGSizeMake(MIX_WIDTH, MIX_HEIGHT);
    videoConfiguration.videoBitRate = 800*1024;
    videoConfiguration.videoMaxBitRate = 1000*1024;
    videoConfiguration.videoMinBitRate = 500*1024;
    videoConfiguration.videoFrameRate = 15;
    videoConfiguration.videoMaxKeyframeInterval = 48;
    videoConfiguration.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoConfiguration.autorotate = NO;
    videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
    
    LFLiveAudioConfiguration *audioConfig = [LFLiveAudioConfiguration new];
    audioConfig.audioSampleRate =LFLiveAudioSampleRate_48000Hz;
    audioConfig.numberOfChannels = 1;
    
    _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfig videoConfiguration:videoConfiguration captureType:LFLiveInputMaskAll];
    _session.delegate = self;
    _session.showDebugInfo = NO;
    _session.preView = nil;
    
    //默认参数
    params = [[ParamSetting alloc]init];
    params->videoWidth = 480;
    params->videoHeight = 640;
    params->reportInterval = 5000;
    params->maxBitrate = 0;
    params->minBitrate = 0;
    params->farendLevel = 10;
    params->bHWEnable = true;
    params->bHighAudio = false ;
    params->push = false;
    
    enterdRoom = false;
    
    // 是否允许视频输入
    //mInputVideoEnable = true;
    
    firstFrame = YES;
    record = [[AudioRecordStream alloc] init ];
    _cameraCapture = [[CameraCaptureDemo alloc] init];
    
    //demo外部录音对象
    record.recrodDelegate = self;
    _cameraCapture.cameraDataDelegate = self;
    _cameraCapture.previewParentView = self.view;
    _mFullScreenIndex = -1;
    
    avNotifyTime = 0 ;
    mStrNotify = @"";
    
    //默认测服
    mIsTestServer = false;
    //[[YMVoiceService getInstance]setTestServer:mIsTestServer];
    //========================== 设置为外部输入音视频的模式 =========================================================
    [[YMVoiceService getInstance] setExternalInputMode:true];
    //========================== 设置Log等级 =========================================================
    [[YMVoiceService getInstance] setLogLevelforConsole:LOG_INFO forFile:LOG_INFO];
    //========================== 设置用户自定义Log路径 =========================================================
    //[[YMVoiceService getInstance] setUserLogPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ymrtc_userlog.txt"]];
    //========================== 初始化YoumeService =========================================================
    [[YMVoiceService getInstance] setAVStatisticInterval: 5000 ];
    
    [[YMVoiceService getInstance] initSDK: self appkey:strAppKey
                                appSecret:strAppSecret
                                 regionId:RTC_CN_SERVER
                         serverRegionName:@"cn" ];
    
    // 设置外部输入的采样率为48k
    [[YMVoiceService getInstance] setExternalInputSampleRate: SAMPLE_RATE_48 mixedCallbackSampleRate:SAMPLE_RATE_48];
    // 设置视频无渲染帧超时等待时间，单位毫秒
    [[YMVoiceService getInstance] setVideoNoFrameTimeout: 5000];
    //========================== END初始化YoumeService ==========================================================
    
    //==========================     Demo的简单UI      ==========================================================
    //获取版本号显示到相应标签
    NSString* strTmp = @"ver:";
    NSString* strVersion = [NSString stringWithFormat:@"%d",[[YMVoiceService getInstance] getSDKVersion]];
    _labelVersion.text = [strTmp stringByAppendingString:strVersion];
    
    mTips = @"No tips Now!";
    mChannelID = @"123";
    int value = (arc4random() % 1000) + 1;
    mLocalUserId = [NSString stringWithFormat:@"user_%d",value];
    
    mSpeakerEnable = true;
    mMode = 0;
    mCameraEnable = false;
    
    _tfTips.text = mTips;
    _tfTips.enabled = false;
    _tfRoomID.text = mChannelID;
    _localUserId.text = mLocalUserId;
    
    _tfavTips.text = @"avTips";
    
    _tfTips.text = @"";
    
    _buttonLeaveRoom.enabled = false;
    _buttonSpeaker.enabled = false;

    
    self.mBInRoom = false;
    self.mBInitOK = false;
    
    CGRect r = [ UIScreen mainScreen ].applicationFrame;
    

        
    CGRect tipsRect = self.tfTips.frame;
    self.tfTips.frame = CGRectMake(tipsRect.origin.x, r.size.height - 20, tipsRect.size.width, tipsRect.size.height);
    //==========================     Demo的简单UI      ==========================================================
    
    //==========================      创建渲染组件      ==========================================================
    int renderViewMargin = 5;
    renderMaxWidth =  ( r.size.width - renderViewMargin * 3 ) / 2 ;
    renderMaxHeight = ( r.size.height - renderViewMargin * 3 ) / 3  ;
    
    //最大的框设置成方形的把，方便后面的判断
    renderMaxWidth = renderMaxWidth < renderMaxHeight ? renderMaxWidth : renderMaxHeight;
    renderMaxHeight = renderMaxWidth;
    
    self.videoGroup.layer.borderWidth = 1;
    self.videoGroup.layer.borderColor = [[UIColor blackColor] CGColor];
    
    int videoGroupHeight =  renderMaxHeight * 2  + renderViewMargin * 3 ;
    self.videoGroup.frame = CGRectMake( 0 , r.size.height - videoGroupHeight , r.size.width, videoGroupHeight );
    
    int renderViewHeight = renderMaxWidth;
    int renderViewWidth = renderMaxHeight;
    
    
    self.mGL20View = [[OpenGLView20 alloc] initWithFrame:CGRectMake(renderViewMargin, renderViewMargin, renderViewWidth, renderViewHeight)];
    [self.videoGroup addSubview:self.mGL20View];
    
    self.mGL20View2 = [[OpenGLView20 alloc] initWithFrame:CGRectMake(renderViewWidth + 2* renderViewMargin, renderViewMargin, renderViewWidth, renderViewHeight)];
    [self.videoGroup addSubview:self.mGL20View2];
    
    self.mGL20View3_mix = [[OpenGLView20 alloc] initWithFrame:CGRectMake(renderViewWidth + 2* renderViewMargin , renderViewHeight + 2* renderViewMargin, renderViewWidth, renderViewHeight)];
    
    float widthRate = (float)renderMaxWidth / MIX_WIDTH;
    float heightRate = (float)renderMaxHeight / MIX_HEIGHT;
    float rate = widthRate > heightRate ? heightRate : widthRate;
    
    self.mGL20View3_mix.bounds = CGRectMake(0, 0, MIX_WIDTH * rate, MIX_HEIGHT * rate);

    [self.videoGroup addSubview:self.mGL20View3_mix];
    
    self.mGL20ViewFullScreen =  [[OpenGLView20 alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height)];
    [self.view addSubview:self.mGL20ViewFullScreen];
    self.mGL20ViewFullScreen.hidden = true ;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 反初始化
//    [[YMVoiceService getInstance] unInit];
//    [YMVoiceService destroy];
//    [self onClickButtonLeaveRoom:nil];
}


- (void)refreshUI{
    _buttonLeaveRoom.enabled = false;
    _buttonSpeaker.enabled = false;
    mSpeakerEnable = true;
    mCameraEnable = false;
    [_buttonSpeaker setTitle:@"关闭扬声器" forState:UIControlStateNormal];
}


//主播扬声器模式
-(void)joinAnchorSpeakerMode{
 
    int value = (arc4random() % 1000) + 1;
    //NSString* strTmp = @"Anchor";
    NSString* strValue = [NSString stringWithFormat:@"%d",value];
    NSString* strUserID = _localUserId.text;
    self->mChannelID = _tfRoomID.text;
    mTips = @"正进入主播扬声器模式";
    _tfTips.text = mTips;
    
   
    if( params )
    {
        if( params->videoWidth >= 0 && params->videoHeight >= 0   )
        {
            [[YMVoiceService getInstance] setVideoNetResolutionWidth:params->videoWidth height:params->videoHeight];
        }
        [[YMVoiceService getInstance] setAVStatisticInterval: params->reportInterval];
        [[YMVoiceService getInstance] setVideoCodeBitrate: params->maxBitrate  minBitrate:params->minBitrate];
        
        if( params->bHighAudio ){
            [[YMVoiceService getInstance] setAudioQuality:HIGH_QUALITY];
        }
        else{
            [[YMVoiceService getInstance] setAudioQuality:LOW_QUALITY];
        }
        
        if( params->bHWEnable ){
            [[YMVoiceService getInstance] setVideoHardwareCodeEnable: TRUE ];
        }
        else{
            [[YMVoiceService getInstance] setVideoHardwareCodeEnable: false ];
        }
        
        [[YMVoiceService getInstance] setFarendVoiceLevelCallback: params->farendLevel ];
    }
    
    NSString *str = _tfToken.text;
    [[YMVoiceService getInstance] setToken:str];
    
    [[YMVoiceService getInstance] joinChannelSingleMode:strUserID channelID:mChannelID userRole:YOUME_USER_HOST  joinAppKey:strJoinAppKey];
    enterdRoom = true;
    
}

//主播频道按钮处理函数
- (IBAction)onClickButtonHost:(id)sender {
    mMode = ANCHOR_SPEAKER_MODE;
    
    [[YMEngineService getInstance] setDelegate:self];
    
    [self refreshUI];
    if(self.mBInRoom){
        [[YMVoiceService getInstance] leaveChannelAll];
    }else {
        [self joinAnchorSpeakerMode];
    }
}


//离开房间按钮响应
- (IBAction)onClickButtonLeaveRoom:(id)sender {
    [self onClickButtonStopCamera:nil];
    mMode = NOT_INROOM_MODE;
    [self refreshUI];
    [self stopRecord];
    [[YMVoiceService getInstance] leaveChannelAll];
}


//点击空白屏幕收起编辑键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if( self.mGL20ViewFullScreen.hidden == false )
    {
        _mFullScreenIndex = -1;
        self.mGL20ViewFullScreen.hidden = true;
    }
    else{
        UITouch * touch = touches.anyObject;//获取触摸对象
        CGPoint pt = [touch locationInView: self.mGL20View ];
        if( [self.mGL20View pointInside:pt  withEvent:event ])
        {
            _mFullScreenIndex = 0;
        }
        else
        {
            pt = [touch locationInView: self.mGL20View2 ];
            if ( [self.mGL20View2 pointInside: pt  withEvent:event ])
            {
                _mFullScreenIndex = 1;
            }
        }
        
    }
    [self.view endEditing:YES];
}

//监听初始化完成情况
- (void)handleInitEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode
{
    switch (eventType)
    {
        case YOUME_EVENT_INIT_OK:
            // SDK验证成功
            self.mBInitOK = TRUE;
            mTips = @"SDK验证成功!";
            //设置服务器区域，在请求进入频道前调用生效
            [[YMVoiceService getInstance] setServerRegion:RTC_CN_SERVER regionName:@"" bAppend:false];
            break;
        case YOUME_EVENT_INIT_FAILED:
            //SDK验证失败
            self.mBInitOK = FALSE;
            mTips = @"SDK验证失败!";
            break;
        default:
            break;
    }
    NSLog(mTips);
    //通知主线程刷新
    dispatch_async (dispatch_get_main_queue (), ^{
        [self.tfTips setText:mTips];
    });
}

- (void)onRequestRestAPI: (int)requestID iErrorCode:(YouMeErrorCode_t) iErrorCode  query:(NSString*) strQuery  result:(NSString*) strResult
{
    NSLog(@"do nothing");
}


- (void)onMemberChange:(NSString*) channelID changeList:(NSArray*) changeList isUpdate:(bool) isUpdate
{
    NSLog(@"isUpdate:%d", isUpdate);
    int count = [changeList count];
    NSLog(@"MemberChagne:%@, count:%d",channelID, count );
    
    for( int i = 0 ; i < count ;i++ ){
        MemberChangeOC* change = [changeList objectAtIndex:i ];
        if( change.isJoin == 1 ){
            NSLog(@"%@ 进入", change.userID);
        }
        else{
            NSLog(@"%@ 离开了", change.userID );
        }
    }
    
    NSLog(@"");
    NSLog(@"");
}

//监听会议相关
- (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode  roomid:(NSString *)roomid param:(NSString*)param
{
    NSLog(@"onYouMeEvent: type:%d, err:%d, room:%@,param:%@", eventType, iErrorCode, roomid, param );
    if ((YOUME_EVENT_INIT_OK == eventType) || (YOUME_EVENT_INIT_FAILED == eventType)) {
        [self handleInitEvent:eventType errcode:iErrorCode];
        return;
    }
    
    if(eventType==YOUME_EVENT_JOIN_OK){
        self.mBInRoom = true;
        
        //通知主线程刷新
        dispatch_async (dispatch_get_main_queue (), ^{
            //设置混流画布
            [[YMEngineService getInstance] setMixVideoWidth:MIX_WIDTH Height:MIX_HEIGHT];
            [[YMEngineService getInstance] addMixOverlayVideoUserId: _localUserId.text PosX:0 PosY:0 PosZ:0 Width:MIX_WIDTH Height:MIX_HEIGHT];
            
            _buttonSpeaker.enabled = true;
            _buttonLeaveRoom.enabled = true;
            [[YMVoiceService getInstance] setSpeakerMute:false];
            [self.tfTips setText:mTips];
            
        });
        
        NSLog(mTips);
        
    }else if(eventType==YOUME_EVENT_JOIN_FAILED){
        self.mBInRoom = false;
        NSString* strTmp = @"加入房间失败,errcode:";
        NSString* strErrorCode = [NSString stringWithFormat:@"%d",iErrorCode];
        mTips = [strTmp stringByAppendingString:strErrorCode];
        NSLog(mTips);
        //通知主线程刷新
        dispatch_async (dispatch_get_main_queue (), ^{
            [self.tfTips setText:mTips];
        });
    }else if(eventType==YOUME_EVENT_LEAVED_ALL){
        self.mBInRoom = false;
        switch (mMode) {
            case ANCHOR_SPEAKER_MODE:
            {
                dispatch_async (dispatch_get_main_queue (), ^{
                [self joinAnchorSpeakerMode];
                });
                break;
            }
            case NOT_INROOM_MODE:
            {
                NSString* strTmp = @"已离开房间,errcode:";
                NSString* strErrorCode = [NSString stringWithFormat:@"%d",iErrorCode];
                mTips = [strTmp stringByAppendingString:strErrorCode];
                NSLog(mTips);
                dispatch_async (dispatch_get_main_queue (), ^{
                    [self.tfTips setText:mTips];
                    
                });
                break;
            }
            case CHANGE_SERVER_MODE:
            {
                NSString* strTmp = @"已离开房间,errcode:";
                NSString* strErrorCode = [NSString stringWithFormat:@"%d",iErrorCode];
                mTips = [strTmp stringByAppendingString:strErrorCode];
                NSLog(mTips);
                dispatch_async (dispatch_get_main_queue (), ^{
                    [self.tfTips setText:mTips];
                });
                break;
            }
            default:
                break;
        }
        
        [self stopRecord];
        
    } else if (eventType == YOUME_EVENT_OTHERS_VIDEO_ON) {
         dispatch_async (dispatch_get_main_queue (), ^{
             [[YMVoiceService getInstance] createRender:param];
             
             int posX = 10;
             int posY = 10;
             
             if( mCurMixCount%3 == 1)
             {
                 posX = 110;
             }
             else if( mCurMixCount%3 == 2){
                 posX = 210;
             }
             mCurMixCount++;
             [[YMEngineService getInstance] addMixOverlayVideoUserId: param PosX:posX PosY:posY PosZ:0 Width:90 Height:120];
             [self.userList addObject:param];
         });
        
    }else if ( eventType == YOUME_EVENT_FAREND_VOICE_LEVEL )
    {
        int value =  (int)iErrorCode;
//        NSLog(@"YOUME_EVENT_FAREND_VOICE_LEVEL:%d", value  );
    }else if ( eventType == YOUME_EVENT_OTHERS_VIDEO_INPUT_START )
    {
        int value =  (int)iErrorCode;
        NSLog(@"User:%@ start video input", param  );
    }else if ( eventType == YOUME_EVENT_OTHERS_VIDEO_INPUT_STOP )
    {
        int value =  (int)iErrorCode;
        NSLog(@"User:%@ stop video input", param  );
    }
    else  {
        NSString* strTmp = @"Evt: %d, err:%d, param:%@ ,room:%@ ";

        mTips = [NSString stringWithFormat: strTmp, eventType, iErrorCode, param, roomid ];

        dispatch_async (dispatch_get_main_queue (), ^{
            
            [self.tfTips setText:mTips];
        });
    }
    
}

- (void)onAudioFrameCallback: (NSString*)userId data:(void*) data len:(int)len timestamp:(uint64_t)timestamp {
    //NSLog(@"onAudioFrameCallback is called.");
}

- (void)onAudioFrameMixedCallback: (void*)data len:(int)len timestamp:(uint64_t)timestamp {
//    NSLog(@"onAudioFrameMixedCallback is called.%d",len);
    /*
    NSString *txtPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"objc3.pcm"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:txtPath isDirectory:NO]){
        [fileManager createFileAtPath:txtPath contents:nil attributes:nil];
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:txtPath];
    [handle seekToEndOfFile];
    [handle writeData:[NSData dataWithBytes:data length:len]];
    [handle closeFile];
     */
    // 播放
//    [record play:[NSData dataWithBytes:data length:len]];
    //推流
    if( self.startPush ){
        // Create a CM Sample Buffer
        [self.session pushAudio:[NSData dataWithBytes:data length:len]];
    }
}

//非混流远端数据回调
- (void)onVideoFrameCallback: (NSString*)userId data:(void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp {
//    NSLog(@"onVideoFrameCallback is called.%lld",timestamp);
    
    int index = [self.userList indexOfObject:userId];
    if( index>-1 && index < 2){ //demo只做了两个远端渲染组件
        const char* pTmpBuffer = (const char *)malloc(len);
        memcpy(pTmpBuffer, data, len);
        dispatch_async (dispatch_get_main_queue (), ^{
            if( _mFullScreenIndex == index  )
            {
                if( self.mGL20ViewFullScreen.hidden == true )
                {
                    CGRect r = [ UIScreen mainScreen ].applicationFrame;
                    float widthRate = (float)r.size.width / width;
                    float heightRate = (float)r.size.height / height;
                    float rate = widthRate > heightRate ? heightRate : widthRate;
                    
                    self.mGL20ViewFullScreen.bounds = CGRectMake(0, 0, width * rate, height * rate);
                    self.mGL20ViewFullScreen.hidden = false;
                    _mFullScreenIndex = index;
                }
                [self.mGL20ViewFullScreen displayYUV420pData:pTmpBuffer width:width height:height];
            }
            
            if(index==0){
                if( self.mGL20View.frame.size.width == self.mGL20View.frame.size.height && width != height )
                {
                    float widthRate = (float)renderMaxWidth / width;
                    float heightRate = (float)renderMaxHeight / height;
                    float rate = widthRate > heightRate ? heightRate : widthRate;
                    
                    self.mGL20View.bounds = CGRectMake(0, 0, width * rate, height * rate);
                }

                [self.mGL20View displayYUV420pData:pTmpBuffer width:width height:height];
            }else{
                if( self.mGL20View2.frame.size.width == self.mGL20View2.frame.size.height && width != height )
                {
                    float widthRate = (float)renderMaxWidth / width;
                    float heightRate = (float)renderMaxHeight / height;
                    float rate = widthRate > heightRate ? heightRate : widthRate;
                    
                    self.mGL20View2.bounds = CGRectMake(0, 0, width * rate, height * rate);
                }
                
                [self.mGL20View2 displayYUV420pData:pTmpBuffer width:width height:height];
            }
            free(pTmpBuffer);
        });
    }
    
}

// 混流数据回调，必须要设置了setMixVideoWidth 和 addMixOverlayVideoUserId 才会有这个回调
- (void)onVideoFrameMixedCallback: (void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp {
    //    NSLog(@"onVideoFrameMixedCallback is called,ts:%lld",timestamp);
    
    const char* pTmpBuffer = (const char *)malloc(len);
    memcpy(pTmpBuffer, data, len);
    dispatch_async (dispatch_get_main_queue (), ^{
        [self.mGL20View3_mix displayYUV420pData:pTmpBuffer width:width height:height];
        if(self.startPush){
            CVPixelBufferRef buff = [self i420FrameToPixelBuffer:(const uint8*)pTmpBuffer width:width height:height];
            [self.session pushVideo:buff];
        }
        free(pTmpBuffer);
    });
}

- (void)frameRender:(int) renderId  nWidth:(int) nWidth  nHeight:(int) nHeight  nRotationDegree:(int) nRotationDegree nBufSize:(int) nBufSize buf:(const void *) buf
{
   
}

- (void) onAVStatistic:(YouMeAVStatisticType_t)type  userID:(NSString*)userID  value:(int) value
{
    NSTimeInterval curTime =  [[NSDate date] timeIntervalSince1970]  ;
    
    if( curTime - avNotifyTime > 2  )
    {
        mStrNotify = @"";
    }
    
    mStrNotify = [mStrNotify stringByAppendingFormat:@"%d,%@,%d\n" , type, userID, value ];
    
    avNotifyTime = curTime;
    
    dispatch_async (dispatch_get_main_queue (), ^{
        _tfavTips.text = mStrNotify;

    });
}


- (IBAction)onClickButtonSpeaker:(id)sender {
    if(mSpeakerEnable){
        [[YMVoiceService getInstance]setSpeakerMute:true];
        mSpeakerEnable = false;
        [_buttonSpeaker setTitle:@"启用扬声器" forState:UIControlStateNormal];
    } else {
        //启动麦克风
        [[YMVoiceService getInstance]setSpeakerMute:false];
        mSpeakerEnable = true;
        [_buttonSpeaker setTitle:@"关闭扬声器" forState:UIControlStateNormal];
    }
}

- (IBAction)onClickButtonOpenMic:(id)sender
{
    [self startRecord ];
}
- (IBAction)onClickButtonCloseMic:(id)sender
{
    [self stopRecord];
}

- (IBAction)onClickButtonAddMixing:(id)sender {
    [[YMEngineService getInstance] addMixOverlayVideoUserId: _localUserId.text PosX:0 PosY:0 PosZ:0 Width:MIX_WIDTH Height:MIX_HEIGHT];
}

- (IBAction)onClickButtonRemoveMixing:(id)sender {
    [[YMEngineService getInstance] removeMixOverlayVideoUserId:_localUserId.text];
}

- (IBAction)onClickParam:(id)sender
{
    
}

- (IBAction)onClickButtonAllowInputVideo:(id)sender {
    //mInputVideoEnable = true;
}

- (IBAction)onClickButtonStopInputVideo:(id)sender {
    //mInputVideoEnable = false;
    //[[YMEngineService getInstance] stopInputVideoFrame];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    ParamViewController *paramView  = (ParamViewController *)segue.destinationViewController;//要跳转的vc
    
    paramView->params = params;
    paramView->bInited = enterdRoom;
}

// Camera relate
#define UI_TEXT_HIGHT 20
#define UI_LABLE_LENGTH 100
#define UI_BTN_LENGTH   150
#define UI_BTN_HIGHT    20
#define UI_BTN_GAP      15

- (IBAction)onClickButtonCamera:(id)sender {
    NSLog(@"onClickButtonCamera is called.");
    
    if (!mCameraEnable &&  self.mBInRoom) {
        
        [self createControl];
        [_cameraCapture startVideoCapture];
        
        //[[YMVoiceService getInstance] startCapture];
        mCameraEnable = true;
        if( params->push ){
            //启动推流
            LFLiveStreamInfo *streamInfo = [LFLiveStreamInfo new];
            streamInfo.url = PUSH_ADDRESS;
            [self.session startLive:streamInfo];
            self.startPush = YES;
        }
    }
}

- (IBAction)onClickButtonStopCamera:(id)sender {
    NSLog(@"onClickButtonCamera is called.");
    if (mCameraEnable) {
        if( params->push || self.startPush ){
            [self.session stopLive];
            self.startPush = NO;
        }
        mCameraEnable= false;
        [self stopVideoCapture];
        [[YMEngineService getInstance] stopInputVideoFrame];
    }
}

#pragma mark -
#pragma mark createControl
- (void)createControl
{
    NSLog(@"createControl is called.");
    [self init];
    NSLog(@"createControl is called.----2");
   
    CGPoint origin = self.view.bounds.origin;
    CGSize  size   = self.view.bounds.size;
    
    // Lable: 透明背景色，白色字体，字体大小为10号
    labelState = [[UILabel alloc] initWithFrame:CGRectMake(origin.x, origin.y + UI_TEXT_HIGHT, UI_LABLE_LENGTH, UI_TEXT_HIGHT)];
    [labelState setTag:10001];
    labelState.backgroundColor = [UIColor clearColor];
    [labelState setTextColor:[UIColor redColor]];
    [labelState setFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:labelState];
//    [labelState release];
    
}

- (void)stopVideoCapture
{
    [_cameraCapture stopVideoCapture];
    //移除localView里面的内容
    for (UIView *view in [self.view subviews]) {
        if ((view.tag == 10001) || (view.tag == 10002) || (view.tag == 10003) || (view.tag == 10004) || (view.tag == 10005) || (view.tag == 10006)) {
            [view removeFromSuperview];
        }
    }
    mCameraEnable = false;
}

- (void) startRecord
{
    if( m_InRecord == false ){
        m_InRecord = true;
        [ record Start];
    }
}

-  (void) stopRecord
{
    if( m_InRecord == true ){
        [ record Stop];
        m_InRecord = false;
    }
}

- (void) OnRecordData:(AudioBufferList *)recordBuffer
{
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
    AudioBuffer buffer = recordBuffer->mBuffers[0];
    [[YMEngineService getInstance] inputAudioFrame:buffer.mData Len:buffer.mDataByteSize Timestamp:recordTime ];
}

- (void) OnCameraCaptureData:(void*) buffer Len:(int)bufferSize Width:(int)width Height:(int)height Fmt:(int)Fmt Rotation:(int)rotationDegree Mirror:(int)mirror Timestamp:(uint64_t)recordTime{
    //if (mInputVideoEnable) {
        [[YMEngineService getInstance] inputVideoFrame:buffer Len:bufferSize Width:width Height:height Fmt:Fmt Rotation:rotationDegree Mirror:mirror Timestamp:recordTime];
    //}
}

@end
