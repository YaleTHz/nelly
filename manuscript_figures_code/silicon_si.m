nelly_folder = fileparts(which('nelly_main'));
path = fullfile(nelly_folder, 'manuscript_figures_code', 'silicon_si_data', filesep);

% time domain cutoffs for varying numbers of etalons
cutoffs = [-115 -122 -135 -150];

% n and k ranges for error maps
n = 3.3:0.005:3.5;
k = -0.12:0.01:0.12;

num_rows = numel(cutoffs);

for cut_i = 1:numel(cutoffs)
    for ii = 259:2:270
        ii
        
        d_sil = importdata([path 'Jul01_' num2str(ii+1) '.tim']);
        d_air = importdata([path 'Jul01_' num2str(ii) '.tim']);
        inds_air = d_air(:,1) >= cutoffs(cut_i);
        inds_sil = d_sil(:,1) >= cutoffs(cut_i);
        
        [freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func, spec_smp, spec_ref] =...
            nelly_main([path 'silicon_si_input.json'],...
            flipud(-d_sil(inds_sil,1)), flipud(d_sil(inds_sil,2)),...
            flipud(-d_air(inds_air,1)), flipud(d_air(inds_air,2)),...
            'simplex_scale', 0.05);
        
        plot_ind = (cut_i - 1)*3 + 1;
        
        subplot(num_rows, 3, plot_ind)
        plot(flipud(-d_air(inds_air,1)), flipud(d_air(inds_air,2)), 'r')
        hold on
        plot(flipud(-d_sil(inds_sil,1)), flipud(d_sil(inds_sil,2)), 'b')
        
        subplot(num_rows, 3, plot_ind+1)
        plot(freq, real(n_fit), 'k')
        hold on
        
        freq_ind = find(abs(freq - 0.52) < 1e-8, 1);
        maps = error_map(func, tf_spec(freq_ind), freq(freq_ind), n, k);
        
        subplot(num_rows, 3, plot_ind+2)
        contour(n, k, maps{1}.data, [1e-9 1e-8 [0.01:0.04:0.15]] , 'k')
        hold on
        
    end
end


