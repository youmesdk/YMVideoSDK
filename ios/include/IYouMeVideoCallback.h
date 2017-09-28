//
//  IYouMeVideoCallback.h
//  youme_voice_engine
//
//  Created by fire on 2017/3/27.
//  Copyright © 2017年 Youme. All rights reserved.
//

#ifndef IYouMeFrameCallback_h
#define IYouMeFrameCallback_h

#include <string>
#include "YouMeConstDefine.h"

class IYouMeVideoCallback
{
public:
    virtual void frameRender(int renderId, int nWidth, int nHeight, int nRotationDegree, int nBufSize, const void * buf) = 0;
};

class IYouMeVideoFrameCallback {
public:
    virtual void onVideoFrameCallback(std::string userId, void * data, int len, int width, int height, int fmt, uint64_t timestamp) = 0;
    virtual void onVideoFrameMixedCallback(void * data, int len, int width, int height, int fmt, uint64_t timestamp) = 0;
};

class IYouMeAudioFrameCallback {
public:
    virtual void onAudioFrameCallback(std::string userId, void* data, int len, uint64_t timestamp) = 0;
    virtual void onAudioFrameMixedCallback(void* data, int len, uint64_t timestamp) = 0;
};

class IYouMeAVStatisticCallback
{
public:
    virtual void onAVStatistic( YouMeAVStatisticType type,  const char* userID,  int value ) = 0 ;
};


#endif /* IYouMeFrameCallback_h */
