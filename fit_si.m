%% load data/input
% load data--d_ref is air, d_smp is si
load test.mat

input = load_input('sample_files/sample_input.json');

t_ref= d_ref(:,1); A_ref = d_ref(:,2);
t_smp= d_smp(:,1); A_smp = d_smp(:,2);

dt = mean([mean(diff(t_ref)) mean(diff(t_smp))]);
%%  pad to match timescales
t_smp_pad = min(t_ref):dt:min(t_smp)-dt;
t_ref_pad = max(t_ref)+dt:dt:max(t_smp);

A_smp_pad = A_smp(1)*ones(numel(t_smp_pad),1);
A_ref_pad = A_ref(end)*ones(numel(t_ref_pad), 1);

t_ref = [t_ref; t_ref_pad']; A_ref = [A_ref; A_ref_pad];
t_smp = [t_smp_pad'; t_smp]; A_smp = [A_smp_pad; A_smp];

%% experimental transfer function
[freq_ref, spec_ref] = fft_func(t_ref,A_ref, input.settings.fft);
[freq_smp, spec_smp] = fft_func(t_smp,A_smp, input.settings.fft);


tf_exp = spec_smp./spec_ref;

%% generate transfer function
[func, prop_func] = build_transfer_function(input.layers);

%% fit to experimental transfer function
sets = input.settings;
freq = sets.freq_lo:sets.freq_step:sets.freq_hi;
n_fit = zeros(2,numel(freq));

n_prev = [5 0];

disc_tf_exp = zeros(size(freq));

for ii = 1:numel(freq)
    % find nearest experimental point
    ind = find(freq_ref > freq(ii),1);
    fprintf('at %0.3f (%0.3f). exp. tf: %s\n', freq(ii), freq_ref(ind),num2str(tf_exp(ind)))
    
    opts = optimset('PlotFcns', 'optimplotfval');
    disc_tf_exp(ii) = tf_exp(ind);
    %exp = tf_exp(ind)
    exp = interp1(freq_ref, tf_exp, freq(ii));
    n_opt = fminsearch(@(n) abs(func(freq(ii), complex(n(1), n(2)))-exp), ...
        n_prev, opts)
    n_prev = n_opt;
    n_fit(:,ii) = n_opt;
end

figure()
subplot(2,2,1)
plot(freq, n_fit(1,:), 'b.-')
xlabel('Frequency (THz)')
ylabel('real(n)')

subplot(2,2,2)
plot(freq, n_fit(2,:), 'r.-')
xlabel('Frequency (THz)')
ylabel('imag(n)')

subplot(2,2,3)
plot(freq_ref, real(tf_exp),'s')
hold on
plot(freq, real(disc_tf_exp), 'o')
xlim([min(freq) max(freq)])
inds = (freq_ref <= max(freq)) & (freq_ref >= min(freq));

tf_fit = @(i) func(freq(i), complex(n_fit(1,i), n_fit(2,i)));
plot(freq, real(arrayfun(tf_fit, 1:numel(freq))),'x')
ylim([min(real(tf_exp(inds))) max(real(tf_exp(inds)))]*1.2)
title('tf real')

subplot(2,2,4)
plot(freq_ref, imag(tf_exp),'s')
hold on
plot(freq, imag(disc_tf_exp), 'o')
xlim([min(freq) max(freq)])
inds = (freq_ref <= max(freq)) & (freq_ref >= min(freq));

plot(freq, imag(arrayfun(tf_fit, 1:numel(freq))),'x')
ylim([min(imag(tf_exp(inds))) max(imag(tf_exp(inds)))]*1.2)
legend('exp', 'exp disc', 'fit')
title('tf imag')

figure()
w = ceil(sqrt(numel(freq)));
h = ceil(sqrt(numel(freq)));

for ii = 1:numel(freq)
    subplot(w,h, ii)
    plot_fit_map(freq(ii), disc_tf_exp(ii),func);
    title(['f = ' num2str(freq(ii)) 'THz'])
end
%% image map

function [] = plot_fit_map(f, exp, func)
n_r = 3.3:0.008:3.6;
%n_r = 2:0.01:5;
n_i = -0.1:0.01:0.1;

err = zeros(numel(n_r), numel(n_i));


for ii = 1:numel(n_r)
    for jj = 1:numel(n_i)
        err(ii,jj) = abs(exp - func(f, complex(n_r(ii), n_i(jj))));
    end
end

imagesc(n_i, n_r, err)
end
