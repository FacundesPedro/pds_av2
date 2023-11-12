function [audiodata, fs, nbits] = setRec (filename = "out.wav", time = 5, fs = 10000, nbits = 16, nchannel = 2) 
  # cria o gravador
  # nchannel - numero de canais de audio (1 - mono, 2 - stereo);
  # fs - freq de amostragem;
  rec = audiorecorder (fs, nbits, nchannel);

  # grave sua linda voz por 'time' segundos
  recordblocking (rec, time);
  
  audiodata = getaudiodata (rec);
  
   % generate mat and wav files;
   % save -mat out.mat audiodata fs
   audiowrite(filename, audiodata, fs); 
  
endfunction   