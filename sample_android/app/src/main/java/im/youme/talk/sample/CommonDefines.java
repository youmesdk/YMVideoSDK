package im.youme.talk.sample;

import com.youme.voiceengine.YouMeConst;

/**
 * Created by peter on 12/10/16.
 */
public class CommonDefines {
    public static final String appJoinKey = "YOUME5BE427937AF216E88E0F84C0EF148BD29B691556";

    public static final String appKey = "YOUMEBC2B3171A7A165DC10918A7B50A4B939F2A187D0";
    public static final String appSecret = "r1+ih9rvMEDD3jUoU+nj8C7VljQr7Tuk4TtcByIdyAqjdl5lhlESU0D+SoRZ30sopoaOBg9EsiIMdc8R16WpJPNwLYx2WDT5hI/HsLl1NJjQfa9ZPuz7c/xVb8GHJlMf/wtmuog3bHCpuninqsm3DRWiZZugBTEj2ryrhK7oZncBAAE=";

    public static final String LOG_TAG = "YOUME";

    public class ChannelState {
        public final static int IDLE = 0;
        public final static int INITIALIZING = 1;
        public final static int READY = 2;
        public final static int JOINING = 3;
        public final static int JOINED = 4;
        public final static int LEAVING = 5;
        public final static int LEAVED = 6;

    }
    public static String ChannelStateToString(int state) {
        switch (state) {
            case ChannelState.IDLE:
                return "未初始化";
            case ChannelState.INITIALIZING:
                return "正在初始化";
            case ChannelState.READY:
                return "初始化完成";
            case ChannelState.JOINING:
                return "正在加入";
            case ChannelState.JOINED:
                return "已加入";
            case ChannelState.LEAVING:
                return "正在退出";
            case ChannelState.LEAVED:
                return "已退出";
        }

        return "Invalid";
    }

    public class ActivityParamKey {
        public final static String debugMode = "debugMode";
        public final static String channelId = "channelId";
        public final static String userId = "userId";
        public final static String userRole = "userRole";
        public final static String regionId = "regionId";
        public final static String regionName = "regionName";
    }

    public static String ErrorCodeToString(int errCode) {
        switch (errCode) {
            case YouMeConst.YouMeErrorCode.YOUME_SUCCESS:
                return "成功";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_ALREADY_INIT:
                return "已经初始化过了";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_NOT_INIT:
                return "还没初始化";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_MEMORY_OUT:
                return "内存不够";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_START_FAILED:
                return "启动语音失败";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_STOP_FAILED:
                return "停止语音失败";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_ILLEGAL_SDK:
                return "无效的SDK";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_WRONG_STATE:
                return "状态不对, 此时不能调用这个API";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_NOT_ALLOWED_MOBILE_NETWROK:
                return "当前不允许使用移动网络通话";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_SERVER_INVALID:
                return "服务器无法连接";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_NETWORK_ERROR:
                return "网络错误";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_SERVER_INTER_ERROR:
                return "服务器内部错误";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_INVALID_PARAM:
                return "无效参数";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_REC_INIT_FAILED:
                return "麦克风初始化失败";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_REC_NO_PERMISSION:
                return "没有录音权限";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_REC_NO_DATA:
                return "麦克风没有输出";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_REC_OTHERS:
                return "未知麦克风错误";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_REC_PERMISSION_UNDEFINED:
                return "用户未选择麦克风权限";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_API_NOT_SUPPORTED:
                return "不支持这个API";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_CHANNEL_EXIST:
                return "相同ID的语音频道已经存在";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_CHANNEL_NOT_EXIST:
                return "指定ID的语音频道不存在";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_WRONG_CHANNEL_MODE:
                return "频道模式错误";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_TOO_MANY_CHANNELS:
                return "同时加入太多频道";

            case YouMeConst.YouMeErrorCode.YOUME_ERROR_GRABMIC_FULL:
                return "抢麦失败，人数满";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_GRABMIC_HASEND:
                return "抢麦失败，活动已结束";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_INVITEMIC_NOUSER:
                return "连麦失败，用户不存在";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_INVITEMIC_OFFLINE:
                return "连麦失败，用户已离线";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_INVITEMIC_REJECT:
                return "连麦失败，用户拒绝";
            case YouMeConst.YouMeErrorCode.YOUME_ERROR_INVITEMIC_TIMEOUT:
                return "连麦失败，超时";


            case YouMeConst.YouMeErrorCode.YOUME_ERROR_UNKNOWN:
                return "未知错误";
        }

        return "错误码:" + errCode;
    }

