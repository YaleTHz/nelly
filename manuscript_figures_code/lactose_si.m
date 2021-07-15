nelly_folder = fileparts(which('nelly_main'));
path = fullfile(nelly_folder, 'manuscript_figures_code', 'lactose_si_data', filesep);

t_lac = [];
A_lacs = [];
t_air = [];
A_airs = [];
tfs = [];


% n range for error mapping
n = 1.6:0.004:2;
% k range for error mapping
k = -0.05:0.01:0.35;

figure()
for ii = 271:-2:257
    ii
    d_lac = importdata([path 'Jun30_' num2str(ii+1) '.tim']);
    d_air = importdata([path 'Jun30_' num2str(ii) '.tim']);
    
    t_lac = d_lac(:,1);
    A_lacs = [A_lacs flipud(d_lac(:,2))];
    t_air = d_air(:,1);
    A_airs = [A_airs flipud(d_air(:,2))];
   [freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref] =...
       nelly_main([path 'lactose_input.json'],...
        t_lac, flipud(d_lac(:,2)), t_air, flipud(d_air(:,2)), ...
        'k_min', 1e-3);
    
    tfs = [tfs; tf_spec];
    
    if ii == 257
        color = 'r';
        lw = 1.1;
    else
        color = [0.5 0.5 0.5];
        lw = 0.5;
    end
    
    subplot(2,2,1)
    plot(freq, real(n_fit), 'color', color, 'linewidth', lw)
    hold on
    ylabel('Refractive index (real)')
    xlabel('Frequency (THz)')
    xlim([0.2 2.2])
    
    subplot(2,2,2)
    plot(freq, imag(n_fit), 'color', color, 'linewidth', lw)
    hold on
    ylabel('Refractive index (imag.)')
    xlabel('Frequency (THz)')
    xlim([0.2 2.2])
    
    subplot(4,1,3)
    semilogy(freq, abs(tf_spec), 'color', color, 'linewidth', lw)
    hold on
    ylabel('|TF|')
    xlabel('Frequency (THz)')
    xlim([1.34 1.39])
    
    map_freqs = [1.36 1.37 1.38];
    map_freq_inds = arrayfun(@(x) find(abs(freq - x) < 1e-10, 1), map_freqs);
    map_tfs = tf_spec(map_freq_inds);
    maps = error_map(func, map_tfs, map_freqs, n, k);
    
    for map_ii = 1:3
        subplot(5,3, 12 + map_ii)
        title([num2str(map_freqs(map_ii), '%0.2f') ' THz'])
        contour(n, k, maps{map_ii}.data, [1e-5:2:10],...
            'color', color, 'linewidth', lw)
        hold on
        xlabel('n')
        ylabel('k')
    end
end


% process traces averaged in time domain
[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref] = ...
    nelly_main([path 'lactose_input.json'],...
    t_lac, mean(A_lacs, 2), t_air, mean(A_airs, 2));

subplot(2,2,1)
plot(freq, real(n_fit), 'k', 'linewidth', 1.1)

subplot(2,2,2)
plot(freq, imag(n_fit), 'k--', 'linewidth', 1.1)

subplot(4,1,3)
semilogy(freq, abs(tf_spec), 'k', 'linewidth', 1.1)

map_tfs = mean(tfs(:,map_freq_inds));
maps = error_map(func, map_tfs, map_freqs, n, k);

for map_ii = 1:3
    subplot(5,3, 12 + map_ii)
    contour(n, k, maps{map_ii}.data, [1e-5:2:10], 'color', 'k', ...
        'linewidth', 1.1)
end