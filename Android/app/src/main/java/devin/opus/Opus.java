package devin.opus;

import android.util.Log;

public class Opus {
    public Opus() {
    }

    /**
     * 注册
     * @param frameSampleRate 每帧采样率
     * @param bitrate_bps 比特率,表示单位时间（1秒）内传送的比特数bps（bit per second，位/秒）的速度
     * @param complexity 复杂度(1-10)
     * @param frameSize 每帧数据大小
     */
    public void register(int frameSampleRate, int bitrate_bps, int complexity, int frameSize) {
        try {
            System.loadLibrary("opus");
            Log.i("Opus:","Library load successful");
        } catch (Throwable e) {
            e.printStackTrace();
            Log.e("Opus:","Library load failure");
        }

        try {
            if(init(frameSampleRate, bitrate_bps, complexity, frameSize))
            {
                Log.i("Opus:","Initial library success");
            }
            else
            {
                Log.e("Opus:","Library initial failure");
            }
        }
        catch (Throwable e) {
            e.printStackTrace();
            Log.e("Opus:","Library initial failure");
        }
    }

    public native int test();

    /**
     * 初始Opus
     * @param frameSampleRate 每帧采样率
     * @param bitrate_bps 比特率,表示单位时间（1秒）内传送的比特数bps（bit per second，位/秒）的速度
     * @param complexity 复杂度(1-10)
     * @param frame_size 每帧数据大小
     * @return 初始成功返回true,否则为false
     */
    public native boolean init(int frameSampleRate, int bitrate_bps, int complexity, int frame_size);

    /**
     * 编码
     * @param srcIn 输入源
     * @param encodeOut 输出编码后的目标数据
     * @return 编码后的真实长度
     */
    public native int encode(short[] srcIn, byte[] encodeOut); // 压缩数据，长度为320short->40byte

    /**
     * 解码
     * @param encodeIn 已编码的输入源
     * @param decodeOut 输出解码后的输出目标数据
     * @param encoderInSize 已编码的源数据长度
     * @return 解码后的真实长度
     */
    public native int decode(byte[] encodeIn, short[] decodeOut, int encoderInSize);// 解压缩数据，长度为40byte->320short

    /**
     * 释放并销毁
     */
    public native boolean destroy();
}
