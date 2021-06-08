% plot ellipse enclosing 3 standard deviations of bivariate Gaussian with
% covariance matrix A and mean mu
function [p, pts] = plot_ellipse(mu, A)
theta = 0:0.01:2*pi;
r = 3;
x = r*cos(theta);
y = r*sin(theta);
pts = sqrtm(A)*[x;y];
pts = pts + mu(:);
p = plot(pts(1,:), pts(2,:));
end