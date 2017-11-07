package im.youme.talk.sample;


import android.annotation.TargetApi;
import android.content.Context;
import android.media.AudioManager;
import android.media.audiofx.AutomaticGainControl;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;

import com.youme.voiceengine.NativeEngine;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.locks.ReentrantLock;

public class AudioRecorderSample
{
    private static final String  TAG = "AudioRecorderSample";
    private static final int     DEFAULT_SAMPLE_RATE = 44100;
    private static final int     DEFAULT_CHANNEL_NUM = 1;
    private static final int     DEFAULT_BYTES_PER_SAMPLE = 2;
    private static final boolean DEBUG = false;
    private static WebRtcAudioEffects effects = null;

    private static String        AudioName;
    private static String        AudioRecordError;
    private static AudioRecord   mAudioRecord;
    private static int           mMinBufferSize = 0;
    private static Thread        mRecorderThread;
    private static Thread        mRecorderCopyThread;
    private static boolean       mIsRecorderStarted = false;
    private static boolean       mIsLoopExit = false;
    private static int           mMicSource;
    private static int           mSamplerate;
    private static int           mChannelNum;
    private static int           mBytesPerSample;
    private static int           mInitStatus = 100;
    private static int           mRecordStatus = 0;
    public  static byte[]        mOutBuffer = null;
    private static int           mCounter = 1;
    private static int           mLoopCounter = 1;
    private static boolean       mInitSuceed = false;
    private static AudioManager  mAudioManager = null;
    private static int           readBufSize = 0;
    private static boolean       rsync = false;

    private static BlockingQueue<byte[]> audioBufferQueue;
    private static ReentrantLock lock = new ReentrantLock();

    public static boolean isRecorderStarted () {
        return mIsRecorderStarted;
    }

    public static int getRecorderStatus () {
        return mRecordStatus;
    }

    public static int getRecorderInitStatus () {
        return mInitStatus;
    }

    public static void initRecorder (Context env) {
        initRecorder(DEFAULT_SAMPLE_RATE, DEFAULT_CHANNEL_NUM, DEFAULT_BYTES_PER_SAMPLE);
        mAudioManager = (AudioManager) env.getSystemService  (Context.AUDIO_SERVICE);
    }

