%% estimate si n
[input_si, n_si] = est_n_input('test_data/si_ref_air.tim',...
                               'test_data/si_ref_smp.tim',...
                               'test_data/si_ref_input.json');
assert(abs((n_si-3.42)/3.42) < 0.05)

%% estimate quartz n
[input_sio2, n_sio2] = est_n_input('test_data/sio2_ref_air.tim',...
                                   'test_data/sio2_ref_smp.tim',...
                                   'test_data/sio2_ref_input.json');
assert(abs((n_sio2-2)/2) < 0.05)

%% estimate quartz cell n
[input_sio2_cell, n_sio2_cell] = est_n_input('test_data/cell_ref_air.tim',...
                                             'test_data/cell_ref_empty.tim',...
                                             'test_data/cell_ref_input.json');
assert(abs(n_sio2_cell-2)/2 < 0.05)
                      
           


function [input, n]  = est_n_input(f_ref, f_smp, f_input)
d_ref = importdata(f_ref);
d_smp = importdata(f_smp);
dt = delay(d_ref(:,1), d_ref(:,2), d_smp(:,1), d_smp(:,2));
input = load_input(f_input);
[input, n] = estimate_n(dt, input);
end

function dt = delay(t1, A1, t2, A2)
t1_max = t1(A1 == max(A1));
t2_max = t2(A2 == max(A2));
dt = t2_max-t1_max;
end