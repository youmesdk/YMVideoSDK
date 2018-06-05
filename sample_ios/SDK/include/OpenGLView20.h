//
//  OpenGLView20.h
//  MyTest
//
//  Created by smy  on 12/20/11.
//  Copyright (c) 2011 ZY.SYM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#include <sys/time.h>

typedef NS_ENUM(NSInteger, GLVideoRenderMode) {
    GLVideoRenderModeHidden = 1,
    GLVideoRenderModeFit = 2,
    GLVideoRenderModeAdaptive = 3
};


@interface OpenGLView20 : UIView

#pragma mark - 接口
- (void)displayYUV420pData:(void *)data width:(NSInteger)w height:(NSInteger)h;
- (void)setVideoSize:(GLuint)width height:(GLuint)height;
- (void)setRenderMode:(GLVideoRenderMode)mode;
/** 
 清除画面
 */
- (void)clearFrame;

@end
