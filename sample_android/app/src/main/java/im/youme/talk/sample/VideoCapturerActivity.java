package im.youme.talk.sample;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.opengl.EGL14;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import android.content.Context;

import com.youme.voiceengine.MemberChange;
import com.youme.voiceengine.NativeEngine;
import com.youme.voiceengine.VideoCapturer;
import com.youme.voiceengine.VideoMgr;
import com.youme.voiceengine.VideoRenderer;
import com.youme.voiceengine.VoiceEngineService;
import com.youme.voiceengine.YouMeCallBackInterface;
import com.youme.voiceengine.YouMeConst;
import com.youme.voiceengine.api;
import com.youme.voiceengine.mgr.YouMeManager;
import com.youme.voiceengine.video.EglBase;
import com.youme.voiceengine.video.RendererCommon;
import com.youme.voiceengine.video.SurfaceViewRenderer;
import com.youme.voiceengine.video.VideoBaseRenderer;
import android.widget.EditText;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

import im.youme.talk.video.PercentFrameLayout;
import android.view.KeyEvent;
import com.tencent.bugly.BuglyStrategy;
import com.tencent.bugly.crashreport.CrashReport;

public class VideoCapturerActivity extends Activity implements YouMeCallBackInterface, View.OnClickListener{

    private static final String YOUME_BUGLY_APP_ID = "428d8b14e2";
    //声明video设置块相关静态变量
    public static int _videoWidth = 240;
    public static int _videoHeight = 320;
    public static int _maxBitRate = 0;
    public static int _minBitRate = 0;
    public static int _reportInterval = 5000;
    public static int _farendLevel = 10;
    public static boolean _bHighAudio = false;
    public static boolean _bHWEnable = true;



    private EditText mUserIDEditText;
    private EditText mRoomIDEditText;


    private static String TAG = "YOUME:" + VideoCapturerActivity.class.getSimpleName();
    private PercentFrameLayout mSurfaceLayout = null;
    private SurfaceViewRenderer mSurfaceView = null;


    private PercentFrameLayout remoteVideoLayout = null;
    private SurfaceViewRenderer remoteVideoView = null;

    private PercentFrameLayout mRemoteSurfaceViewLayoutTwo = null;
    private SurfaceViewRenderer mRemoteSurfaceViewTwo = null;

    private PercentFrameLayout mRemoteSurfaceViewLayoutThree = null;
    private SurfaceViewRenderer mRemoteSurfaceViewThree = null;

    private TextView tvState = null;
    private TextView avTips = null;
    private String m_newUserId;
    private int m_UserViewIndex = 0;
    private int[] m_UserViewIndexEn = {0, 0, 0};

    private Button btn_join = null;
    private Button btn_camera_onoff = null;
    private Button btn_camera_switch = null;
    private Button btn_open_mic = null;
    private boolean isCameraOn = false;
    private Map<Integer, String> renderMap = null;

    String local_user_id = null;
    private boolean isJoinedRoom=false;

    private long  avTime = 0;
    private String  strAvTip = null ;
    private String  farendLevel = "0";

    private boolean  isMicOpen = false;

    private int local_render_id = 0;
    private int rotation = 0;
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Context context = getApplicationContext();
        CrashReport.initCrashReport(context, YOUME_BUGLY_APP_ID, true);
        CrashReport.setAppVersion(context, "外部输入");
//        YouMeManager.setSOName( "youmetalk" );
        YouMeManager.Init(this);
        super.onCreate(savedInstanceState);
        Intent intent = new Intent(this,VoiceEngineService.class);
        startService(intent);

        //设置回调监听对象,需要implements YouMeCallBackInterface
        api.SetCallback(this);
        //设置测试服还是正式服
        //NativeEngine.setServerMode(NativeEngine.SERVER_MODE_TEST);
        //设置api为外部输入音视频的模式
        api.setExternalInputMode( true );
        //调用初始化
        api.init(CommonDefines.appKey, CommonDefines.appSecret, YouMeConst.YOUME_RTC_SERVER_REGION.RTC_CN_SERVER, "");

