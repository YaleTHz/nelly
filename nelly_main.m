function [freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func]...
    = cordouan_main(input_file_name, t_smp, A_smp, t_ref, A_ref)
%% error checking

%% load and process data
input = load_input(input_file_name);

%% check time ranges, and pad as necessary
[t, A_smp_pad, A_ref_pad] = time_pad(t_smp, A_smp, t_ref, A_ref);

%remove offset to avoid artificial drop upon zero padding
A_smp_pad = A_smp_pad - A_smp_pad(end);
A_ref_pad = A_ref_pad - A_ref_pad(end);


%% calculate experimental transfer function
% fourier transform time domain data
[freq_smp, spec_smp] = fft_func(t, A_smp_pad, input.settings.fft);
[freq_ref, spec_ref] = fft_func(t, A_ref_pad, input.settings.fft);

freq_full = freq_ref;
tf_full = spec_smp./spec_ref;

% discretize
freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;
spec_smp_disc = interp1(freq_smp, spec_smp, freq);
spec_ref_disc = interp1(freq_ref, spec_ref, freq);

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;

%% build transfer function 
t_cut = t_smp(end) - t_smp(A_smp == max(A_smp));
func_smp = build_transfer_function(input.sample, 0);
func_ref = build_transfer_function(input.reference, 0);
func = @(freq, n_solve) func_smp(freq, n_solve)/func_ref(freq, n_solve);

%% perform fitting
n_fit = zeros(2, numel(freq));
n_prev = [2 -0.5];

for ii = 1:numel(freq)
    err = @(n) abs(func(freq(ii), complex(n(1), n(2)))-tf_spec(ii));
    %err = @(n) abs(f_ana(freq(ii), complex(n(1), n(2)))-tf_spec(ii));
    opts = optimset('PlotFcns', @optimplotfval);
    n_opt = fminsearch(err, n_prev, opts);
    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
    fprintf('%0.2f THz: n = %s\n', freq(ii), num2str(complex(n_opt(1), n_opt(2))))
end

 tf_pred = arrayfun(@(ii) func(freq(ii), complex(n_fit(1,ii), n_fit(2, ii))), 1:numel(freq));
end