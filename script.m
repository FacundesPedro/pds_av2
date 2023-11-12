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
t = 0:1/10:time; % Vetor de tempo
f = 2500; % Frequência do sinal senoidal
x = sin(2*pi*f*t);
noise = randn(1,length(x));
%y + noise
signal = x + noise;
% uncomment this if want to create a new file;
% add print to show when the process start!

%setRec("out.wav", 5, fs);
%% Substituir pelo sinal de voz gravado
%[x, ] = getRec(); %fs was defined in the start of the script

% FIR
ripple_max = 1; % Ripple máximo na banda de passagem (em dB)
attenuation = 60; % Atenuação na banda de rejeição (em dB)
transition_width = 1; % Largura da banda de transição (em oitavas)

% IRR

%% Substituir pelo sinal de voz gravado
%[x, ] = getRec(); %fs was defined in the start of the script

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
order_fir_low = kaiserord([passband_low_normalized, stopband_low_normalized], [1, 0], [ripple_max, attenuation]);
order_fir_medium = kaiserord([passband_medium_normalized, stopband_medium_normalized], [1, 0], [ripple_max, attenuation]);
order_fir_high = kaiserord([passband_high_normalized, stopband_high_normalized], [1, 0], [ripple_max, attenuation]);
% print the orders for comparison!!

% Criando filtros
fir_low_filter = fir1(order_fir_low, [passband_low_normalized, stopband_low_normalized], kaiser(order_fir_low+1, ripple_max));
fir_medium_filter = fir1(order_fir_medium, [passband_medium_normalized, stopband_medium_normalized], kaiser(order_fir_medium+1, ripple_max));
fir_high_filter = fir1(order_fir_high, [passband_high_normalized, stopband_high_normalized], kaiser(order_fir_high+1, ripple_max));

% Aplicando filtros
filtered_low_fir = filter(fir_low_filter, 1, signal);
filtered_medium_fir = filter(fir_medium_filter, 1, signal);
filtered_high_fir = filter(fir_high_filter, 1, signal);

% Plotagem
figure;
freqz(fir_low_filter, 1, 1024, fs);
title('Filtro Passa-Baixa ( 0-250 hz )');

figure;
freqz(fir_medium_filter, 1, 1024, fs);
title('Filtro Passa-faixa ( 250-2000 hz )');

figure;
freqz(fir_high_filter, 1, 1024, fs);
title('Filtro Passa-Alta ( 2000/20000 hz )');

figure;
subplot(2,1,1);
plot(t, signal);
title('Sinal Original');

subplot(2,1,2);
plot(t, filtered_low_fir);
title('Sinal Filtrado com FIR/LOW');

subplot(2,1,3);
plot(t, filtered_medium_fir);
title('Sinal Filtrado com FIR/MEDIUM');

subplot(2,1,4);
plot(t, filtered_high_fir);
title('Sinal Filtrado com FIR/HIGH');