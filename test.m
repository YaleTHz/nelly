%% test that all files are present
files = {'cordouan_main',
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

a_gauss = TD_window(t, a, 'gauss' ,3);

N = 2132;
[freq, spec] = fft_func(t,a_gauss, N, 'none', 1);
[freq_gauss, spec_gauss] = fft_func(t, a, N, 'gauss', 3);

assert(sum(spec_gauss ~= spec) == 0)

