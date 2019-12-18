function [n] = cordouan_main(input_file_name, t_smp, A_smp, t_ref, A_ref)
%% error checking
%assert(t_smp(1) == t_ref(1), 'Time domain traces must start at the same time');

%% load data
input = load_input(input_file_name);

%% calculate experimental transfer function
% fourier transform time domain data
[freq_smp, spec_smp] = fft_func(t_smp, A_smp, input.settings.fft);
[freq_ref, spec_ref] = fft_func(t_ref, A_ref, input.settings.fft);


% discretize (maybe put in its own function)
freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;
spec_smp_disc = interp1(freq_smp, spec_smp, freq);
spec_ref_disc = interp1(freq_ref, spec_ref, freq);

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;

%% build transfer function 
func = build_transfer_function(input);

%f(w, n_solve)
func(0.2, 4)
% 
% %% loop over data points
% 
% for % freq in frequency range
%     %something like:
%     n(freq) = fmincom(@(n) transferFunction(n, freq), ...)
% end
end