import wave
import numpy as np
import sys
def adjust_vol(input_wav, output_wav, amp):
    """
    :param input_wav:
    :param output_wav:
    :param amp:
    :return:
    """
    f = wave.open(input_wav, 'rb')
    params = f.getparams()
    nchannels, sampwidth, framerate, nframes = params[:4]
    strData = f.readframes(nframes)
    waveData = np.frombuffer(strData, dtype=np.int16)
    f.close()
    try:
        max_amp = max(abs(waveData))
        if max_amp > amp:
            waveData = waveData * 1.0 / (max(abs(waveData)) * (1.0 / amp))
    except:
        pass
    ff = wave.open(output_wav, "wb")
    ff.setnchannels(nchannels)
    ff.setsampwidth(sampwidth)
    ff.setframerate(framerate)
    waveData = waveData.astype(np.int16)
    ff.writeframes(waveData.tobytes())
    ff.close()


if __name__ == '__main__':
    input_wav = sys.argv[1]
    output_wav = sys.argv[2]
    amp_org = sys.argv[3]
    amp = int (amp_org)
    adjust_vol(input_wav, output_wav, amp)

