function [freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref, smp_full, ref_full] = exp_tf(t_smp, A_smp, t_ref, A_ref, input)
% EXP_TF    Fourier transform time-domain traces and calculate transfer
% functions
% 
% [freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref] = ...
%          EXP_TF(t_smp, A_smp, t_ref, A_ref, input) Fourier transforms the
% time domain traces (t_smp, A_smp) and (t_ref, A_ref). input is a struct
% which follows the input file format, and specifies the frequency points,
% zero padding, and windowing for the Fourier transform. 
% OUTPUT
% freq      -- the frequencies points corresponding to the transfer function
% output tf_spec
% tf_spec   -- the transfer function (E_smp(freq)/E_ref(freq)) at the
% frequency points specified in freq
% freq_full -- the full range of frequency points resulting from the
% zero-padded time traces
% tf_full   -- the transfer function (E_smp(freq)/E_ref(freq)) at the
% frequency points specified in freq_full
% spec_smp  -- the Fourier transform of the sample time trace (t_smp,
% A_smp) at the frequencies specied in freq
% spec_ref  -- the Fourier transform of the reference time trace (t_ref,
% A_ref) at the frequencies specified in freq

%% check time ranges, and pad as necessary
[t, A_smp_pad, A_ref_pad] = time_pad(t_smp, A_smp, t_ref, A_ref);

%% calculate experimental transfer function
% fourier transform time domain data
fft_sets = input.settings.fft;

%[freq_smp, spec_smp] = fft_func(t, A_smp_pad, fft_sets);
%[freq_ref, spec_ref] = fft_func(t, A_ref_pad, fft_sets);
[freq_smp, spec_smp] = fft_func(t, A_smp, fft_sets);
[freq_ref, spec_ref] = fft_func(t, A_ref, fft_sets);

freq_full = freq_ref;
tf_full = spec_smp./spec_ref;


% discretize
spec_smp = spec_smp(freq_full <= input.settings.freq_hi);
spec_ref = spec_ref(freq_full <= input.settings.freq_hi);
smp_full = spec_smp;
ref_full = spec_ref;
freq_full = freq_full(freq_full <= input.settings.freq_hi);
tf_full = tf_full(freq_full <= input.settings.freq_hi);

freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;

spec_smp_disc = disc(freq_full,spec_smp, freq);
spec_ref_disc = disc(freq_full,spec_ref, freq);

spec_smp = spec_smp_disc;
spec_ref = spec_ref_disc;

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;


    function [disc_y] = disc(x,y, x_new)
        dx = mean(diff(x));
        disc_y = ones(1, length(x_new));
        
        for ii = 1:length(x_new)
            inds = x >= (x_new(ii)-dx/2) & x < (x_new(ii) + dx/2);
            disc_y(ii) = mean(y(inds));
        end
    end
end
