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


#import "ParamViewController.h"

@implementation  ParamSetting



@end

@interface ViewController () <ICameraRecordDelegate>
// OpenGL ES
@property (nonatomic , strong)  OpenGLView20* mGL20View;

@property (nonatomic , strong)  OpenGLView20* mGL20View2;
@property (nonatomic , strong)  OpenGLView20* mGL20View3_mix;
@property (atomic,strong) NSMutableArray *userList;
@property (retain, nonatomic) IBOutlet UIView *videoGroup;
@property (retain, nonatomic) CameraCaptureDemo  *cameraCapture;

@end

@implementation ViewController

@synthesize labelState;

NSString* strAppKey = @"YOUME5BE427937AF216E88E0F84C0EF148BD29B691556";
NSString* strAppSecret = @"y1sepDnrmgatu/G8rx1nIKglCclvuA5tAvC0vXwlfZKOvPZfaUYOTkfAdUUtbziW8Z4HrsgpJtmV/RqhacllbXD3abvuXIBlrknqP+Bith9OHazsC1X96b3Inii6J7Und0/KaGf3xEzWx/t1E1SbdrbmBJ01D1mwn50O/9V0820BAAE=";

//2 主播扬声器没模式,5 离开房间,6 切换服务器
const int ANCHOR_SPEAKER_MODE = 2;
const int NOT_INROOM_MODE = 5;
const int CHANGE_SERVER_MODE = 6;

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

    
    //默认参数
    params = [[ParamSetting alloc]init];
    params->videoWidth = 240;
    params->videoHeight = 320;
    params->reportInterval = 5000;
    params->bitRate = 300;
    params->farendLevel = 10;
    params->bHWEnable = true;
    params->bHighAudio = true ;
    
    enterdRoom = false;
    
    // 是否允许视频输入
    mInputVideoEnable = true;
    
    firstFrame = YES;
    record = [[AudioRecordStream alloc] init ];
    _cameraCapture = [[CameraCaptureDemo alloc] init];
    
    //demo外部录音对象
    record.recrodDelegate = self;
    _cameraCapture.cameraDataDelegate = self;
    _cameraCapture.previewParentView = self.view;
    
    avNotifyTime = 0 ;
    mStrNotify = @"";
    
    //默认测服
    mIsTestServer = false;
    //[[YMVoiceService getInstance]setTestServer:true];
    
    //========================== 初始化YoumeService =========================================================
    [[YMVoiceService getInstance] setAVStatisticInterval: 5000 ];
    
    [[YMVoiceService getInstance] initSDK: self appkey:strAppKey
                                appSecret:strAppSecret
                                 regionId:RTC_CN_SERVER
                         serverRegionName:@"cn" ];
    // 设置外部输入的采样率为48k
    [[YMVoiceService getInstance] setSampleRate: SAMPLE_RATE_48 ];
    //========================== END初始化YoumeService ==========================================================
    
    //==========================     Demo的简单UI      ==========================================================
    //获取版本号显示到相应标签
    NSString* strTmp = @"ver:";
    NSString* strVersion = [NSString stringWithFormat:@"%d",[[YMVoiceService getInstance] getSDKVersion]];
    _labelVersion.text = [strTmp stringByAppendingString:strVersion];
    
    mTips = @"No tips Now!";
    mChannelID = @"709";
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
    
    self.videoGroup.layer.borderWidth = 1;
    self.videoGroup.layer.borderColor = [[UIColor blackColor] CGColor];
    self.videoGroup.frame = CGRectMake(5, self.videoGroup.frame.origin.y, r.size.width - 10, self.videoGroup.frame.size.height);
        
    CGRect tipsRect = self.tfTips.frame;
    self.tfTips.frame = CGRectMake(tipsRect.origin.x, r.size.height - 20, tipsRect.size.width, tipsRect.size.height);
    //==========================     Demo的简单UI      ==========================================================
    
    //==========================      创建渲染组件      ==========================================================
    int renderViewHeight = 80;
    int renderViewWidth = 80;
    int renderViewMargin = 5;
    
    self.mGL20View = [[OpenGLView20 alloc] initWithFrame:CGRectMake(renderViewMargin, renderViewMargin, renderViewWidth, renderViewHeight)];
    [self.videoGroup addSubview:self.mGL20View];
    
    self.mGL20View2 = [[OpenGLView20 alloc] initWithFrame:CGRectMake(renderViewWidth + 2* renderViewMargin, renderViewMargin, renderViewWidth, renderViewHeight)];
    [self.videoGroup addSubview:self.mGL20View2];
    
    self.mGL20View3_mix = [[OpenGLView20 alloc] initWithFrame:CGRectMake(2 * renderViewWidth + 3 * renderViewMargin, renderViewMargin, renderViewWidth, renderViewHeight)];
    [self.videoGroup addSubview:self.mGL20View3_mix];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // 反初始化
    [[YMVoiceService getInstance] unInit];
    [YMVoiceService destroy];
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
        [[YMVoiceService getInstance] setVideoCodeBitrate: params->bitRate];
        
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
    
    
    [[YMVoiceService getInstance] joinChannelSingleMode:strUserID channelID:mChannelID userRole:YOUME_USER_HOST];
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
    [self.view endEditing:YES];
}

