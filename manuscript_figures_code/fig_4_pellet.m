nelly_path = fileparts(which('nelly_main'));
assert(numel(nelly_path) ~= 0,...
    'nelly_main not found. Please add the Nelly folder to your MATLAB path or set is as your current folder.');

path = fullfile(nelly_path, 'manuscript_figures_code',...
    'fig_4_data', 'pellet_results', filesep);

d_ref = importdata([path 'ref_pulse.tsv']);
d_ref = d_ref.data;
d_smp = importdata([path 'smp_pulse.tsv']);
d_smp = d_smp.data;

eps_sim_re = importdata([path 'eps_re.tsv']);
eps_sim_re = eps_sim_re.data;
eps_sim_im = importdata([path 'eps_im.tsv']);
eps_sim_im = eps_sim_im.data;

% plot time domain traces
figure()
plot(d_ref(:,1), d_ref(:,2), 'r')
hold on
plot(d_smp(:,1), d_smp(:,2), 'b')

% run Nelly with all branches included
[freq, n_fit_full, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'pellet_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2));

% run Nelly with only branches in which reflections occur within one layer
% (this is specified by the 'terms', 'one_layer' argument pair. 
[freq, n_fit_one_layer, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'pellet_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2),'terms', 'one_layer');

% run Nelly with no etalons included (only accounting for reflection
% losses and propagation terms).
[freq, n_fit_no_ref, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref]...
    = nelly_main([path 'pellet_input.json'],...
    d_smp(:,1), d_smp(:,2), d_ref(:,1), d_ref(:,2),'terms', 'no_ref');

% calculate refractive index assuming propagation is the only term present
% in the transfer function
[~, n_simple] = just_propagation(freq, tf_spec, 1000);

figure()

subplot(1,5,2)
plot_fill(n_simple, eps_sim_re, eps_sim_im, freq)
subplot(1,5,3)
plot_fill(n_fit_no_ref, eps_sim_re, eps_sim_im, freq)
subplot(1,5,4)
plot_fill(n_fit_one_layer, eps_sim_re, eps_sim_im, freq)
subplot(1,5,5)
set(gca, 'visible', 'off')
subplot(1,5,1)
plot_fill(n_fit_full, eps_sim_re, eps_sim_im, freq)


% plot residuals
freq_sim = eps_sim_re(:,1);
eps_sim_interp = interp1(freq_sim(1:end-1),...
    eps_sim_re(1:end-1,2) + 1i*eps_sim_im(1:end-1,2), freq);
figure()
subplot(1,5,2)
plot(freq, real(n_simple.^2) - real(eps_sim_interp), 'k')
hold on
plot(freq, imag(n_simple.^2) - imag(eps_sim_interp), 'k--')

subplot(1,5,3)
plot(freq, real(n_fit_no_ref.^2) - real(eps_sim_interp), 'k')
hold on
plot(freq, imag(n_fit_no_ref.^2) - imag(eps_sim_interp), 'k--')

subplot(1,5,4)
plot(freq, real(n_fit_one_layer.^2) - real(eps_sim_interp), 'k')
hold on
plot(freq, imag(n_fit_one_layer.^2) - imag(eps_sim_interp), 'k--')

subplot(1,5,5)
set(gca, 'visible', 'off')

subplot(1,5,1)
plot(freq, real(n_fit_full.^2) - real(eps_sim_interp), 'k')
hold on
plot(freq, imag(n_fit_full.^2) - imag(eps_sim_interp), 'k--')


function [] = plot_fill(n, eps_sim_re, eps_sim_im, freq)
c1 = [252 141 98]/255;
c2 = [141 160 203]/255;
fill([freq(:); flipud(eps_sim_re(:,1))],...
    [real(n(:).^2); flipud(eps_sim_re(:, 2))], c1,...
    'edgecolor', 'none', 'facealpha', 0.7)
hold on

fill([freq(:); flipud(eps_sim_im(:,1))],...
    [imag(n(:).^2); flipud(eps_sim_im(:, 2))], c2, ...
    'edgecolor', 'none', 'facealpha', 0.7)

plot(eps_sim_re(:,1), eps_sim_re(:,2),'k', 'linewidth', 2)
plot(eps_sim_im(:,1), eps_sim_im(:,2),'k:',...
    'linewidth', 2)

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


