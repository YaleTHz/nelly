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
    path = 'C:\Users\utayv\OneDrive\Desktop\grad\research\cordouan\testing\load_input\';
    load_input([path 'comments.json'])
end

%% gives error when some geometry entries are missing n
function error_when_some_missing_n_test(testCase)
    path = 'C:\Users\utayv\OneDrive\Desktop\grad\research\cordouan\testing\load_input\';
    f = @() load_input([path 'missing_n.json']);
    verifyError(testCase, f, 'load_input:nonuniform_field')
end

%% gives error when all geometry entries are missing n
function error_when_all_missing_n_test(testCase)
    path = 'C:\Users\utayv\OneDrive\Desktop\grad\research\cordouan\testing\load_input\';
    f = @() load_input([path 'missing_n_all.json']);
    verifyError(testCase, f, 'load_input:missing_field')
end

%% correctly loads csv files
function load_csv_test(testCase)
    % should find csv input in same folder as input file and correctly
    % converts input into refractive index function
    path = 'C:\Users\utayv\OneDrive\Desktop\grad\research\cordouan\testing\load_input\';
    inp = load_input([path 'csv_load_test.json']);
    assert(inp.sample(2).n_func(1.5) == 1.5 - 2*1i)
end
