% run this code from the folder containing the Nelly package
% (should have subdirectory test_data)
fnames = dir;
expected_files = {'test_data.m', 'test_data'};
assert(numel(setdiff(expected_files, {fnames.name})) == 0, ...
    'test_data must be run from Nelly root directory')

addpath('utilities')

%% test SnO2 photoconductivity
d = 1; nn = 2.2;
[f, tf_spec, freq, func] = testCond('sno2_photo_ref.tim',...
    'sno2_photo_smp.tim', ...
    'sno2_photo_input.json', nn)
h = allchild(gca);
plot(freq, real(tinkham(tf_spec, d, nn)),'--', 'color',...
    h(2).Color, 'DisplayName', 'Thin film re')
plot(freq, imag(tinkham(tf_spec, d, nn)),'--', 'color',...
    h(1).Color, 'DisplayName', 'Thin film im')
quest = 'SnO2 photoconductivity: Does this look right? (should mostly match thin film)';
lookright = questdlg(quest, 'Check results', 'Yes', 'No', 'No');
assert(strcmp(lookright, 'Yes'), 'SnO2 photoconductivity looked incorrect')
close

%% test si ref. (no reflections)
[f, tf_spec, freq, func] = expTest('test_data/si_ref_air.tim',...
        'test_data/si_ref_smp.tim',...
        'test_data/si_ref_input.json')
    
quest = 'Si refractive index: Does this look right(~3.4)?';
lookright = questdlg(quest, 'Check results', 'Yes', 'No', 'No');
assert(strcmp(lookright, 'Yes'), 'Si refractive index looked incorrect')
close

%% test quartz (2 etalons)
expTest('test_data/sio2_ref_air.tim',...
        'test_data/sio2_ref_smp.tim',...
        'test_data/sio2_ref_input.json')
quest = 'Quartz refractive index: Does this look right(~2)?';
lookright = questdlg(quest, 'Check results', 'Yes', 'No', 'No');
assert(strcmp(lookright, 'Yes'), 'Quartz refractive index looked incorrect')
close


%% test cell (quartz-air-quartz)
[f, tf_spec, freq, func] = expTest('test_data/cell_ref_air.tim',...
        'test_data/cell_ref_empty.tim',...
        'test_data/cell_ref_input.json')
quest = 'Quartz refractive index: Does this look right(~2)?';
lookright = questdlg(quest, 'Check results', 'Yes', 'No', 'No');
assert(strcmp(lookright, 'Yes'), 'Quartz refractive index looked incorrect')
close

%% test cell (quartz-water-quartz)
[f, tf_spec, freq, func] = expTest('test_data/cell_ref_empty.tim',...
        'test_data/cell_ref_filled.tim',...
        'test_data/cell_ref_filled_input.json');
% get literature data
load 'test_data/water_lit_data.mat'
subplot(1,2,1)
plot(n_thz_sch, n_sch)
plot(n_thz_thr, n_thr)
legend('Nelly','Schmuttenmaer (1996)', 'Thrane (1995)')
subplot(1,2,2)
plot(a_thz_sch, a_sch*3e10./(4*pi*a_thz_sch*1e12))
plot(a_thz_thr, a_thr*3e10./(4*pi*a_thz_thr*1e12))

quest = 'Water refractive index: Does this look right (compared to lit value)?';
lookright = questdlg(quest, 'Check results', 'Yes', 'No', 'No');
assert(strcmp(lookright, 'Yes'), 'Water refractive index looked incorrect')

function [fig, tf_spec, freq, func] = expTest(ref_file, smp_file, input_file)

d_ref = importdata(ref_file);
d_smp = importdata(smp_file);
t_ref= d_ref(:,1); A_ref = d_ref(:,2);
t_smp= d_smp(:,1); A_smp = d_smp(:,2);

[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func]...
    = nelly_main(input_file, t_smp, A_smp, t_ref, A_ref);

fig = figure();
subplot(1,2,1)
plot(freq, real(n_fit))
hold on
xlabel('Frequency (THz)')
ylabel('n')

subplot(1,2,2)
plot(freq, imag(n_fit))
hold on
xlabel('Frequency (THz)')
ylabel('\kappa')
end


function [fig, tf_spec, freq, func] = testCond(ref_file, smp_file, input_file, n_n)
data_path = 'test_data/';
d_ref = importdata([data_path ref_file]);
d_smp = importdata([data_path smp_file]);
t_ref= d_ref(:,1); A_ref = d_ref(:,2);
t_smp= d_smp(:,1); A_smp = d_smp(:,2);
A_smp = A_ref + A_smp;

[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func]...
    = nelly_main([data_path input_file], t_smp, A_smp, t_ref, A_ref);
cond = n_to_photocond(freq, n_fit, n_n);
fig = figure();
plot(freq, real(cond))
hold on
plot(freq, imag(cond))
legend('re', 'im')
xlabel('Frequency (THz)')
ylabel('Conductivity (S/m)')
end


