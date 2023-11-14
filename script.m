% dependencys
pkg load signal;
pkg load control;

% global
fs = 44100; %  44,1 kHz
fc_low = 0; % freq inicial de corte para freq baixas, Hz, !graves;
fc_medium = 250; % freq inicial de corte para freq medias, Hz, !medios;
fc_high = 2000; % freq inicial de corte para freq altas, hz, !agudos;
time = 5; % record duration in seconds

% Criando um sinal senoidal de teste!!!!
t = 0:1/6000:time; % Vetor de tempo
%f = 150; % Frequência do sinal senoidal
%x = sin(2*pi*f*t);
%noise = randn(1,length(x));
%y + noise
%signal = x + noise;

% uncomment this if want to create a new file;
% add print to show when the process start!
filename = "out";
%setRec("out.wav", 5, fs);
%% Substituir pelo sinal de voz gravado
[x, ] = getRec(strcat(filename, '.wav')); %fs was defined in the start of the script

% FIR
ripple_max = 1; % Ripple máximo na banda de passagem (em dB)
attenuation = 60; % Atenuação na banda de rejeição (em dB)
transition_width = 1; % Largura da banda de transição (em oitavas)

% IRR


% frequências de corte
passband_low_freq = fc_low; % banda de passagem 
stopband_low_freq = 250; % banda de rejeição 
passband_medium_freq = fc_medium; % banda de passagem 
stopband_medium_freq = 2000; % banda de rejeição 
passband_high_freq = fc_high; % banda de passagem 
stopband_high_freq = 20000; % banda de rejeição 

% segundo o professor!
% Filtro passa-baixas - banda passante 0 a 250 Hz (faixa de graves) 
% Filtro passa-faixa - banda passante: 250 a 2 kHz (faixa de médios)
% Filtro passa-alta - banda passante: 2 kHz a 20 kHz (faixa de agudos) 

% segundo pesquisas!
% graves 20-250 hz
% medios 250-5000 hz
% agudos 5000-20000 hz

% Calculando as frequências normalizadas
passband_low_normalized = passband_low_freq / (fs/2);
stopband_low_normalized = stopband_low_freq / (fs/2);
passband_medium_normalized = passband_medium_freq / (fs/2);
stopband_medium_normalized = stopband_medium_freq / (fs/2);
passband_high_normalized = passband_high_freq / (fs/2);
stopband_high_normalized = stopband_high_freq / (fs/2);

% Calculando a ordem do filtro usando a regra de Kaiser
%order_fir_low = kaiserord([passband_low_normalized, stopband_low_normalized], [1, 0], [ripple_max, attenuation]);
%order_fir_medium = kaiserord([passband_medium_normalized, stopband_medium_normalized], [1, 0], [ripple_max, attenuation]);
%order_fir_high = kaiserord([passband_high_normalized, stopband_high_normalized], [1, 0] , [ripple_max, attenuation]);
order_fir_low = 550;
order_fir_medium = 550;
order_fir_high = 550;
% print the orders for comparison!!

% Criando filtros
fir_low_filter = fir1(order_fir_low, [passband_low_normalized, stopband_low_normalized], kaiser(order_fir_low+1, ripple_max));
fir_medium_filter = fir1(order_fir_medium, [passband_medium_normalized, stopband_medium_normalized], kaiser(order_fir_medium+1, ripple_max));
fir_high_filter = fir1(order_fir_high, [passband_high_normalized, stopband_high_normalized], kaiser(order_fir_high+1,  ripple_max));

% Projeto do filtro IIR passa-baixa
[b_low, a_low] = butter(6, stopband_low_normalized, 'low');

% Aplicação do filtro IIR passa-baixa no sinal de áudio gravado
voiceFilteredLowIIR = filter(b_low, a_low, x);

% Projeto do filtro IIR passa-faixa
[b_mid, a_mid] = butter(6, [stopband_medium_normalized, stopband_high_normalized], 'bandpass');

% Aplicação do filtro IIR passa-faixa no sinal de áudio gravado
voiceFilteredMidIIR = filter(b_mid, a_mid, x);

% Projeto do filtro IIR passa-alta
[b_high, a_high] = butter(6, stopband_high_normalized, 'high');

% Aplicação do filtro IIR passa-alta no sinal de áudio gravado
voiceFilteredHighIIR = filter(b_high, a_high, x);

% Aplicando filtros
filtered_low_fir = filter(fir_low_filter, 1, x);
filtered_medium_fir = filter(fir_medium_filter, 1, x);
filtered_high_fir = filter(fir_high_filter, 1, x);

%Resposta ao Impulso para filtros FIR
impulse_response_low_fir = impz(fir_low_filter);
impulse_response_medium_fir = impz(fir_medium_filter);
impulse_response_high_fir = impz(fir_high_filter);

%Resposta ao Impulso para filtros IIR
impulse_response_low_iir = impz(b_low, a_low);
impulse_response_medium_iir = impz(b_mid, a_mid);
impulse_response_high_iir = impz(b_high, a_high);

%Plotagem resposta ao impulso para filtros FIR
figure;
subplot(3,1,1);
stem(impulse_response_low_fir);
title('Resposta ao Impulso - FIR|LOW');

subplot(3,1,2);
stem(impulse_response_medium_fir);
title('Resposta ao Impulso - FIR|MEDIUM');

subplot(3,1,3);
stem(impulse_response_high_fir);
title('Resposta ao Impulso - FIR|HIGH');

% Plotagem resposta ao impulso para filtros IIR
figure;
subplot(3,1,1);
stem(impulse_response_low_iir);
title('Resposta ao Impulso - IIR|LOW');

subplot(3,1,2);
stem(impulse_response_medium_iir);
title('Resposta ao Impulso - IIR|MEDIUM');

subplot(3,1,3);
stem(impulse_response_high_iir);
title('Resposta ao Impulso - IIR|HIGH');

% plotagem sinal de entrada e ruido
figure;
subplot(2,1,1);
plot(x);
title('Original');

subplot(2,1,2);
stem(abs(fft(x)));
title('Sinal Original (Magnitude)');

% Plotagem FIR FIltros
figure;
freqz(fir_low_filter, 1, 1024, fs);
title('Filtro Passa-Baixa ( 0-250 hz )');

figure;
freqz(fir_medium_filter, 1, 1024, fs);
title('Filtro Passa-faixa ( 250-2000 hz )');

figure;
freqz(fir_high_filter, 1, 1024, fs);
title('Filtro Passa-Alta ( 2000/20000 hz )');

% Plotagem FIR Sinais filtrados
figure;
subplot(3,1,1);
stem(filtered_low_fir);
title('Sinal Filtrado com FIR/LOW');

subplot(3,1,2);
stem(filtered_medium_fir);
title('Sinal Filtrado com FIR/MEDIUM');

subplot(3,1,3);
stem(filtered_high_fir);
title('Sinal Filtrado com FIR/HIGH');

% Plotagem dos sinais filtrados IIR
figure;
subplot(3,1,1);
stem(voiceFilteredLowIIR);
title('Sinal Filtrado com IIR/Baixo');

subplot(3,1,2);
stem(voiceFilteredMidIIR);
title('Sinal Filtrado com IIR/Médio-Alto');

% Save the filtered signal to a .wav file
audiowrite(strcat(filename,"_fir_low.wav"), filtered_low_fir, fs);
audiowrite(strcat(filename,"_fir_medium.wav"), filtered_medium_fir, fs);
audiowrite(strcat(filename,"_fir_high.wav"), filtered_high_fir, fs);