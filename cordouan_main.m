function [n_fit] = cordouan_main(input_file_name, t_smp, A_smp, t_ref, A_ref)
%% error checking

%% load and process data
input = load_input(input_file_name);

%% check time ranges, and pad as necessary
[t, A_smp_pad, A_ref_pad] = time_pad(t_smp, A_smp, t_ref, A_ref);

%% calculate experimental transfer function
% fourier transform time domain data
[freq_smp, spec_smp] = fft_func(t, A_smp_pad, input.settings.fft);
[freq_ref, spec_ref] = fft_func(t, A_ref_pad, input.settings.fft);

% discretize
freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;
spec_smp_disc = interp1(freq_smp, spec_smp, freq);
spec_ref_disc = interp1(freq_ref, spec_ref, freq);

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;

%% build transfer function 
[func, ~] = build_transfer_function(input.layers);

%% perform fitting
n_fit = zeros(2, numel(freq));
n_prev = [5 0];

for ii = 1:numel(freq)
    err = @(n) abs(func(freq(ii), complex(n(1), n(2)))-tf_spec(ii));
    opts = optimset('PlotFcns', @optimplotfval);
    n_opt = fminsearch(err, n_prev, opts);
    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
    fprintf('%0.2f THz: n = %s\n', freq(ii), num2str(complex(n_opt(1), n_opt(2))))
end

end