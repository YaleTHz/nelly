function [freq, tf_spec, freq_full, tf_full, spec_smp, spec_ref] = exp_tf(t_smp, A_smp, t_ref, A_ref, input)
%% check time ranges, and pad as necessary
[t, A_smp_pad, A_ref_pad] = time_pad(t_smp, A_smp, t_ref, A_ref);

%remove offset to avoid artificial drop upon zero padding
A_smp_pad = A_smp_pad - A_smp_pad(end);
A_ref_pad = A_ref_pad - A_ref_pad(end);


%% calculate experimental transfer function
% fourier transform time domain data
fft_sets = input.settings.fft;
[freq_smp, spec_smp] = fft_func(t, A_smp_pad, fft_sets);
[freq_ref, spec_ref] = fft_func(t, A_ref_pad, fft_sets);

freq_full = freq_ref;
tf_full = spec_smp./spec_ref;


% discretize
spec_smp = spec_smp(freq_full <= input.settings.freq_hi);
spec_ref = spec_ref(freq_full <= input.settings.freq_hi);
freq_full = freq_full(freq_full <= input.settings.freq_hi);

freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;

spec_smp_disc = disc(freq_full,spec_smp, freq);
spec_ref_disc = disc(freq_full,spec_ref, freq);

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;


    function [disc_y] = disc(x,y, x_new)
        dx = mean(diff(x));
        disc_y = ones(1, length(x_new));
        
        for ii = 1:length(x_new)
            inds = x >= x_new(ii)-dx & x <= x_new(ii) + dx;
            disc_y(ii) = mean(y(inds));
        end
    end
end
