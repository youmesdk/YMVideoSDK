//
//  ViewController.h
//  VoiceTest
//
//  Created by kilo on 16/7/12.
//  Copyright © 2016年 kilo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceEngineCallback.h"
#import <YMFrameCallback.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraCaptureDemo.h"
#import "AudioQueuePlay.h"

@interface ParamSetting : NSObject {
@public
    int videoWidth;
    int videoHeight;
    int reportInterval;
    int bitRate;
    int farendLevel;
    bool bHWEnable;
    bool bHighAudio;
    bool push;
    
}
@end

@interface ViewController : UIViewController<VoiceEngineCallback, YMFrameCallback, IAudioRecordDelegate >
{
    NSString *mChannelID;
    NSString *mLocalUserId;
    NSString *mTips;
    bool mSpeakerEnable;
    int mMode;
    bool mIsTestServer;
    bool mCameraEnable;
    bool m_InRecord;
    bool mInputVideoEnable;
    
    //UI
    UILabel *labelState;
    UIButton *btnStartVideo;
    UIButton *btnSwitchVideo;
    UIButton *btnStopVideo;
    UIView  *localView;
    UIImageView  *localSubView;
    

    
    BOOL firstFrame;	//是否为第一帧
    
    NSTimeInterval avNotifyTime;
    NSString * mStrNotify;
    
    
    AudioRecordStream* record;
    
    BOOL  enterdRoom;
    
    int renderMaxWidth;
    int renderMaxHeight;
    
@public
    ParamSetting* params;
}

- (void)handleInitEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode;
- (void)onYouMeEvent:(YouMeEvent_t)eventType errcode:(YouMeErrorCode_t)iErrorCode channelid:(NSString *)channelid param:(NSString*)param;

- (void)onAudioFrameCallback: (NSString*)userId data:(void*) data len:(int)len timestamp:(uint64_t)timestamp;
- (void)onAudioFrameMixedCallback: (void*)data len:(int)len timestamp:(uint64_t)timestamp;
- (void)onVideoFrameCallback: (NSString*)userId data:(void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp;
- (void)onVideoFrameMixedCallback: (void*) data len:(int)len width:(int)width height:(int)height fmt:(int)fmt timestamp:(uint64_t)timestamp;

- (void)frameRender:(int) renderId  nWidth:(int) nWidth  nHeight:(int) nHeight  nRotationDegree:(int) nRotationDegree nBufSize:(int) nBufSize buf:(const void *) buf ;


- (void) OnRecordData:(AudioQueueBufferRef)recordBuffer;

@property (weak, nonatomic) IBOutlet UIButton *buttonSpeaker;

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UITextField *tfRoomID;
@property (weak, nonatomic) IBOutlet UITextField *tfToken;

@property (weak, nonatomic) IBOutlet UITextField *tfTips;

@property (weak, nonatomic) IBOutlet UILabel *tfavTips;

@property (weak, nonatomic) IBOutlet UIButton *buttonAnchorSpeaker;

@property (weak, nonatomic) IBOutlet UIButton *buttonLeaveRoom;

@property (weak, nonatomic) IBOutlet UILabel *labelDelay;

@property (retain, nonatomic) IBOutlet UITextField *localUserId;

@property (weak, nonatomic) IBOutlet   UIView  *videoResolutionView;

- (IBAction)onClickButtonSpeaker:(id)sender;

- (IBAction)onClickButtonHost:(id)sender;

- (IBAction)onClickButtonLeaveRoom:(id)sender;



- (IBAction)onClickSwitchServer:(id)sender;

- (IBAction)onClickButtonOpenVideoEncoder:(id)sender;

- (IBAction)onClickButtonOpenMic:(id)sender;
- (IBAction)onClickButtonCloseMic:(id)sender;
- (IBAction)onClickButtonAddMixing:(id)sender;
- (IBAction)onClickButtonRemoveMixing:(id)sender;

- (IBAction)onClickParam:(id)sender;

- (IBAction)onClickButtonAllowInputVideo:(id)sender;
- (IBAction)onClickButtonStopInputVideo:(id)sender;

@property (atomic, assign) BOOL mBInitOK;
@property (atomic, assign) BOOL mBInRoom;

@property (nonatomic, retain) UILabel *labelState;
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;

- (void)createControl;
- (AVCaptureDevice *)getFrontCamera;
- (void)startVideoCapture;
- (void)stopVideoCapture:(id)arg;

- (void) startRecord;
-  (void) stopRecord;


@end


