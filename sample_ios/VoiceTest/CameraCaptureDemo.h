//
//  CameraCaptureDemo.h
//  YmTalkTest
//
//  Created by 余俊澎 on 2017/8/29.
//  Copyright © 2017年 Youme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

// 摄像头数据回调
@protocol ICameraRecordDelegate <NSObject>
- (void) OnCameraCaptureData:(void*) buffer Len:(int)bufferSize Width:(int)width Height:(int)height Fmt:(int)Fmt Rotation:(int)rotationDegree Mirror:(int)mirror Timestamp:(uint64_t)recordTime;
@end

@interface CameraCaptureDemo : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>{
    AVCaptureDevice *avCaptureDevice;
    int producerFps;
    int cameraPosition; //摄像头
}

@property (nonatomic,weak) id<ICameraRecordDelegate> cameraDataDelegate;
@property (nonatomic,retain) UIView*  previewParentView;
@property (nonatomic, retain) AVCaptureSession *avCaptureSession;

- (void)startVideoCapture;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
- (void)stopVideoCapture;

@end
