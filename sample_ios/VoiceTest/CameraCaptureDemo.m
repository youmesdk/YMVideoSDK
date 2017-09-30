//
//  CameraCaptureDemo.m
//  YmTalkTest
//
//  Created by 余俊澎 on 2017/8/29.
//  Copyright © 2017年 Youme. All rights reserved.
//

#import "CameraCaptureDemo.h"

@implementation CameraCaptureDemo
{
    char * _brgaBuffer;
}

-(id)init{
    producerFps = 15;
    cameraPosition = 1;
    _brgaBuffer = malloc(1080*1920*4);
    return self;
    
}

- (AVCaptureDevice *)getCamera:(AVCaptureDevicePosition)position
{
    //获取前置摄像头设备
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == position)
            return device;
    }
    return nil;
    
}

- (void)startVideoCapture{
    // create session
    self.avCaptureSession = [[AVCaptureSession alloc] init];
    
    // get available camera
    if((self->avCaptureDevice = [self getCamera:AVCaptureDevicePositionFront]) == nil)
    {
        NSLog(@"Failed to get valide capture device");
        return;
    }
    
    // create capture input with camera
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput)
    {
        NSLog(@"Failed to get video input");
        self->avCaptureDevice = nil;
        return;
    }
    
    // create video output
    dispatch_queue_t videoDataQueue = dispatch_queue_create("video capture queue", DISPATCH_QUEUE_SERIAL);
    if(!videoDataQueue) {
        NSLog(@"Failed to create queue");
        return;
    }
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    if(!videoOutput){
        NSLog(@"Failed to create video output");
        return;
    }
    
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    videoOutput.minFrameDuration = CMTimeMake(1, self->producerFps);
    
    [videoOutput setSampleBufferDelegate:self queue:videoDataQueue];
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.avCaptureSession];
    previewLayer.frame = CGRectMake(_previewParentView.bounds.origin.x, _previewParentView.bounds.size.height - 120, 90, 120);
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    NSLog(@"L:%d %s() is called.", __LINE__, __FUNCTION__);
    
    [_previewParentView.layer addSublayer:previewLayer];
    
    NSLog(@"L:%d %s() is called.", __LINE__, __FUNCTION__);
    
    [self.avCaptureSession beginConfiguration];
    //self.avCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
    self.avCaptureSession.sessionPreset =  AVCaptureSessionPreset1280x720;
    if([self.avCaptureSession canAddInput:videoInput]) {
        [self.avCaptureSession addInput:videoInput];
    } else {
       NSLog(@"Failed to add video input");
    }
    
    if([self.avCaptureSession canAddOutput:videoOutput]){
        [self.avCaptureSession addOutput:videoOutput];
    } else {
        NSLog(@"Failed to add video output");
    }
    
    [self.avCaptureSession commitConfiguration];
    
    
    AVCaptureConnection * dataOutputConnection = [ videoOutput connectionWithMediaType:AVMediaTypeVideo ];
    if( [dataOutputConnection isVideoOrientationSupported ])
    {
        dataOutputConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
//    self->firstFrame = YES;
    [self.avCaptureSession startRunning];
    NSLog(@"L:%d %s() is called.", __LINE__, __FUNCTION__);
    
    NSLog(@"Video capture started");
}

- (void)stopVideoCapture
{
    //停止摄像头捕抓
    if(self.avCaptureSession){
        [self.avCaptureSession stopRunning];
        self.avCaptureSession = nil;
        NSLog(@"Video capture stopped");
    }
    self->avCaptureDevice = nil;
}



- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    const int kFlags = 0;
    //捕捉数据输出 要怎么处理虽你便
    CVPixelBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the buffer*/
    if(CVPixelBufferLockBaseAddress(videoFrame, kFlags) != kCVReturnSuccess) {
        NSLog(@"lock data failed.");
        return;
    }
    
    uint8_t* baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(videoFrame);
    size_t bufferSize = CVPixelBufferGetDataSize(videoFrame);
    size_t width = CVPixelBufferGetWidth(videoFrame);
    size_t height = CVPixelBufferGetHeight(videoFrame);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(videoFrame);
    //        size_t bytesPerPixel = bytesPerRow/width;
    int pixelFormat = CVPixelBufferGetPixelFormatType(videoFrame);
    
    switch (pixelFormat) {
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            //NSLog(@"Capture pixel format=420v");
            break;
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            //NSLog(@"Capture pixel format=420f");
            break;
        case kCVPixelFormatType_32BGRA:
            //NSLog(@"Capture pixel format=BGRA");
            // transfer the 32BGRA -> YUV420P
            break;
        default:
            NSLog(@"Capture pixel format=others(0x%x)", pixelFormat);
            break;
    }
    
    int rotationDegree = 0;
    int mirror = 0;
    
    //        rotationDegree = (360 + rotationDegree - screenOrientation)%360;
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    char* buffer;
    if(bytesPerRow != width*4)
    {
        buffer = _brgaBuffer;
        for (int i = 0; i < height; i++) {
            memcpy(&buffer[i*width*4], &baseAddress[i*bytesPerRow], width*4);
        }
    }
    else{
        buffer = baseAddress;
    }

    
    [self.cameraDataDelegate OnCameraCaptureData:buffer Len:bufferSize Width:width Height:height Fmt:3 Rotation:rotationDegree Mirror:mirror Timestamp:recordTime];
//    [[YMEngineService getInstance] inputVideoFrame:baseAddress Len:(int)(bufferSize) Width:(int)width Height:(int)height Fmt:3 Rotation:rotationDegree Timestamp:recordTime];
    
    /*We unlock the buffer*/
    CVPixelBufferUnlockBaseAddress(videoFrame, kFlags);
    //NSLog(@"video data:addr:0x%x size:%d w:%d h:%d d:%d bpp:%d bpr:%d fmt:%x",
    //      baseAddress, bufferSize, width, height, rotationDegree, bytesPerPixel, bytesPerRow, pixelFormat);
}
@end
