package im.youme.talk.sample;


import java.io.IOException;
import java.util.List;

import java.util.ArrayList;
import android.annotation.SuppressLint;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.opengl.GLES20;
import android.opengl.GLES11Ext;
import android.os.Build;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.TextureView;
import android.content.Context;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.content.pm.PackageManager;
import android.app.Activity;
import android.Manifest;
import android.view.Surface;

import com.youme.voiceengine.NativeEngine;
import com.youme.voiceengine.video.GlUtil;


@SuppressLint("NewApi")
@SuppressWarnings("deprecation")
public class CameraMgrSample {
    static String tag =  CameraMgrSample.class.getSimpleName();

    private final static int DEFAULE_WIDTH = 640;
    private final static int DEFAULE_HEIGHT = 480;
    private final static int DEFAULE_FPS = 24;

    private SurfaceView svCamera = null;
    private SurfaceTexture mSurfaceTexture = null;
    private Camera camera = null;
    Camera.Parameters camPara = null;
    private String camWhiteBalance;
    private String camFocusMode;

    private byte mBuffer[];
    private static boolean isFrontCamera = false;
    private static int orientation = 90;
    private static int screenOrientation = 0;
    private static CameraMgrSample instance = new CameraMgrSample();
    private static Context context = null;
    private CameraMgrSample (){}
    public static CameraMgrSample getInstance() {
        return instance;
    }

    public CameraMgrSample(SurfaceView svCamera) {
        this.svCamera = svCamera;
        //this.svCamera.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
        //this.svCamera.getHolder().addCallback(new YMSurfaceHolderCallback());
    }

    public static void init(Context ctx) {
        context = ctx;
        if( context instanceof Activity )
        {
            switch (((Activity)context).getWindowManager().getDefaultDisplay().getRotation())  {
                case Surface.ROTATION_0:
                    screenOrientation = 0;
                    break;
                case Surface.ROTATION_90:
                    screenOrientation = 90;
                    break;
                case Surface.ROTATION_180:
                    screenOrientation = 180;
                    break;
                case Surface.ROTATION_270:
                    screenOrientation = 270;
                    break;
            }
        }
        else
        {
            screenOrientation = 0;
        }

    }