//监听初始化完成情况
- (void)handleInitEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode
{
    switch (eventType)
    {
        case YOUME_EVENT_INIT_OK:
            // TODO 设置日志级别，会被服务器下发的配置覆盖
            [[YMVoiceService getInstance] setLogLevel: LOG_INFO ];
            
            [[YMVoiceService getInstance] setVideoCodeBitrate: 300 ];
            [[YMVoiceService getInstance] setVideoHardwareCodeEnable: true ];

            // SDK验证成功
            self.mBInitOK = TRUE;
            mTips = @"SDK验证成功!";
            //设置服务器区域，在请求进入频道前调用生效
            [[YMVoiceService getInstance] setServerRegion:(int)RTC_CN_SERVER regionName:@"" bAppend:false];
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
            [[YMEngineService getInstance] setMixVideoWidth:320 Height:480];
            [[YMEngineService getInstance] addMixOverlayVideoUserId: _localUserId.text PosX:0 PosY:0 PosZ:0 Width:320 Height:480];
            
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
             [[YMEngineService getInstance] addMixOverlayVideoUserId: param PosX:10 PosY:10 PosZ:0 Width:80 Height:120];
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
        NSString* strTmp = @"SDK回调 errcode:";
        NSString* strErrorCode = [NSString stringWithFormat:@"%d",iErrorCode];
        mTips = [strTmp stringByAppendingString:strErrorCode];
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
//    [record play:[NSData dataWithBytes:data length:len]];
}

//非混流远端数据回调
- (void)onVideoFrameCallback: (NSString*)userId data:(void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp {
//    NSLog(@"onVideoFrameCallback is called.%lld",timestamp);
    int index = [self.userList indexOfObject:userId];
    if( index>-1 && index < 2){ //demo只做了两个远端渲染组件
        const char* pTmpBuffer = malloc(len);
        memcpy(pTmpBuffer, data, len);
        dispatch_async (dispatch_get_main_queue (), ^{
            if(index==0){
                [self.mGL20View displayYUV420pData:pTmpBuffer width:width height:height];
            }else{
                [self.mGL20View2 displayYUV420pData:pTmpBuffer width:width height:height];
            }
            free(pTmpBuffer);
        });
    }
}

// 混流数据回调，必须要设置了setMixVideoWidth 和 addMixOverlayVideoUserId 才会有这个回调
- (void)onVideoFrameMixedCallback: (void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp {
    //    NSLog(@"onVideoFrameMixedCallback is called,ts:%lld",timestamp);
    const char* pTmpBuffer = malloc(len);
    memcpy(pTmpBuffer, data, len);
    dispatch_async (dispatch_get_main_queue (), ^{
        [self.mGL20View3_mix displayYUV420pData:pTmpBuffer width:width height:height];
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
    [[YMEngineService getInstance] addMixOverlayVideoUserId: _localUserId.text PosX:0 PosY:0 PosZ:0 Width:320 Height:480];
}

- (IBAction)onClickButtonRemoveMixing:(id)sender {
    [[YMEngineService getInstance] removeMixOverlayVideoUserId:_localUserId.text];
}

- (IBAction)onClickParam:(id)sender
{
    
}

- (IBAction)onClickButtonAllowInputVideo:(id)sender {
    mInputVideoEnable = true;
}

- (IBAction)onClickButtonStopInputVideo:(id)sender {
    mInputVideoEnable = false;
    [[YMEngineService getInstance] stopInputVideoFrame];
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
    }
}

- (IBAction)onClickButtonStopCamera:(id)sender {
    NSLog(@"onClickButtonCamera is called.");
    if (mCameraEnable) {
        mCameraEnable= false;
        [self stopVideoCapture];
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
    if (mInputVideoEnable) {
        [[YMEngineService getInstance] inputVideoFrame:buffer Len:bufferSize Width:width Height:height Fmt:Fmt Rotation:rotationDegree Mirror:mirror Timestamp:recordTime];
    }
}


@end
