% FIR
ripple_max = 1; % Ripple máximo na banda de passagem (em dB)
attenuation = 60; % Atenuação na banda de rejeição (em dB)
transition_width = 1; % Largura da banda de transição (em oitavas)

% IRR

% global
fs = 44100; %  44,1 kHz
fc_low = 20; % freq inicial de corte para freq baixas, Hz, !graves;
fc_medium = 250; % freq inicial de corte para freq medias, Hz, !medios;
fc_high = 5000; % freq inicial de corte para freq altas, hz, !agudos;

%% Substituir pelo sinal de voz gravado
%x = sin(2*pi*f*t);

% frequências de corte
passband_low_freq = fc_low; % banda de passagem 
stopband_low_freq = 250; % banda de rejeição 
passband_medium_freq = fc_medium; % banda de passagem 
stopband_medium_freq = 5000; % banda de rejeição 
passband_high_freq = fc_high; % banda de passagem 
stopband_high_freq = 20000; % banda de rejeição 

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
order = kaiserord([passband_normalized, stopband_normalized], [1, 0], [ripple_max, attenuation]);
% Criando filtros
fir_filter = fir1(order, [passband_normalized, stopband_normalized], kaiser(order+1, ripple_max));
% Aplicando filtros
filtered_x_fir = filter(fir_filter, 1, x);


% Plotagem
freqz(fir_filter, 1, 1024, fs);