#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaToolbox/MediaToolbox.h>

#define QUEUE_BUFFER_SIZE 4   //队列缓冲个数
#define AUDIO_BUFFER_SIZE 372 //数据区大小
#define MAX_BUFFER_SIZE 102400 //
#define AUDIO_FRAME_SIZE 372

//ios 录音回调
@protocol IAudioRecordDelegate <NSObject>
- (void) OnRecordData:(AudioBufferList*)recordBuffer;
@end

@interface AudioRecordStream : NSObject

@property (nonatomic, assign) id<IAudioRecordDelegate> recrodDelegate;

-(void)Start;
-(void)Stop;
-(void)play:(NSData *)data;

@end 