    public static String CallEventToString(int callEvent) {
        switch (callEvent) {
            case YouMeConst.YouMeEvent.YOUME_EVENT_INIT_OK:
                return "初始化成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INIT_FAILED:
                return "初始化失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_JOIN_OK:
                return "进入语音频道成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_JOIN_FAILED:
                return "进入语音频道失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_LEAVED_ONE:
                return "退出单个语音频道完成";
            case YouMeConst.YouMeEvent.YOUME_EVENT_LEAVED_ALL:
                return "退出所有语音频道完成";
            case YouMeConst.YouMeEvent.YOUME_EVENT_PAUSED:
                return "暂停语音完成";
            case YouMeConst.YouMeEvent.YOUME_EVENT_RESUMED:
                return "恢复语音完成";
            case YouMeConst.YouMeEvent.YOUME_EVENT_SPEAK_SUCCESS:
                return "改变当前讲话房间成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_SPEAK_FAILED:
                return "改变当前讲话房间失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_RECONNECTING:
                return "RECONNECTING";
            case YouMeConst.YouMeEvent.YOUME_EVENT_RECONNECTED:
                return "RECONNECTED";
            case YouMeConst.YouMeEvent.YOUME_EVENT_REC_FAILED:
                return "麦克风错误";
            case YouMeConst.YouMeEvent.YOUME_EVENT_BGM_STOPPED:
                return "背景音乐停止";
            case YouMeConst.YouMeEvent.YOUME_EVENT_BGM_FAILED:
                return "背景音乐失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_MIC_ON:
                return "OTHERS_MIC_ON";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_MIC_OFF:
                return "OTHERS_MIC_OFF";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_SPEAKER_ON:
                return "OTHERS_SPEAKER_ON";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_SPEAKER_OFF:
                return "OTHERS_SPEAKER_OFF";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_VOICE_ON:
                return "开始讲话";
            case YouMeConst.YouMeEvent.YOUME_EVENT_OTHERS_VOICE_OFF:
                return "停止讲话";


            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_START_OK:
                return "发起抢麦活动成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_START_FAILED:
                return "发起抢麦活动失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_STOP_OK:
                return "停止抢麦活动成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_STOP_FAILED:
                return "停止抢麦活动失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_REQUEST_OK:
                return "抢麦成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_REQUEST_FAILED:
                return "抢麦失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_REQUEST_WAIT:
                return "进入抢麦等待队列";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_RELEASE_OK:
                return "释放麦成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_RELEASE_FAILED:
                return "释放麦失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_ENDMIC:
                return "不再占有麦";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_NOTIFY_START:
                return "[通知]抢麦活动开始";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_NOTIFY_STOP:
                return "[通知]抢麦活动结束";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_NOTIFY_HASMIC:
                return "[通知]有麦可抢";
            case YouMeConst.YouMeEvent.YOUME_EVENT_GRABMIC_NOTIFY_NOMIC:
                return "[通知]无麦可抢";

            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_SETOPT_OK:
                return "连麦设置成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_SETOPT_FAILED:
                return "连麦设置失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_REQUEST_OK:
                return "请求连麦成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_REQUEST_FAILED:
                return "请求连麦失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_RESPONSE_OK:
                return "回应连麦成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_RESPONSE_FAILED:
                return "回应连麦失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_STOP_OK:
                return "结束连麦成功";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_STOP_FAILED:
                return "结束连麦失败";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_CAN_TALK:
                return "双方可以通话了";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_CANNOT_TALK:
                return "双方已不能通话";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_NOTIFY_CALL:
                return "[通知]请求连麦";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_NOTIFY_ANSWER:
                return "[通知]连麦回应";
            case YouMeConst.YouMeEvent.YOUME_EVENT_INVITEMIC_NOTIFY_CANCEL:
                return "[通知]结束连麦";

        }

        return "语音事件:" + callEvent;
    }

    public static String BroadcastMsgToString(int bctype) {
        switch (bctype){
            case YouMeConst.YouMeBroadcast.YOUME_BROADCAST_GRABMIC_BROADCAST_GETMIC:
                return "[抢麦广播]有人抢到了麦";
            case YouMeConst.YouMeBroadcast.YOUME_BROADCAST_GRABMIC_BROADCAST_FREEMIC:
                return "[抢麦广播]有人释放了麦";
            case YouMeConst.YouMeBroadcast.YOUME_BROADCAST_INVITEMIC_BROADCAST_CONNECT:
                return "[连麦广播]有人正在连麦";
            case YouMeConst.YouMeBroadcast.YOUME_BROADCAST_INVITEMIC_BROADCAST_DISCONNECT:
                return "[连麦广播]有人结束连麦";
        }
        return "广播消息:" + bctype;
    }

}

