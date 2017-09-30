package im.youme.talk.sample;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Switch;

public class videoSet extends AppCompatActivity {

    private EditText mVideoWidth;
    private EditText mVideoHeight;
    private EditText mReportInterval;
    private EditText mBitRate;
    private EditText mFarendLevel;
    private Switch mQualitySwitch;
    private Switch mbHWEnableSwitch;

    private void initComponent(){
        mVideoWidth = (EditText)findViewById(R.id.editText_videoWidth);
        mVideoHeight = (EditText)findViewById(R.id.editText_videoHeight);
        mReportInterval = (EditText)findViewById(R.id.editText_reportInterval);
        mBitRate = (EditText)findViewById(R.id.editText_bitRate);
        mFarendLevel = (EditText)findViewById(R.id.editText_farendLevel);
        mQualitySwitch = (Switch)findViewById(R.id.switch_videoQuality);
        mbHWEnableSwitch = (Switch)findViewById(R.id.switch_bHWEnable);

        mVideoWidth.setText(Integer.toString(VideoCapturerActivity._videoWidth));
        mVideoHeight.setText(Integer.toString(VideoCapturerActivity._videoHeight));
        mReportInterval.setText(Integer.toString(VideoCapturerActivity._reportInterval));
        mBitRate.setText(Integer.toString(VideoCapturerActivity._bitRate));
        mFarendLevel.setText(Integer.toString(VideoCapturerActivity._farendLevel));

        //api14以下调用setChecked有问题？call requires api14
        mQualitySwitch.setChecked(VideoCapturerActivity._bHighAudio);
        mbHWEnableSwitch.setChecked(VideoCapturerActivity._bHWEnable);

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_video_set);
        initComponent();
    }


    //点击确定按钮的响应
    public void onConfirmClick(View view){

        VideoCapturerActivity._videoWidth = Integer.parseInt(mVideoWidth.getText().toString());
        VideoCapturerActivity._videoHeight = Integer.parseInt(mVideoHeight.getText().toString());
        VideoCapturerActivity._reportInterval = Integer.parseInt(mReportInterval.getText().toString());
        VideoCapturerActivity._bitRate = Integer.parseInt(mBitRate.getText().toString());
        VideoCapturerActivity._farendLevel = Integer.parseInt(mFarendLevel.getText().toString());
        VideoCapturerActivity._bHighAudio = mQualitySwitch.isChecked();
        VideoCapturerActivity._bHWEnable   =mbHWEnableSwitch.isChecked();

        videoSet.this.finish();
    }
}
