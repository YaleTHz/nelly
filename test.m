%% test that all files are present
files = {'nelly_main',
    'faxis',
    'fft_func'
    'load_input'
    'TD_window'};
check_file_exists = @(fname) assert(exist(fname)==2, '%s missing', fname);
cellfun(check_file_exists, files)

%% test that windowing prior to fft gives same result as windowing during fft
path = 'C:\Users\utayv\OneDrive\Desktop\grad\research\data\thz-data\2019_12_06\Dec06_';
data = importdata([path '001.tim']);


t = data(:,1);
a = data(:,2);
opts_gauss = struct('windowing_type', 'gauss', 'windowing_width', 3, 'padding', 2132);
opts_none = struct('windowing_type', 'none', 'windowing_width', 3, 'padding', 2132);

a_gauss = TD_window(t, a, 'gauss' ,3);

N = 2132;
[freq, spec] = fft_func(t,a_gauss, opts_none);
[freq_gauss, spec_gauss] = fft_func(t, a, opts_gauss);

assert(sum(spec_gauss ~= spec) == 0)

%% test that transfer function is the same for two layers of substrate vs. one 
% layer of the same thickness
