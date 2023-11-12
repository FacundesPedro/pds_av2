function [audiodata, fs] = getRec (filename = 'out.wav')
  [audiodata, fs] = audioread(filename);
endfunction