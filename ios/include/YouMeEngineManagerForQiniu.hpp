//
//  YouMeEngineManagerForQiniu.hpp
//  youme_voice_engine
//
//  Created by mac on 2017/8/4.
//  Copyright © 2017年 Youme. All rights reserved.
//

#ifndef YouMeEngineManagerForQiniu_hpp
#define YouMeEngineManagerForQiniu_hpp

#include <thread>
#include <deque>
#include <mutex>
#include <XCondWait.h>
#include <YouMeCommon/CrossPlatformDefine/PlatformDef.h>
#include "IYouMeVideoCallback.h"
#include "ICameraManager.hpp"

class Frame {
    
public:
    Frame(int width, int height, int format);
    Frame(void* data, int len, int width, int height, int format, uint64_t timestamp);
    virtual ~Frame();
    void resize(int width, int height);
    void erase();

public:
    int width;
    int height;
    void* data;
    int len;
    int format;
    uint64_t timestamp;
};

class AudioTrack {
    
public:
    AudioTrack(int size);
    AudioTrack(void* data, int size, int samplerate, int channels, uint64_t timestamp);
    AudioTrack(int size, int samplerate, int channels, uint64_t timestamp);
    virtual ~AudioTrack();

public:
    int samplerate;
    int channels;
    void* data;
    int size;
    uint64_t timestamp;
};

class AudioFifo {
    
public:
    AudioFifo(std::string userId, int samplerate, int channels);
    virtual ~AudioFifo();
    
    int write(void* data, int size);
    int read(void* data, int size);
    int getBlankSize();
    int getDataSize();

public:
    std::string userId;
    int samplerate;
    int channels;
    void* data;
    int size;
    int rp;
    int wp;
    
    std::recursive_mutex mutex;
};

class MixingInfo {
    
public:
    MixingInfo(std::string userId, int x, int y, int z, int width, int height);
    virtual ~MixingInfo();
    
    //重载<
    bool operator<(const MixingInfo&);
    
    void pushFrame(std::shared_ptr<Frame> frame);
    std::shared_ptr<Frame> popFrame();
    std::shared_ptr<Frame> popFrame(uint64_t timestamp, long delta);

public:
    std::string userId;
    int x;
    int y;
    int z;
    int width;
    int height;
    
    // 表示是否为参考视频
    bool isMainVideo;
    
    std::recursive_mutex frameListMutex;
    std::list<std::shared_ptr<Frame>> frameList;
    std::shared_ptr<Frame> freezedFrame;
};

class YouMeEngineManagerForQiniu {
    
private:
    std::thread m_thread;
    bool m_isLooping = false;
    youmecommon::CXCondWait condWait;
    
    std::deque<Frame*> m_msgQueue;
    std::mutex m_msgQueueMutex;
    std::condition_variable m_msgQueueCond;
    
    std::list<std::shared_ptr<MixingInfo>> mixingInfoList;
    Frame* mMixedFrame;
    IYouMeVideoCallback *mYouMeVideoCallback = NULL;
    youmecommon::CXCondWait mixing_condWait;
    IYouMeVideoFrameCallback* videoFrameCallback;
    IYouMeAudioFrameCallback* audioFrameCallback;
    
    // Audio mixing thread
    std::thread m_thread_audio_mixing;
    bool m_isLooping_audio_mixing = false;
    youmecommon::CXCondWait condWait_audio_mixing;
    std::deque<AudioTrack*> m_msgQueue_audio_mixing;
    std::mutex m_msgQueueMutex_audio_mixing;
    std::condition_variable m_msgQueueCond_audio_mixing;
    
    std::list<std::shared_ptr<AudioFifo>> audioFifoList;
    std::recursive_mutex audioFifoListMutex;
    
private:
    YouMeEngineManagerForQiniu();
    virtual ~YouMeEngineManagerForQiniu();
    void startThread();
    void stopThread();
    void threadFunc();
    void ClearMessageQueue();
    
    // Audio mixing thread related
    void startAudioMixingThread();
    void stopAudioMixingThread();
    void audioMixingThreadFunc();
    void ClearAudioMixingMessageQueue();
    
    void mixVideo(Frame* src, int x, int y, int width, int height);
    std::shared_ptr<MixingInfo> getMixingInfo(std::string userId);
    std::shared_ptr<AudioTrack> mixAudio(std::list<std::shared_ptr<AudioTrack>> audioTrackList);
    
public:
    static YouMeEngineManagerForQiniu* getInstance(void);
    void frameRender(std::string userId, int nWidth, int nHeight, int nRotationDegree, int nBufSize, const void * buf, uint64_t timestamp);
    void onVideoFrameCallback(std::string userId, const void * data, int len, int width, int height, int fmt, uint64_t timestamp);
    void onVideoFrameMixedCallback(const void * data, int len, int width, int height, int fmt, uint64_t timestamp);
    void onAudioFrameCallback(std::string userId, void* data, int len, uint64_t timestamp);
    void onAudioFrameMixedCallback(void* data, int len, uint64_t timestamp);
    
    void setYouMeVideoCallback(IYouMeVideoCallback* cb);
    int  setMixVideoSize(int width, int height);
    int  addMixOverlayVideo(std::string userId, int x, int y, int z, int width, int height);
    int  removeMixOverlayVideo(std::string userId);
    void pushFrame(Frame* frame);
    std::string toString();
    void setVideoFrameCallback(IYouMeVideoFrameCallback* videoFrameCallback);
    void setAudioFrameCallback(IYouMeAudioFrameCallback* audioFrameCallback);
    bool needMixing(std::string userId);
    
    void pushAudioTrack(AudioTrack* audioTrack);
    std::shared_ptr<AudioFifo> getAudioFifo(std::string userId);
    int addAudioFifo(std::string userId, int samplerate, int channels);

};

#endif /* YouMeEngineManagerForQiniu_hpp */
