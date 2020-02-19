function [freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main(input, t_smp, A_smp, t_ref, A_ref)
%% error checking

%% load and process data
if ~ isstruct(input)
    input = load_input(input);
end

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
freq = input.settings.freq_lo:input.settings.freq_step:input.settings.freq_hi;
spec_smp_disc = interp1(freq_smp, spec_smp, freq);
spec_ref_disc = interp1(freq_ref, spec_ref, freq);


figure(5)
plot(freq, unwrap(angle(spec_smp_disc))-unwrap(angle(spec_ref_disc)))
hold on
%plot(freq, unwrap(angle(spec_ref_disc)))

% calculate transfer function
tf_spec = spec_smp_disc./spec_ref_disc;


%% build transfer function 
% determine time cut off for etalons (relative to peak)
t_cut_exp = t_smp(end) - t_smp(find(A_smp == max(A_smp),1));
switch fft_sets.windowing_type
    case 'gauss'
        t_cut_wind = 3*fft_sets.windowing_width;
    case 'square' 
        t_cut_wind = fft_sets.windowing_width/2;
    otherwise
        t_cut_wind = Inf;
end

t_cut = min([t_cut_exp t_cut_wind]);

delay = t_smp(find(A_smp == max(A_smp),1)) - t_ref(find(A_ref == max(A_ref),1));
fprintf('Delay = %0.3f\n', delay)
n_est = estimate_n(delay, input);

func_smp = build_transfer_function(input.sample, 't_cut', t_cut);
func_ref = build_transfer_function(input.reference, 't_cut', t_cut);
func = @(freq, n_solve) func_smp(freq, n_solve)/func_ref(freq, n_solve);

%% perform fitting
n_fit = zeros(2, numel(freq));

if real(n_est) < 0
    n_est = 1;
end
k_mean = mean([min(freq) max(freq)])*2*pi*1e12/3e14;
d_inds = find(strcmp({input.sample.n}, 'solve'));
d_tot = sum(arrayfun(@(ii) input.sample(ii).d, d_inds))
n_prev = [real(n_est) log(mean(abs(tf_spec)))/(d_tot*k_mean)]
%n_prev = [10 -10];

for ii = 1:numel(freq)
    %err = @(n) abs(func(freq(ii), complex(n(1), n(2)))-tf_spec(ii));
    err = @(n) n_error(func(freq(ii), complex(n(1), n(2))), tf_spec(ii));
    opts = optimset();
    n_opt = fminsearch(err, n_prev, opts);
    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
    fprintf('%0.2f THz: n = %s\n', freq(ii), num2str(complex(n_opt(1), n_opt(2))))
end

 tf_pred = arrayfun(@(ii) func(freq(ii), complex(n_fit(1,ii), n_fit(2, ii))), 1:numel(freq));
end


function [chi] = n_error(t1, t2)
err_ang = angle(t1)-angle(t2);
err_trn = log(abs(t1))-log(abs(t2));
chi = err_ang^2 + err_trn^2;
%chi = norm(t1-t2);
end