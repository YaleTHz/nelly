% applies windowing (specified in input)and takes fourier transform of 
% given time domain data
function [freq, spec] = fft_func(time, amplitude, N, window_type, window_width)
amplitude_windowed = TD_window(time, amplitude, window_type, window_width);
freq = faxis(time, N);
spec = fft(amplitude_windowed,N);
end