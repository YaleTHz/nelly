function input = load_input(fname)
input = jsondecode(fileread(fname));

% file validation to come
% add in defaults and log these additions to some output for transparency
geom = input.geometry;
mats = input.materials;

assert(numel(geom)> 0, 'input geometry does not have any materials')

input.layers = cell(1,numel(geom));

for ii = 1:numel(geom)
    mat = mats.(geom{ii});
    %% make refractive index retrieval function
    assert(isnumeric(mat.n) | ischar(mat.n), 'refractive index must be number or string')

    % static refractive index
    if isnumeric(mat.n)
        mat.n_func = @(w, n_solve) mat.n;
        
    % unknown refractive index (what we're solving for 
    elseif strcmp(mat.n, 'solve')
        mat.n_func = @(f, n_solve) n_solve;
        
    % load values for refractive
    else
        assert(isfile(mat.n),...
            'couldnt find refractive index file %s', mat.n)
        % maybe separate data load  into its own function later
        dat = importdata(mat.n);
        freq = dat(:,1);
        n = dat(:,2);
        mat.n_func = @(f, n_solve) interp1(freq, n, f);
    end
    input.layers{ii} = mat;
    fprintf('%d. %0.2f um of material w n from %s\n', ii, mat.d, mat.n)
end

end