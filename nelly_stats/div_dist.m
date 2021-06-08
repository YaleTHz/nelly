function [p, cov] = div_dist(mu_num, cov_num, mu_denom)
A_inv = [real(mu_denom) -imag(mu_denom); imag(mu_denom) real(mu_denom)];

cov = inv(A_inv'*inv(cov_num)*A_inv);
mu = mu_num/mu_denom;

p = @(x) mvnpdf([real(x) imag(x)], [real(mu) imag(mu)], cov);
end