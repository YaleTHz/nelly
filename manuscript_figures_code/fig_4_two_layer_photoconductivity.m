nelly_path = fileparts(which('nelly_main'));
assert(numel(nelly_path) ~= 0,...
    'nelly_main not found. Please add the Nelly folder to your MATLAB path or set is as your current folder.');

path = fullfile(nelly_path, 'manuscript_figures_code',...
    'fig_4_data', 'two_layer_photo_results', filesep);

% import CST simluation results
d_ref = importdata([path 'ref_pulse.tsv']);
d_ref = d_ref.data;
d_smp = importdata([path 'smp_pulse.tsv']);
d_smp = d_smp.data;

% import material parameters used in CST simulation
eps_sim_re = importdata([path 'eps_re.tsv']);
eps_sim_re = eps_sim_re.data;
eps_sim_im = importdata([path 'eps_im.tsv']);
eps_sim_im = eps_sim_im.data;

freq_sim = eps_sim_re(:,1);
n_sim = sqrt(eps_sim_re(:,2) + 1i*eps_sim_im(:,2));

% plot time domain traces
figure()
plot(d_ref(:,1), d_ref(:,2), 'r')
hold on
plot(d_smp(:,1), d_smp(:,2), 'b')

% run Nelly with all branches included
[freq, n_fit_full, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'two_layer_photo_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2));

% run Nelly with only branches in which reflections occur within one layer
% (this is specified by the 'terms', 'one_layer' argument pair. 
[freq, n_fit_one_layer, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'two_layer_photo_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2),'terms', 'one_layer');

% run Nelly with no etalons included (only accounting for reflection
% losses).
[freq, n_fit_no_ref, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'two_layer_photo_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2),'terms', 'no_ref');

[~, n_simple] = just_propagation(freq, tf_spec, 6, 'n_off', 2.2);

n_off = 2.2;
cond_true = n_to_photocond(freq_sim, n_sim, n_off);

figure()

subplot(1,5,2)
plot_fill(freq, n_to_photocond(freq, n_simple, n_off),...
    freq_sim, cond_true)

subplot(1,5,3)
plot_fill(freq, n_to_photocond(freq, n_fit_no_ref, n_off),...
    freq_sim, cond_true)

subplot(1,5,4)
plot_fill(freq, n_to_photocond(freq, n_fit_one_layer, n_off), ...
    freq_sim, cond_true)


subplot(1,5,5)
cond_tink = tinkham(tf_spec, 6, n_off);
plot_fill(freq, cond_tink, freq_sim, cond_true)
ylim([-0.0426 25])

subplot(1,5,1)
plot_fill(freq, n_to_photocond(freq, n_fit_full, n_off),...
    freq_sim, cond_true)
ylim([-0.0426 25])

% plot residuals
cond_interp = interp1(freq_sim(1:end-1), cond_true(1:end-1), freq);

figure()
subplot(1,5,2)
plot(freq,...
    real(n_to_photocond(freq, n_simple, n_off)) - real(cond_interp), 'k')
hold on
plot(freq,...
    imag(n_to_photocond(freq, n_simple, n_off)) - imag(cond_interp), 'k--')

subplot(1,5,3)
plot(freq,...
    real(n_to_photocond(freq, n_fit_no_ref, n_off)) - real(cond_interp), 'k')
hold on
plot(freq,...
    imag(n_to_photocond(freq, n_fit_no_ref, n_off)) - imag(cond_interp), 'k--')

subplot(1,5,4)
plot(freq,...
    real(n_to_photocond(freq, n_fit_one_layer, n_off)) - real(cond_interp), 'k')
hold on
plot(freq,...
    imag(n_to_photocond(freq, n_fit_one_layer, n_off)) - imag(cond_interp), 'k--')

subplot(1,5,5)
plot(freq, real(cond_tink) - real(cond_interp), 'k')
hold on
plot(freq, imag(cond_tink) - imag(cond_interp), 'k--')

subplot(1,5,1)
plot(freq,...
    real(n_to_photocond(freq, n_fit_full, n_off)) - real(cond_interp), 'k')
hold on
plot(freq,...
    imag(n_to_photocond(freq, n_fit_full, n_off)) - imag(cond_interp), 'k--')

function [] = plot_fill(freq, cond, freq_true, cond_true)
c1 = [252 141 98]/255;
c2 = [141 160 203]/255;

fill([freq(:); flipud(freq_true(:))],...
    [real(cond(:)); flipud(real(cond_true(:)))], c1,...
    'edgecolor', 'none', 'facealpha', 0.7)
hold on

fill([freq(:); flipud(freq_true(:))],...
    [imag(cond(:)); flipud(imag(cond_true(:)))], c2, ...
    'edgecolor', 'none', 'facealpha', 0.7)

plot(freq_true, real(cond_true), 'k', 'linewidth', 2)
plot(freq_true, imag(cond_true), 'k:', 'linewidth', 2)

xlim([0.2 2.2])
end

function [] = plot_error(n, c, eps_sim_re, eps_sim_im, freq)
fill([freq 2.2 0.2], [100*abs((eps_sim_re-real(n.^2))./eps_sim_re) 0 0],...
    'facecolor', c, 'edgecolor', 'w')
hold on
fill([freq 2.2 0.2], [100*abs((eps_sim_im-real(n.^2))./eps_sim_im) 0 0],...
    'facecolor', c, 'edgecolor', 'k', 'linestyle', '--')

xlim([0.2 2.2])
end


