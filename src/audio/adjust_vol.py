import wave
#import matplotlib.pyplot as plt
import numpy as np
import sys




def adjust_vol(input_wav, output_wav, amp):
    """
    将输入音频的振幅缩放到amp范围内，结果写入output_wav
    :param input_wav:
    :param output_wav:
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
    print(max(abs(waveData)))
    # wave幅值归一化
    waveData = waveData * 1.0 / (max(abs(waveData)) * (1.0 / amp))
    f.close()


    ff = wave.open(output_wav, "wb")
    ff.setnchannels(nchannels)
    ff.setsampwidth(sampwidth)
    ff.setframerate(framerate)
    # 将wav_data转换为二进制数据写入文件
    waveData = waveData.astype(np.int16)
    ff.writeframes(waveData.tobytes())
    ff.close()
    print(input_wav + " 处理完成！")
    # plot the wave
    # time = np.arange(0, nframes) * (1.0 / framerate)
    # plt.plot(time, waveData)
    # plt.xlabel("Time(s)")
    # plt.ylabel("Amplitude")
    # plt.title("Single channel wavedata")
    # plt.grid('on')  # 标尺，on：有，off:无。
    # plt.show()

def is_low_vol(input_wav, amp):
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
    print (input_wav)
    print (amp)
    if max(abs(waveData)) < amp:
        print (input_wav +"最大振幅小于" + amp)




if __name__ == '__main__':
    input_wav = sys.argv[1]
    output_wav = sys.argv[2]
    amp_org = sys.argv[3]
    amp = int (amp_org)
    adjust_vol(input_wav, output_wav, amp)
    #is_low_vol(input_wav, amp)