    // Creates an AudioRecord instance using AudioRecord.Builder which was added in API level 23.
    @TargetApi(23)
    private static AudioRecord createAudioRecordOnMarshmallowOrHigher(
            int sampleRateInHz, int channelConfig, int bufferSizeInBytes) {
        Log.d(TAG, "createAudioRecordOnMarshmallowOrHigher");
        return new AudioRecord.Builder()
                .setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
                .setAudioFormat(new AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRateInHz)
                        .setChannelMask(channelConfig)
                        .build())
                .setBufferSizeInBytes(bufferSizeInBytes)
                .build();
    }

    public static void initRecorder (int sampleRateInHz, int channelNum, int bytesPerSample) {
        int channelCfg;
        int pcmType;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            mMicSource = MediaRecorder.AudioSource.VOICE_COMMUNICATION;
        }else{
            mMicSource = MediaRecorder.AudioSource.VOICE_CALL;
        }
        mSamplerate      = sampleRateInHz;
        mChannelNum      = channelNum;
        mBytesPerSample  = bytesPerSample;
        mLoopCounter     = 1;
        mInitSuceed      = true;

        switch (channelNum) {
            case 1:
                channelCfg = AudioFormat.CHANNEL_IN_MONO;
                break;
            case 2:
                channelCfg = AudioFormat.CHANNEL_IN_STEREO;
                break;
            default:
                channelCfg = AudioFormat.CHANNEL_IN_MONO;
                break;
        }
        switch (bytesPerSample) {
            case 1:
                pcmType = AudioFormat.ENCODING_PCM_8BIT;
                break;
            case 2:
                pcmType = AudioFormat.ENCODING_PCM_16BIT;
                break;
            default:
                pcmType = AudioFormat.ENCODING_PCM_16BIT;
                break;
        }
        readBufSize = 2048;//mSamplerate * mChannelNum * mBytesPerSample / 100 * 2; // 20ms data
        mOutBuffer = new byte[readBufSize];
        audioBufferQueue = new ArrayBlockingQueue<byte[]>(10);

        mMinBufferSize = AudioRecord.getMinBufferSize(mSamplerate, channelCfg, pcmType) * 2;
        if (mMinBufferSize == AudioRecord.ERROR_BAD_VALUE) { // AudioRecord.ERROR_BAD_VALUE = -2
            Log.e(TAG, "Invalid parameter !");
            mInitStatus = AudioRecord.ERROR_BAD_VALUE;
            mInitSuceed = false;
        }
        Log.d(TAG, "getMinBufferSize = "+mMinBufferSize+" bytes");

        try
        {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Use AudioRecord.Builder to create the AudioRecord instance if we are on API level 23 or
                // higher.
                mAudioRecord = createAudioRecordOnMarshmallowOrHigher(
                        mSamplerate, channelCfg, mMinBufferSize);
            } else {
                // Use default constructor for API levels below 23.
                mAudioRecord = new AudioRecord(mMicSource, mSamplerate, channelCfg, pcmType, mMinBufferSize);
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                effects = WebRtcAudioEffects.create();
                effects.setAEC(true);
                effects.enable(mAudioRecord.getAudioSessionId());
            }
        }
        catch (IllegalArgumentException e) {
            Log.e(TAG, "AudioRecord initialize fail :" + e.getMessage() );
            mInitStatus = AudioRecord.STATE_UNINITIALIZED;
            mInitSuceed = false;
            return;
        }

        if (mAudioRecord.getState() == AudioRecord.STATE_UNINITIALIZED) { // AudioRecord.STATE_UNINITIALIZED = 0, AudioRecord.STATE_INITIALIZED = 1
            Log.e(TAG, "AudioRecord initialize fail !");
            mInitStatus = AudioRecord.STATE_UNINITIALIZED;
            mAudioRecord.release(); // Initial fail will release handler
            mInitSuceed = false;
        }


        if (mInitSuceed && (readBufSize > mMinBufferSize)) {
            Log.e(TAG, "Error record buffer overflow!");
        }
        

    }

    public static boolean startRecorder () {
        if (mIsRecorderStarted) {
            Log.e(TAG, "Recorder already started !");
            return false;
        }
        if (null != mAudioManager) {
            Log.e("AudioMgr", "mAudioManager.setMode");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
                mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            } else {
                mAudioManager.setMode(AudioManager.MODE_IN_CALL);
            }
        }

        if (mInitSuceed) {
            mAudioRecord.startRecording();
        }
        mAudioManager.setSpeakerphoneOn(true);

        mIsLoopExit = false;
        mRecorderThread = new Thread(new AudioRecorderRunnable());
        mRecorderThread.start();
        if(rsync) {
            mRecorderCopyThread = new Thread(new AudioBufferCopyRunnable());
            mRecorderCopyThread.start();
        }

        mIsRecorderStarted = true;

        Log.d(TAG, "Start audio recorder success !");

        return true;
    }

    public static void stopRecorder() {
        if (null != mAudioManager) {
            Log.e("AudioMgr", "mAudioManager is null");
            mAudioManager.setMode(AudioManager.MODE_NORMAL);
            mAudioManager.setSpeakerphoneOn(true);
        }
        if (!mIsRecorderStarted) {
            return;
        }

        mIsLoopExit = true;
        try {
            mRecorderThread.interrupt();
            mRecorderThread.join(5000);
            if(rsync) {
                mRecorderCopyThread.interrupt();
                mRecorderCopyThread.join(5000);
            }
        }
        catch (InterruptedException e) {
            e.printStackTrace();
        }

        if (mInitSuceed && (mAudioRecord.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING)) {
            mAudioRecord.stop();
            mAudioRecord.release();
        }

        mIsRecorderStarted = false;
        mOutBuffer = null;
        audioBufferQueue.clear();
        audioBufferQueue = null;
        if(effects!=null) {
            effects.release();
            effects = null;
        }

        Log.d(TAG, "Stop audio recorder success !");
    }


    private static class AudioBufferCopyRunnable implements Runnable{
        @Override
        public void run() {
            try {
                while ((!mIsLoopExit) && (!Thread.interrupted())) {
                    byte[] buff = audioBufferQueue.take();
                    NativeEngine.inputAudioFrame(buff, buff.length, System.currentTimeMillis());
                }
            }catch (Exception e) {
                Log.e(TAG, "Recorder Copy thread exit!");
            }
        }
    }

    private static class AudioRecorderRunnable implements Runnable {

        @Override
        public void run() {
            FileOutputStream fos = null;
            if (DEBUG) {
                AudioName = String.format("/sdcard/test_%d.pcm", mCounter++);
                File file = new File(AudioName);
                try {
                    if (file.exists()) {
                        file.delete();
                    }
                    fos = new FileOutputStream(file); //建立一个可以存取字节的文件
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            try {
                while ((!mIsLoopExit) && (!Thread.interrupted())) {

                    //int readBufSize = mSamplerate * mChannelNum * mBytesPerSample / 100 * 2; // 20ms data
                    if (mInitSuceed && (readBufSize > mMinBufferSize)) {
                        Log.e(TAG, "Error record buffer overflow!");
                    }

                    if (mInitSuceed) {
                        int ret = mAudioRecord.read(mOutBuffer, 0, readBufSize);
                        if (ret > 0) {
                            if (DEBUG) {
                                Log.d(TAG, "OK, Recorder " + ret + " bytes: [" + mOutBuffer[0] + "][" + mOutBuffer[1] + "][" + mOutBuffer[2] + "][" + mOutBuffer[3] + "]");
                                try {
                                    fos.write(mOutBuffer);
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                            if ((mLoopCounter < 5) && (mLoopCounter >= 0)) {
                                Log.e(TAG, "Record success: ret="+ret);
                            }
                            OnAudioRecorderRefresh(mOutBuffer, mSamplerate, mChannelNum, mBytesPerSample);
                            mRecordStatus = mAudioRecord.getRecordingState();
                        } else {
                            switch (ret) {
                                case AudioRecord.ERROR_INVALID_OPERATION:     // =-3, if the object isn't properly initialized
                                    AudioRecordError = "Error ERROR_INVALID_OPERATION";
                                    break;
                                case AudioRecord.ERROR_BAD_VALUE:             // =-2, if the parameters don't resilve to valid data and indexes
                                    AudioRecordError = "Error ERROR_BAD_VALUE";
                                    break;
                                //case AudioRecord.ERROR_DEAD_OBJECT:           // =-6, if and error indicating that the object reporting it is no longer valid and needs to be recreated
                                //    AudioRecordError = "Error ERROR_DEAD_OBJECT";
                                //    break;
                                case AudioRecord.ERROR:                       // =-1, in case of other error
                                    AudioRecordError = "Error Other ERRORs";
                                    break;
                                case 0:
                                    AudioRecordError = "Error Record Size=0, maybe record right NOT be enabled in some special android phone!!";
                                    break;
                            }
                            mRecordStatus = ret;
                            Arrays.fill(mOutBuffer, (byte)0);
                            Log.d(TAG, "Dummy getMinBufferSize = "+mOutBuffer.length+" bytes");
                            OnAudioRecorderRefresh(mOutBuffer, mSamplerate, mChannelNum, mBytesPerSample);
                            Thread.sleep(20);
                            if ((mLoopCounter < 5) && (mLoopCounter >= 0)) {
                                Log.e(TAG, AudioRecordError);
                            }
                        }
                        mLoopCounter++;
                    } else { // Dummy record data if initial fail
                        Arrays.fill(mOutBuffer, (byte)0);
                        Log.d(TAG, "Dummy getMinBufferSize = "+mOutBuffer.length+" bytes");
                        OnAudioRecorderRefresh(mOutBuffer, mSamplerate, mChannelNum, mBytesPerSample);
                        Thread.sleep(20);
                    }
                }
            } catch (InterruptedException e) {
                Log.e(TAG, "Recorder thread exit!");
            }

            if (DEBUG) {
                try {
                    fos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void OnAudioRecorder(int isStart) {
        //Log.d("AudioRecorder", "AudioRecorder : " + isStart);
        if (isStart != 0) {
            startRecorder();
        } else {
            stopRecorder();
        }
    }

    public static void OnAudioRecorderRefresh(byte[] audBuf, int samplerate, int channelnum, int bps) {
        // Notify native layer to refresh IO buffer
//        NativeEngine.AudioRecorderBufRefresh(audBuf, samplerate, channelnum, bps);
        try {
            if(rsync) {
                byte[] copyBuff = new byte[audBuf.length];
                System.arraycopy(audBuf,0,copyBuff,0,audBuf.length);
                if(audioBufferQueue.remainingCapacity()<8){
                    Log.d("OnAudioRecorderRefresh",""+audioBufferQueue.remainingCapacity());
                    audioBufferQueue.clear();
                }
//                Log.d("OnAudioRecorderRefresh",""+audioBufferQueue.remainingCapacity());
                audioBufferQueue.put(copyBuff);
            }else {
                NativeEngine.inputAudioFrame(audBuf, audBuf.length, System.currentTimeMillis());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