        strAvTip = "";

        getWindow().setFormat(PixelFormat.TRANSLUCENT);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_video_capturer);


        mUserIDEditText = (EditText)findViewById(R.id.editText_userID);
        mRoomIDEditText = (EditText)findViewById(R.id.editText_roomID);

        //随机userid
        local_user_id = "user"+(int)(Math.random() * 10000);
        mUserIDEditText.setText(local_user_id);




        mSurfaceLayout = (PercentFrameLayout) this.findViewById(R.id.capturer_video_layout);
        mSurfaceLayout.setPosition(0,0,100,100);
        mSurfaceView = (SurfaceViewRenderer) this.findViewById(R.id.capturer_video_view);
        try {
            mSurfaceView.init(null, null);
            //mSurfaceView.init(EglBase.create().getEglBaseContext(), null);
        } catch (Exception e) {
            System.out.println("catch exception");
            throw e;
        }
        mSurfaceView.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
        mSurfaceView.setMirror(false);
        mSurfaceView.setVisibility(View.VISIBLE);

        btn_join = (Button)findViewById( R.id.btn_join );

        //int render00 = VideoRenderer.addRender(user_id, mSurfaceView);
        btn_camera_onoff = (Button) findViewById(R.id.btn_camera_onoff);
        btn_camera_onoff.setActivated(false);
        btn_camera_onoff.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!isJoinedRoom ){
                    Toast.makeText(VideoCapturerActivity.this, "进入频道还没有完成", Toast.LENGTH_SHORT).show();
                    return;
                }
                tvState.setText("the sdkInfo:" + api.getSdkInfo());
                if(isCameraOn) {
//                    VideoCapturer.StopCapturer();
                    CameraMgrSample.stopCapture();
//                    AudioRecorderSample.stopRecorder();
                    btn_camera_onoff.setText("打开摄像头");
                } else {
//                    VideoCapturer.StartCapturer();
                    CameraMgrSample.startCapture();
                    //设置视频无渲染帧超时等待时间，单位毫秒
                    api.setVideoNoFrameTimeout(5000);
                    btn_camera_onoff.setText("关闭摄像头");
                }
                isCameraOn = isCameraOn?false:true;
            }
        } );

        btn_camera_switch = (Button) findViewById(R.id.btn_camera_switch);
        btn_camera_switch.setOnClickListener(this);

        btn_open_mic = (Button) findViewById( R.id.btn_open_mic );
        btn_open_mic.setOnClickListener( this );

        tvState = (TextView) findViewById(R.id.state);
        renderMap = new HashMap<>();

        avTips = (TextView) findViewById( R.id.avtip);
        avTips.setTextColor( Color.rgb(255, 255, 255) );

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        for(Integer key : renderMap.keySet()) {
            VideoRenderer.deleteRender(key);
        }

        VideoRenderer.deleteRender(local_render_id);
    }

    @Override
    protected void onStop() {
        super.onStop();
    }

    private void updateLocalView() {
        local_render_id = VideoRenderer.addRender(local_user_id, mSurfaceView);
    }

    private void updateNewView(final String newUserId, int index) {
        int render = 0;

        switch (index) {
            case 0:
                remoteVideoLayout = (PercentFrameLayout) this.findViewById(R.id.remote_video_layout_one);
                remoteVideoLayout.setPosition(0,0,100,100);
                remoteVideoView = (SurfaceViewRenderer) this.findViewById(R.id.remote_video_view_one);
                //remoteVideoView.init(EglBase.create().getEglBaseContext(), null);
                remoteVideoView.init(null, null);
                remoteVideoView.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
                remoteVideoView.setMirror(false);
                remoteVideoView.setVisibility(View.VISIBLE);
                render = VideoRenderer.addRender(newUserId, remoteVideoView);
                remoteVideoView.setOnClickListener(new View.OnClickListener() {
                    boolean mask = false;
                    final String m_tempUserId = newUserId;
                    @Override
                    public void onClick(View view) {
                        if (m_UserViewIndexEn[0] == 1) {
                            if (!mask) {
                                NativeEngine.maskVideoByUserId(m_tempUserId, true); // 1是屏蔽
                                mask = true;
                            } else {
                                NativeEngine.maskVideoByUserId(m_tempUserId, false); // 2是恢复
                                mask = false;
                            }
                        }
                    }
                });
                break;
            case 1:
                mRemoteSurfaceViewLayoutTwo = (PercentFrameLayout)this.findViewById(R.id.remote_video_layout_two);
                mRemoteSurfaceViewLayoutTwo.setPosition(0,0,100,100);
                mRemoteSurfaceViewTwo = (SurfaceViewRenderer) this.findViewById(R.id.remote_video_view_two);
                //mRemoteSurfaceViewTwo.init(EglBase.create().getEglBaseContext(), null);
                mRemoteSurfaceViewTwo.init(null, null);
                mRemoteSurfaceViewTwo.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
                mRemoteSurfaceViewTwo.setMirror(false);
                mRemoteSurfaceViewTwo.setVisibility(View.VISIBLE);
                render = VideoRenderer.addRender(newUserId, mRemoteSurfaceViewTwo);
                mRemoteSurfaceViewTwo.setOnClickListener(new View.OnClickListener() {
                    boolean mask = false;
                    final String m_tempUserId = newUserId;
                    @Override
                    public void onClick(View view) {
                        if (m_UserViewIndexEn[1] == 1) {
                            if (!mask) {
                                NativeEngine.maskVideoByUserId(m_tempUserId, true); // 1是屏蔽
                                mask = true;
                            } else {
                                NativeEngine.maskVideoByUserId(m_tempUserId, false); // 2是恢复
                                mask = false;
                            }
                        }
                    }
                });
                break;
            case 2:
                mRemoteSurfaceViewLayoutThree = (PercentFrameLayout)this.findViewById(R.id.remote_video_layout_three);
                mRemoteSurfaceViewLayoutThree.setPosition(0,0,100,100);
                mRemoteSurfaceViewThree = (SurfaceViewRenderer) this.findViewById(R.id.remote_video_view_three);
                //mRemoteSurfaceViewThree.init(EglBase.create().getEglBaseContext(), null);
                mRemoteSurfaceViewThree.init(null, null);
                mRemoteSurfaceViewThree.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
                mRemoteSurfaceViewThree.setMirror(false);
                mRemoteSurfaceViewThree.setVisibility(View.VISIBLE);
                render = VideoRenderer.addRender(newUserId, mRemoteSurfaceViewThree);
                mRemoteSurfaceViewThree.setOnClickListener(new View.OnClickListener() {
                    boolean mask = false;
                    final String m_tempUserId = newUserId;
                    @Override
                    public void onClick(View view) {
                        if (m_UserViewIndexEn[2] == 1) {
                            if (!mask) {
                                NativeEngine.maskVideoByUserId(m_tempUserId, true); // 1是屏蔽
                                mask = true;
                            } else {
                                NativeEngine.maskVideoByUserId(m_tempUserId, false); // 2是恢复
                                mask = false;
                            }
                        }
                    }
                });
                break;
        }
        renderMap.put(render, newUserId);
        Log.d(TAG, "render = " + render + ".");
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        try {
            super.onConfigurationChanged(newConfig);
            if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
            } else if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            }
        } catch (Exception ex) {
        }
    }

    @Override
    public void onEvent (int event, int error, String room, Object param) {
        Log.i(TAG, "event:" + CommonDefines.CallEventToString(event) + ", error:" + error + ", room:" + room + ",param:" + param);
        Message msg = new Message();
        Bundle extraData = new Bundle();
        extraData.putString("channelId", room);
        msg.what = event;
        msg.arg1 = error;
        msg.obj = param;
        msg.setData(extraData);

        youmeVideoEventHandler.sendMessage(msg);
    }

	@Override
    public  void onRequestRestAPI(int requestID , int iErrorCode , String strQuery, String strResult) {

    }

	@Override
    public  void onMemberChange(String channelID, MemberChange[] arrChanges, boolean isUpdate  ) {
        Log.i(TAG, "onMemberChange:"+channelID + ",isUpdate:" + isUpdate );

    }

	@Override
	public  void onBroadcast(int bc , String room, String param1, String param2, String content){
			
	}

    @Override
    public  void onAVStatistic( int avType,  String userID, int value )
    {
        Message msg = new Message();
        Bundle extraData = new Bundle();
        extraData.putString("userID", userID);
        msg.what = 10000;
        msg.arg1 = avType;
        msg.arg2 = value;
        msg.obj = userID;
        msg.setData(extraData);

        youmeVideoEventHandler.sendMessage(msg);

    }
		
    private Handler youmeVideoEventHandler = new Handler() {
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            String userId;
            switch (msg.what) {
                case YouMeConst.YouMeEvent.YOUME_EVENT_INIT_OK:
                    Log.d(TAG, "初始化成功");
                    tvState.setText("初始化成功");
                    //Demo初始化摄像头
                    CameraMgrSample.getInstance().init(VideoCapturerActivity.this);

                    //btn_join.performClick();

                    mRemoteSurfaceViewLayoutThree = (PercentFrameLayout)VideoCapturerActivity.this.findViewById(R.id.remote_video_layout_three);
                    mRemoteSurfaceViewLayoutThree.setPosition(0,0,100,100);
                    mRemoteSurfaceViewThree = (SurfaceViewRenderer) VideoCapturerActivity.this.findViewById(R.id.remote_video_view_three);
                    //mRemoteSurfaceViewThree.init(EglBase.create().getEglBaseContext(), null);
                    mRemoteSurfaceViewThree.init(null, null);
                    mRemoteSurfaceViewThree.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FIT);
                    mRemoteSurfaceViewThree.setMirror(false);
                    mRemoteSurfaceViewThree.setVisibility(View.VISIBLE);

                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_JOIN_OK:
                    if( !isJoinedRoom ){
                        Log.d(TAG, "进频道成功");
                        tvState.setText("进频道成功");
//                    api.setHeadsetMonitorOn(true);
                        //进频道成功后可以设置视频回调
                        api.SetVideoCallback();
                        //设置混流回调
                        VideoMgr.setVideoFrameCallback(new videoDataCallback());
                        VideoMgr.setMixVideoSize(360,480);
                        //String userId, int x, int y, int z, int width, int height
                        VideoMgr.addMixOverlayVideo(local_user_id,0,0,0,360,480);
                        //设置远端语音音量回调



                        //这时候允许打开摄像头进行采集
                        btn_camera_onoff.setActivated(true);
                        isJoinedRoom = true;

                        //btn_camera_onoff.performClick();
                    }
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_LEAVED_ALL:
                    isJoinedRoom = false;
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_VIDEO_ON:
                    boolean needCreateRender = true;
                    m_newUserId = String.valueOf(msg.obj);
                    Log.d(TAG, "新加的user ID=" + m_newUserId);
                    VideoMgr.addMixOverlayVideo(m_newUserId,20,40,0,240,120);
                    if(m_newUserId.equals(local_user_id)) {
                        updateLocalView();
                    } else {
                        for(Integer render : renderMap.keySet()) {
                            String tempUserId = (String)renderMap.get(render);
                            if(tempUserId.equals(m_newUserId)) {
                                needCreateRender = false;
                                break;
                            }
                        }

                        if(needCreateRender) {
                            //m_UserViewIndex = m_UserViewCnt % 3;
                            m_UserViewIndex = renderMap.size();
                            if(m_UserViewIndex<2) {//demo只支持接收3路远端数据，这个判断避免崩溃
                                updateNewView(m_newUserId, m_UserViewIndex);
                                m_UserViewIndexEn[m_UserViewIndex] = 1;
                            }
                        }
                    }

                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_VIDEO_OFF:
                    m_newUserId = String.valueOf(msg.obj);
                    Log.d(TAG, "下线的user ID=" + m_newUserId);
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_MASK_VIDEO_BY_OTHER_USER:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, "Mask video by user: " + userId, Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_RESUME_VIDEO_BY_OTHER_USER:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, "Resume video by user: " + userId, Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_MASK_VIDEO_FOR_USER:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, "Mask video for user: " + userId, Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_RESUME_VIDEO_FOR_USER:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, "Resume video for user: " + userId, Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_CAMERA_PAUSE:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, userId + " camera status OFF ", Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_CAMERA_RESUME:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, userId + " camera status ON ", Toast.LENGTH_SHORT).show();
                    break;
                case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_VIDEO_SHUT_DOWN:
                    userId = String.valueOf(msg.obj);
                    Toast.makeText(VideoCapturerActivity.this, userId + " video is shut down ", Toast.LENGTH_SHORT).show();
                    break;
                case 10000: //avStatistic回调
                {
                    userId = String.valueOf( msg.obj );

                    long curtime = System.currentTimeMillis();
                    if( curtime - avTime >= 1000 )
                    {
                        strAvTip = "";
                    }

                    avTime = curtime;
                    strAvTip = strAvTip + msg.arg1 + "," + userId + "," + msg.arg2 + "\n";
                    avTips.setText(strAvTip );
                    break;
                }
                case YouMeConst.YouMeEvent.YOUME_EVENT_FAREND_VOICE_LEVEL:
                    int level = msg.arg1;
                    userId = String.valueOf(msg.obj);
                    if (level < 1) {
                        farendLevel = "0";
                    } else if (level < 2) {
                        farendLevel = "00";
                    } else if (level < 3) {
                        farendLevel = "000";
                    } else if (level < 4) {
                        farendLevel = "0000";
                    } else if (level < 5) {
                        farendLevel = "00000";
                    } else if (level < 6) {
                        farendLevel = "000000";
                    } else if (level < 7) {
                        farendLevel = "0000000";
                    } else if (level < 8) {
                        farendLevel = "00000000";
                    } else if (level < 9) {
                        farendLevel = "000000000";
                    } else if (level < 10) {
                        farendLevel = "0000000000";
                    } else {
                        farendLevel = "00000000000";
                    }
                    tvState.setText("the sdkInfo:" + api.getSdkInfo() + "\n远端音量(" + userId + "): " + farendLevel);
                    break;
            }
        }
    };

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_camera_switch:
                CameraMgrSample.switchCamera();
                break;
            case R.id.btn_open_mic:
            {
                if( isMicOpen == true )
                {
                    btn_open_mic.setText( "打开麦克风" );
                    NativeEngine.stopInputVideoFrame();
                    AudioRecorderSample.stopRecorder();
                    isMicOpen = false;
                }
                else{
                    btn_open_mic.setText( "关闭麦克风" );
                    AudioRecorderSample.initRecorder(VideoCapturerActivity.this);
                    AudioRecorderSample.startRecorder();
                    api.setSpeakerMute(false);
                    isMicOpen = true;
                }

            }
            break;
        }
    }


    /**
     * 监听Back键按下事件,方法1:
     * 注意:
     * super.onBackPressed()会自动调用finish()方法,关闭
     * 当前Activity.
     * 若要屏蔽Back键盘,注释该行代码即可
     */
    @Override
    public void onBackPressed() {
//        moveTaskToBack(true);
//        super.onBackPressed();
//        Log.i(TAG, "onBackPressed");
//        tvState.setText("退出中...");
//
//        VideoCapturerActivity.this.finish();
        System.exit(0);
    }

