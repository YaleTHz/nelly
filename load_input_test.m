%% test must be run from Nelly root directory
function tests = load_input_test
    fnames = dir;
    expected_files = {'load_input.m'};
    assert(numel(setdiff(expected_files, {fnames.name})) == 0, ...
        'load_input_test must be run from Nelly root directory')
    tests = functiontests(localfunctions);
end
%% works properly for json with comments
function works_with_comments_test(testCase)
    path = 'testing/load_input/';
    load_input([path 'comments.json'])
end

%% gives error when some geometry entries are missing n
function error_when_some_missing_n_test(testCase)
    path = 'testing/load_input/';
    f = @() load_input([path 'missing_n.json']);
    verifyError(testCase, f, 'load_input:nonuniform_field')
end

%% gives error when all geometry entries are missing n
function error_when_all_missing_n_test(testCase)
    path = 'testing/load_input/';
    f = @() load_input([path 'missing_n_all.json']);
    verifyError(testCase, f, 'load_input:missing_field')
end

%% correctly loads csv files
function load_csv_test(testCase)
    % should find csv input in same folder as input file and correctly
    % converts input into refractive index function
    path = 'testing/load_input/';
    inp = load_input([path 'csv_load_test.json']);
    assert(inp.sample(2).n_func(1.5) == 1.5 - 2*1i)
end

%% pads reference when sample is thicker
function thickness_padding_reference_test(testCase)
    path = 'testing/load_input/';
    inp = load_input([path 'pad_ref.json']);
    d_smp = sum(arrayfun(@(x) x.d, inp.sample));
    d_ref = sum(arrayfun(@(x) x.d, inp.reference));
    
    % thicknesses match
    assert(d_smp == d_ref)
    
    % padded with correct layer
    last = inp.reference(end);
    pad = inp.reference(end - 1);
    
    assert(last.n == pad.n);
end

%% pads sample when reference is thicker
function thickness_padding_sample_test(testCase)
    path = 'testing/load_input/';
    inp = load_input([path 'pad_smp.json']);
    d_smp = sum(arrayfun(@(x) x.d, inp.sample));
    d_ref = sum(arrayfun(@(x) x.d, inp.reference));
    
    % thicknesses match
    assert(d_smp == d_ref)
    
    % padded with correct layer
    last = inp.sample(end);
    pad = inp.sample(end - 1);
    
    assert(last.n == pad.n);
end

%% allows loading of structs with functions
function load_struct_func_test(testCase)
    path = 'testing/load_input/';
    inp = load_input([path 'pad_smp.json']);
    inp.reference(1).n_func = @(f, n) 4;
    inp_reloaded = load_input(inp);
    assert(inp_reloaded.reference(1).n_func(0,0) == 4)
end