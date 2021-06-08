pdf = @(x) exp(-(sqrt(x)-3)^2);

sig = 2;
n_traces = 1e6;
proppdf = @(x,y) normpdf(abs(x-y), 0, sig);
proprnd = @(x) x + sig*(rand-0.5);
    
[trace, accept] = mhsample(2 ,n_traces,...
        'pdf',pdf,'proppdf',proppdf, 'proprnd',proprnd);