//    @Override
//    public boolean onKeyDown(int keyCode, KeyEvent event) {
//        if (keyCode==KeyEvent.KEYCODE_BACK){
//            moveTaskToBack(true);
//            System.exit(0);
//            return false;
//        }
//        super.onKeyDown(keyCode, event);
//        return true;
//    }

    //点击设置按钮响应
    public void onSetClick(View v){
        Intent intent = new Intent();
        intent.setClass(VideoCapturerActivity.this, videoSet.class);
        //intent.putExtra("userID",mUserID);
        //intent.putExtra("roomID",mRoomID);
        startActivity(intent);

    }

    //点击加入频道按钮响应
    public void onJoinClick(View v){

        if( isJoinedRoom ){
            api.leaveChannelAll() ;
            btn_join.setText("加入频道");
        }
        else
        {
            //加入频道前进行video设置
            api.setSampleRate(YouMeConst.YOUME_SAMPLE_RATE.SAMPLE_RATE_44);
            api.setVideoNetResolution(_videoWidth,_videoHeight);
            api.setAVStatisticInterval(_reportInterval);
            api.setVideoCodeBitrate(_maxBitRate, _minBitRate );
            api.setFarendVoiceLevelCallback(_farendLevel);
            api.setVideoHardwareCodeEnable(_bHWEnable);
            if(_bHighAudio){
                api.setAudioQuality(1);
            }else {
                api.setAudioQuality(0);
            }

            api.setMicrophoneMute( true );
            //进入频道
            local_user_id =  mUserIDEditText.getText().toString();
            int ret = api.joinChannelSingleModeWithAppKey( local_user_id, mRoomIDEditText.getText().toString(), YouMeConst.YouMeUserRole.YOUME_USER_HOST, CommonDefines.appJoinKey );
            btn_join.setText("离开频道");
        }
    }






    public class videoDataCallback implements VideoMgr.VideoFrameCallback {

        @Override
        public void onVideoFrameCallback(String userId, byte[] data, int len, int width, int height, int fmt, long timestamp) {
            //Log.i(TAG, "onVideoFrameCallback. data len:"+len+" fmt: " + fmt + " timestamp:" + timestamp);
        }

        @Override
        public void onVideoFrameMixed(byte[] data, int len, int width, int height, int fmt, long timestamp) {
            //Log.i(TAG, "onVideoFrameMixedCallback. data len:"+len+" fmt: " + fmt + " timestamp:" + timestamp);

            SurfaceViewRenderer view = mRemoteSurfaceViewThree;
            if(view != null) {
                int[] yuvStrides = new int[]{width, width / 2, width / 2};
                int yLen = width * height;
                int uLen = width * height / 4;
                int vLen = width * height / 4;
                byte[] yPlane = new byte[yLen];
                byte[] uPlane = new byte[uLen];
                byte[] vPlane = new byte[vLen];
                System.arraycopy(data, 0, yPlane, 0, yLen);
                System.arraycopy(data, yLen, uPlane, 0, uLen);
                System.arraycopy(data, yLen + uLen, vPlane, 0, vLen);
                ByteBuffer[] yuvPlanes = new ByteBuffer[]{ByteBuffer.wrap(yPlane), ByteBuffer.wrap(uPlane), ByteBuffer.wrap(vPlane)};
                VideoBaseRenderer.I420Frame frame = new VideoBaseRenderer.I420Frame(width, height,  0, yuvStrides, yuvPlanes);
                view.renderFrame(frame);
            } else {
                Log.e("VideoRenderer", "mRemoteSurfaceViewThree is null");
            }
        }
    }


}



