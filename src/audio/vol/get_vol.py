import sys
import wave
import numpy as np
def _vol(input_wav):
    """
    判断输入的音频最大振幅是不是小于amp
    :param input_wav:
    :param amp:
    :return:
    """
    f = wave.open(input_wav, 'rb')
    params = f.getparams()
    nchannels, sampwidth, framerate, nframes = params[:4]
    # 读取音频，字符串格式
    strData = f.readframes(nframes)
    # 将字符串转化为int
    waveData = np.frombuffer(strData, dtype=np.int16)
    f.close()
    try:
        print(max(abs(waveData)))
    except:
        pass

if __name__ == '__main__':
    input_wav = sys.argv[1]
    _vol(input_wav)
