package devin.opus;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

import java.util.Vector;

public class MainActivity extends AppCompatActivity {

    Log log;
    private Button Start;
    private Button Stop;
    private boolean isStart;

    private static OpusNative opus =new OpusNative();
    private short[] tempBuffer;
    private AudioRecord audioRecord;
    private AudioTrack audioTrack;

    private int audioChannels =  AudioFormat.CHANNEL_IN_MONO;
    private static final int FRAME_SIZE=320;
    private static final int COMPLEXITY=8;
    private static final int FRAME_SAMPLE_RATE=8000;
    private static final int BITRATE_BPS=8000;

    static {
        opus.register(FRAME_SAMPLE_RATE, BITRATE_BPS, COMPLEXITY, FRAME_SIZE);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        init();
    }

    private void init() {
        Start = (Button) this.findViewById(R.id.button1);
        Stop = (Button) this.findViewById(R.id.button2);
        Start.setOnClickListener(new TestAudioListener());
        Stop.setOnClickListener(new TestAudioListener());
    }

    class TestAudioListener implements OnClickListener {

        @Override
        public void onClick(View v) {
            if (v == Start) {
                Log.e("TestOpus:","Start");
                isStart = true;
                startAudioRecord();
            }
            if (v == Stop) {
                Log.e("TestOpus:","Stop");
                isStart = false;
            }
        }
    }

    private void startAudioRecord(){

        new Thread(new Runnable() {
            @Override
            public void run() {
                try{
                    encodes.clear();
                    decodes.clear();
                    tempBuffer = new short[FRAME_SIZE];
                    byte[] encodeBuf = new byte[FRAME_SIZE];

                    if(audioRecord==null)
                    {
                        audioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC,FRAME_SAMPLE_RATE,  audioChannels, AudioFormat.ENCODING_PCM_16BIT, FRAME_SIZE*2);//
                        audioRecord.startRecording();
                    }

                    isStart = true;
                    while (isStart) {
                        int bufferRead = audioRecord.read(tempBuffer, 0, FRAME_SIZE);
                        int ret3 = opus.encode(tempBuffer, encodeBuf);
                        Log.e("TestOpus:",encodes.size()+": bufferRead:"+bufferRead+" encode ret1:"+ret3);
                        byte[] newEncodeBytes=new byte[ret3];
                        System.arraycopy(encodeBuf, 0, newEncodeBytes, 0, ret3);
                        encodes.add(newEncodeBytes);

//                        if(encodes.size()>500)
//                        {
//                            isStart=false;
//                        }
                    }
                    int t=encodes.size()*40;
                    Log.e("TestOpus:","总长："+t);
                    audioRecord.stop();
                    audioRecord.release();
                    audioRecord = null;
                    playAudio();
                }catch (Throwable t) {
                    t.printStackTrace();
                    Log.e("TestOpus:","录音失败");
                }
            }
        }).start();
    }

    private Vector<byte[]> encodes=new Vector<byte[]>();
    private Vector<short[]> decodes=new Vector<short[]>();
    private void playAudio()
    {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
//                    bufferSize = AudioTrack.getMinBufferSize(FRAME_SAMPLE_RATE, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT);
                    if(audioTrack==null)
                    {
                        audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, FRAME_SAMPLE_RATE, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT, FRAME_SIZE, AudioTrack.MODE_STREAM);
                        audioTrack.play();
                    }

                    Log.e("TestOpus:", "playAudio run");
                    for (byte[] b : encodes) {
                        short[] decodeBuf = new short[FRAME_SIZE];
                        int ret2 = opus.decode(b, decodeBuf, b.length);
                        Log.e("TestOpus:", "playAudio decode ret2:" + ret2);
                        short[] decodeBuf2 = new short[ret2];
                        System.arraycopy(decodeBuf, 0, decodeBuf2, 0, ret2);
                        decodes.add(decodeBuf2);
                    }

                    short[] playBuf;
                    while (decodes.size()>0)
                    {
                        playBuf=decodes.remove(0);
                        audioTrack.write(playBuf, 0, playBuf.length);
                        Log.e("TestOpus:","audioTrack write playBuf.length:"+playBuf.length);
                    }
                } catch (Throwable t) {
                    t.printStackTrace();
                    Log.e("TestOpus:", "播放失败");
                }
                audioTrack.stop();
                audioTrack.release();
                audioTrack=null;
            }
        }).start();
    }

    @Override
    protected void onDestroy() {
        isStart = false;
        opus.destroy();
        opus=null;
        super.onDestroy();
    }
}