    public int openCamera(boolean isFront) {
        if(null != camera) {
            closeCamera();
        }

        int cameraId = 0;
        int cameraNum = Camera.getNumberOfCameras();
        CameraInfo cameraInfo = new CameraInfo();

        for (int i = 0; i < cameraNum; i++) {
            Camera.getCameraInfo(i, cameraInfo);
            if((isFront) && (cameraInfo.facing == CameraInfo.CAMERA_FACING_FRONT)) {
                cameraId = i;
                orientation = (360 - cameraInfo.orientation + 360 - screenOrientation) % 360;
                //orientation = (360 - orientation) % 360;  // compensate the mirror
                Log.d(tag, "i:" + i + "orientation:" + orientation);
                break;
            } else if((!isFront) && (cameraInfo.facing == CameraInfo.CAMERA_FACING_BACK)) {
                cameraId = i;
                orientation = (cameraInfo.orientation + 360 - screenOrientation) % 360;
                Log.d(tag, "ii:" + i + "orientation:" + orientation);
                break;
            }
        }

        try {
            camera = Camera.open(cameraId);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            camera = null;
            return -1;
        }

//        dumpCameraInfo(camera, cameraId);

        try {
            camPara = camera.getParameters();
        } catch(Exception e) {
            e.printStackTrace();
            camera = null;
            return -2;
        }

        Camera.Size size = getCloselyPreSize(DEFAULE_WIDTH, DEFAULE_HEIGHT, camPara.getSupportedPreviewSizes(), false);
        if( size == null  ){
            Log.d(tag, "could not  getCloselyPreSize ");
            return -3;
        }
        camPara.setPreviewSize(size.width, size.height);

        Log.d(tag, "width = " + size.width + ", height = " + size.height + "; w = " + DEFAULE_WIDTH + ", h = " + DEFAULE_HEIGHT + ", fps = " + DEFAULE_FPS);

        //p.setPreviewSize(352, 288);
        camPara.setPreviewFormat(ImageFormat.NV21);
        List<int[]> fpsRangeList = camPara.getSupportedPreviewFpsRange();
        //camPara.setPreviewFpsRange(VideoMgr.getFps() * 1000, VideoMgr.getFps() * 1000);
        camPara.setPreviewFpsRange(fpsRangeList.get(0)[0], fpsRangeList.get(0)[1]);
        Log.d(tag, "minfps = " + fpsRangeList.get(0)[0]+" maxfps = "+fpsRangeList.get(0)[1]);
        //camera.setDisplayOrientation(90);
        //mCamera.setPreviewCallback(new H264Encoder(352, 288));
        camWhiteBalance = camPara.getWhiteBalance();
        camFocusMode = camPara.getFocusMode();
        Log.d(tag, "white balance = " + camWhiteBalance + ", focus mode = " + camFocusMode);

        try {
            camera.setParameters(camPara);
        } catch(Exception e) {
            e.printStackTrace();
        }
        int mFrameWidth = camPara.getPreviewSize().width;
        int mFrameHeigth = camPara.getPreviewSize().height;
        int frameSize = mFrameWidth * mFrameHeigth;
        frameSize = frameSize * ImageFormat.getBitsPerPixel(camPara.getPreviewFormat())/8;
        mBuffer = new byte[frameSize];
        camera.addCallbackBuffer(mBuffer);
        camera.setPreviewCallback(youmePreviewCallback);

        if((Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) && (null == svCamera)) {
            int textureId = GlUtil.generateTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
            mSurfaceTexture = new SurfaceTexture(textureId);
            try {
                camera.setPreviewTexture(mSurfaceTexture);
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        } else {
            try {
                if(null == svCamera) {
                    camera.setPreviewDisplay(null);
                } else {
                    camera.setPreviewDisplay(svCamera.getHolder());
                }
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }

        setPerViewFps(DEFAULE_FPS);

        camera.startPreview();
        return 0;
    }

    public void setPerViewFps(int fps) {
        try {
            if (camera == null) {
                return;
            }

            Camera.Parameters p = camera.getParameters();
            p.setPreviewFrameRate(fps);
            p.setPreviewFpsRange((fps - 1) * 1000, fps * 1000);
            camera.setParameters(p);
        } catch (Exception e) {
            e.printStackTrace();
        }
        Log.i("Camera", "setPerViewFps fps:" + fps);
    }


    public int closeCamera() {
        if (camera != null) {
            camera.setPreviewCallback(null);
            camera.stopPreview();
            camera.release();
            camera = null;
        }
        return 0;
    }

    public void setSvCamera(SurfaceView svCamera) {
        this.svCamera = svCamera;
        //this.svCamera.getHolder().addCallback(new YMSurfaceHolderCallback());
        //this.svCamera.getHolder().setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }

    Camera.PreviewCallback youmePreviewCallback = new Camera.PreviewCallback() {
        @Override
        public void onPreviewFrame(byte[] data, Camera camera) {

            //Camera.Parameters camPara = camera.getParameters();
            int fmt        = camPara.getPreviewFormat();
            int fps        = camPara.getPreviewFrameRate();
            Camera.Size sz = camPara.getPreviewSize();
            int[] FpsRang = new int[2];
            camPara.getPreviewFpsRange(FpsRang);
            int width      = sz.width;
            int height     = sz.height;

            //Log.e(tag, "previewCallback is called.rotation:" + orientation + " width="+width+" height="+height+" length="+data.length);

            /*try {
                    File f = new File(Environment.getExternalStorageDirectory(), "/youme/video_capture.yuv");
                    if (!f.exists()) {
                            f.createNewFile();
                        }
                    FileOutputStream out = new FileOutputStream(f, true);
                    out.write(data, 0, width*height*3/2);
                    out.flush();
                    out.getFD().sync();
                    out.close();
                } catch (Exception e) {
                    return ;
                }*/
            int rotation = 270;
            if(!isFrontCamera)
            {
                rotation = 90;
            }
            NativeEngine.inputVideoFrame(data, data.length, width, height, 1, rotation, 0, System.currentTimeMillis());

            if(camera != null) {
                camera.addCallbackBuffer(mBuffer);
            }
        }
    };
    public static void startCapture() {
        Log.e(tag, "start capture is called");
        isFrontCamera = true;
        getInstance().openCamera(isFrontCamera);
    }

    public static void stopCapture() {
        Log.e(tag, "stop capture is called.");
        getInstance().closeCamera();
    }

    public static void switchCamera() {
        Log.e(tag, "switchCamera is called.");
        isFrontCamera = !isFrontCamera;
        getInstance().closeCamera();
        getInstance().openCamera(isFrontCamera);
    }

    private static class PermissionCheckThread extends Thread {
        @Override
        public void run() {
            try {
                Log.i(tag, "PermissionCheck starts...");
                Context mContext = context;
                while(!Thread.interrupted()) {
                    Thread.sleep(1000);
                    Log.i(tag, "PermissionCheck starts...running");
                    if ((mContext != null) && (mContext instanceof Activity)) {
                        int cameraPermission = ContextCompat.checkSelfPermission((Activity)mContext, Manifest.permission.CAMERA);
                        if (cameraPermission == PackageManager.PERMISSION_GRANTED) {
                            // Once the permission is granted, reset the microphone to take effect.
                            break;
                        }
                        int audioPermission = ContextCompat.checkSelfPermission((Activity)mContext, Manifest.permission.RECORD_AUDIO);
                        if (audioPermission == PackageManager.PERMISSION_GRANTED) {
                            // Once the permission is granted, reset the microphone to take effect.
                            break;
                        }
                    }
                }
            } catch (InterruptedException e) {
                Log.i(tag, "PermissionCheck interrupted");
            }catch (Throwable e) {
                Log.e(tag, "PermissionCheck caught a throwable:" + e.getMessage());

            }
            Log.i(tag, "PermissionCheck exit");
        }
    }
    private static PermissionCheckThread mPermissionCheckThread = null;

    public static boolean startRequestPermissionForApi23() {
        boolean isApiLevel23 = false;
        Context mContext = context;//AppPara.getContext();
        try {
            if ((Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) && (mContext != null)
                    && (mContext instanceof Activity) && (mContext.getApplicationInfo().targetSdkVersion >= 23)) {

                isApiLevel23 = true;
                int cameraPermission = ContextCompat.checkSelfPermission((Activity)mContext, Manifest.permission.CAMERA);
                if (cameraPermission != PackageManager.PERMISSION_GRANTED) {
                    Log.e(tag, "Request for camera permission");
                    ActivityCompat.requestPermissions((Activity)mContext,
                            new String[]{Manifest.permission.CAMERA},
                            1);
                    // Start a thread to check if the permission is granted. Once it's granted, reset the microphone to apply it.
                    if (mPermissionCheckThread != null) {
                        mPermissionCheckThread.interrupt();
                        mPermissionCheckThread.join(2000);
                    }
                    mPermissionCheckThread = new PermissionCheckThread();
                    if (mPermissionCheckThread != null) {
                        mPermissionCheckThread.start();
                    }
                } else {
                    Log.i(tag, "Already got camera permission");
                }
            }
        } catch (Throwable e) {
            Log.e(tag, "Exception for startRequirePermiForApi23");
            e.printStackTrace();
        }

        return isApiLevel23;
    }

    public static void stopRequestPermissionForApi23() {
        try {
            if (mPermissionCheckThread != null) {
                mPermissionCheckThread.interrupt();
                mPermissionCheckThread.join(2000);
                mPermissionCheckThread = null;
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    /**
     * 通过对比得到与宽高比最接近的尺寸（如果有相同尺寸，优先选择）
     *
     * @param surfaceWidth           需要被进行对比的原宽
     * @param surfaceHeight          需要被进行对比的原高
     * @param preSizeList            需要对比的预览尺寸列表
     * @return  得到与原宽高比例最接近的尺寸
     */
    protected Camera.Size getCloselyPreSize(int surfaceWidth, int surfaceHeight,
                                            List<Camera.Size> preSizeList, boolean mIsPortrait) {

        int ReqTmpWidth;
        int ReqTmpHeight;
        // 当屏幕为垂直的时候需要把宽高值进行调换，保证宽大于高
        switch(orientation) {
            case 90:
            case 270:
                ReqTmpWidth = surfaceHeight;
                ReqTmpHeight = surfaceWidth;
                break;
            default:
                ReqTmpWidth = surfaceWidth;
                ReqTmpHeight = surfaceHeight;
                break;
        }

        //先查找preview中是否存在与surfaceview相同宽高的尺寸
        float wRatio = 1.0f;
        float hRatio = 1.0f;
        List<Camera.Size> tempList = new ArrayList<Camera.Size>();
        for(Camera.Size size : preSizeList){
            wRatio = (((float) size.width) / ReqTmpWidth);
            hRatio = (((float) size.height) / ReqTmpHeight);
            if((wRatio >= 1.0) && (hRatio >= 1.0)) {
                tempList.add(size);
            }
        }

        int pixelCount = 0;
        Camera.Size retSize = null;
        for(Camera.Size size : tempList) {
            if(0 == pixelCount) {
                pixelCount = size.width * size.height;
                retSize = size;
            } else {
                if((size.width * size.height) < pixelCount) {
                    pixelCount = size.width * size.height;
                    retSize = size;
                }
            }
        }

        // 得到与传入的宽高比最接近的size
//        float reqRatio = ((float) ReqTmpWidth) / ReqTmpHeight;
//        float curRatio, deltaRatio;
//        float deltaRatioMin = Float.MAX_VALUE;
//        Camera.Size retSize = null;
//        for (Camera.Size size : preSizeList) {
//            curRatio = ((float) size.width) / size.height;
//            deltaRatio = Math.abs(reqRatio - curRatio);
//            if (deltaRatio < deltaRatioMin) {
//                deltaRatioMin = deltaRatio;
//                retSize = size;
//            }
//        }

        if( retSize != null ){
            Log.i(tag, "w:"+retSize.width+" h:"+retSize.height);
        }

        return retSize;
    }


}
