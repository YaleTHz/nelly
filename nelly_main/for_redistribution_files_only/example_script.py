import nelly_main
import matlab
import csv
nelly_lib = nelly_main.initialize()


fpref = '../../test_data/'

def load_file(fname):
    t = []
    a = []
    with open(fname) as csvfile:
        freader = csv.reader(csvfile, delimiter='\t')
        for row in freader:
            t.append(float(row[0]))
            a.append(float(row[1]))
    return [matlab.double(t), matlab.double(a)]



[t_smp, a_smp] = load_file(fpref + 'cell_ref_filled.tim')
[t_ref, a_ref] = load_file(fpref + 'cell_ref_empty.tim')


freq, n_fit = nelly_lib.nelly_main(fpref + 'cell_ref_filled_input.json', t_smp, a_smp, t_ref, a_ref, nargout=2)

print(freq)
print(n_fit)


