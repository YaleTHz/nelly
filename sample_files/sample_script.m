%% loading in data (replace paths with your data)
data_ref = importdata('../test_data/cell_ref_empty.tim');
data_smp = importdata('../test_data/cell_ref_filled.tim');

t_ref = data_ref(:,1);
A_ref = data_ref(:,2);

t_smp = data_smp(:,1);
A_smp = data_smp(:,2);

%% running Nelly; n_fit is the extracted refractive index at the 
%% frequencies in freq
[freq, n_fit, ~, ~, ~, ~, ~]... 
    = nelly_main('sample_input_file.json', t_smp, A_smp, t_ref, A_ref);