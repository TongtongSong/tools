import sys
import torch
import torchaudio # >=0.9.0
import random
resample_rate=int(sys.argv[1])
min_sli=float(sys.argv[2])
max_sli=float(sys.argv[3])
wav_list=sys.argv[4:-1]
dst_wav=sys.argv[-1]
torchaudio.set_audio_backend("sox_io")
for idx,wav_path in enumerate(wav_list):
    waveform, sample_rate = torchaudio.load(wav_path)
    assert waveform.shape[0]==1
    if sample_rate!=resample_rate:
        waveform = torchaudio.transforms.Resample(
            orig_freq=sample_rate, new_freq=resample_rate)(waveform)
        sample_rate = resample_rate
    sli_time=random.uniform(min_sli,max_sli)
    sli_wav=torch.zeros((1,int(sli_time*sample_rate)))
    waveform = torch.cat((sli_wav, waveform), dim=1)
    if idx==0:
        dst_waveform = waveform
    else:
        dst_waveform=torch.cat((dst_waveform,waveform),dim=1)
    if idx == len(wav_list) - 1:
        sli_time = random.uniform(min_sli, max_sli)
        sli_wav = torch.zeros((1, int(sli_time * sample_rate)))
        dst_waveform = torch.cat((dst_waveform, sli_wav), dim=1)
        torchaudio.save(dst_wav, dst_waveform, sample_rate,format='wav',bits_per_sample=16,encoding='PCM_S')



