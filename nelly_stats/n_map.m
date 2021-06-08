function mat = n_map(n, k, f)
mat = zeros(numel(k), numel(n));
total = numel(n)*numel(k);
for c = 1:numel(n)
    for r = 1:numel(k)
        waitbar((numel(k)*(c-1) + r)/total)
        mat(r,c) = f(n(c) - 1i*k(r));
    end
end