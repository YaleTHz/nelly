% applies windowing (specified in input)and takes fourier transform of 
% given time domain data
function [freq, spec] = fft_func(time, amplitude, options)
amplitude_windowed = TD_window(time, amplitude, ...
    options.windowing_type, options.windowing_width);
freq = faxis(time, 2^options.padding);
spec = fft(amplitude_windowed, 2^options.padding);
end