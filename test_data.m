%% test si ref. (no reflections)
expTest('test_data/si_ref_air.tim',...
        'test_data/si_ref_smp.tim',...
        'test_data/si_ref_input.json')
lookright = input('Si refractive index: Does this look right(~3.4)? (y/n) ', 's');
assert(strcmp(lookright, 'y'), 'Si refractive index looked incorrect')
close

%% test quartz (2 etalons)
expTest('test_data/sio2_ref_air.tim',...
        'test_data/sio2_ref_smp.tim',...
        'test_data/sio2_ref_input.json')
lookright = input('Quartz refractive index: Does this look right(~2)? (y/n) ', 's');
assert(strcmp(lookright, 'y'), 'Quartz refractive index looked incorrect')
close

function expTest(ref_file, smp_file, input_file)

d_ref = importdata(ref_file);
d_smp = importdata(smp_file);
t_ref= d_ref(:,1); A_ref = d_ref(:,2);
t_smp= d_smp(:,1); A_smp = d_smp(:,2);

[freq, n_fit, freq_full, tf_full, tf_spec, tf_pred, func]...
    = cordouan_main(input_file, t_smp, A_smp, t_ref, A_ref);

figure()
subplot(1,2,1)
plot(freq, n_fit(1,:))
xlabel('Frequency (THz)')
ylabel('n')

subplot(1,2,2)
plot(freq, -n_fit(2,:))
xlabel('Frequency (THz)')
ylabel('\kappa')
end




