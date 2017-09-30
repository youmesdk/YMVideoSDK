#import "AudioQueuePlay.h"


void checkStatus(int code){
    
}

@interface AudioRecordStream(){
    AudioComponentInstance audioUnit;
    int kInputBus;
    int kOutputBus;
//    NSMutableData* audioBuffer;
    NSCondition *mAudioLock;
    int mDataLen;
    void *mPCMData;
}
@end


@implementation AudioRecordStream

- (id) init {
    self = [super init];
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    if (audioSession) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setMode:AVAudioSessionModeVoiceChat error:nil];
    }
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    kInputBus = 1;
    kOutputBus = 0;
    mDataLen=0;
    
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    //desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    // Enable IO for playback
    UInt32 zero = 1;// 设置为0 关闭playback
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &zero,
                                  sizeof(zero));
    checkStatus(status);
    
    
    //TODO  声音是8k采样率，16bit，单声道，pcm的
    // Describe format
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate          = 48000.00;
    audioFormat.mFormatID            = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags         = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved;
    audioFormat.mFramesPerPacket     = 1;
    audioFormat.mChannelsPerFrame    = 1;
    audioFormat.mBitsPerChannel      = 16;
    audioFormat.mBytesPerPacket      = (audioFormat.mBitsPerChannel / 8) * audioFormat.mChannelsPerFrame;
    audioFormat.mBytesPerFrame       = audioFormat.mBytesPerPacket;
    
    // Apply format
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    // Set output callback
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
//    flag = 0;
//    status = AudioUnitSetProperty(audioUnit,
//                                  kAudioUnitProperty_ShouldAllocateBuffer,
//                                  kAudioUnitScope_Output,
//                                  kInputBus,
//                                  &flag,
//                                  sizeof(flag));
//    checkStatus(status);
    
    
    // Initialise
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
    
//    audioBuffer = [[NSMutableData alloc]init];
    mPCMData = malloc(MAX_BUFFER_SIZE);
    mAudioLock = [[NSCondition alloc]init];
    
    return self;
}

-(AudioComponentInstance) audioUnit{
    return audioUnit;
}

-(void *)audioBuffer{
    return mPCMData;
}

-(void)processAudio:(AudioBufferList *)bufferList{
    if( self.recrodDelegate != NULL ){
        [self.recrodDelegate OnRecordData: bufferList ];
        
    }
}

-(void)play:(NSData *)data{
    if(mPCMData == NULL){
        return;
    }
    [mAudioLock lock];
    int len = (int)[data length];
    if (len > 0 && len + mDataLen < MAX_BUFFER_SIZE) {
//        memcpy(mPCMData+mDataLen,[data bytes],len);
        [data getBytes:mPCMData+mDataLen length:len];
        mDataLen += len;
    }
    [mAudioLock unlock];
}

-(void)Start{
    AudioOutputUnitStart(audioUnit);
}

-(void)Stop{
    AudioOutputUnitStop(audioUnit);
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    // Because of the way our audio format (setup below) is chosen:
    // we only need 1 buffer, since it is mono
    // Samples are 16 bits = 2 bytes.
    // 1 frame includes only 1 sample
    AudioRecordStream *ars = (__bridge AudioRecordStream*)inRefCon;
    
    AudioBuffer buffer;
    
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumberFrames * 2;
    buffer.mData = NULL;
    
    // Put buffer in a AudioBufferList
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    // Then:
    // Obtain recorded samples
    
    OSStatus status;
    
    status = AudioUnitRender([ars audioUnit],
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &bufferList);
    checkStatus(status);
    
    // Now, we have the samples we just read sitting in buffers in bufferList
    // Process the new data
    [ars processAudio:&bufferList];
    
    // release the malloc'ed data in the buffer we created earlier
//    free(bufferList.mBuffers[0].mData);
    
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
                                AudioUnitRenderActionFlags *ioActionFlags,
                                const AudioTimeStamp *inTimeStamp,
                                UInt32 inBusNumber,
                                UInt32 inNumberFrames,
                                AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    AudioRecordStream *ars = (__bridge AudioRecordStream*)inRefCon;
    
    for (int i=0; i < ioData->mNumberBuffers; i++) { // in practice we will only ever have 1 buffer, since audio format is mono
        AudioBuffer buffer = ioData->mBuffers[i];
//        NSLog(@"buffer.mDataByteSize %d",buffer.mDataByteSize);
        BOOL isFull = NO;
        [ars->mAudioLock lock];
        if( ars->mDataLen >=  buffer.mDataByteSize)
        {
            memcpy(buffer.mData,  ars->mPCMData, buffer.mDataByteSize);
            ars->mDataLen -= buffer.mDataByteSize;
            memmove( ars->mPCMData,  ars->mPCMData+buffer.mDataByteSize, ars->mDataLen);
            isFull = YES;
        }
        [ ars->mAudioLock unlock];
        if (!isFull) {
            memset(buffer.mData, 0, buffer.mDataByteSize);
        }
    }
    
    return noErr;
}

@end
