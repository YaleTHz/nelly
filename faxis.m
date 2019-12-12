% faxis is a small function that creates THz axis if the input data is in ps unit
% Berechnet Frequenzachse mit N Punkten aus gegebener Zeitachse.
% Calculates frequency axis with N points from given timeline.
function [f df Nt dt] = faxis (t, N)
Nt = length (t);
dt = (t(Nt)-t(1))/(Nt-1);
df = 1/N/dt;

% Neu 28.4.10: Bisher anfällig für Rundungsfehler. Daher:
%f = 0:df:1/dt-df;
% Previously vulnerable to rounding errors. Therefore:
% f = 0: df: 1 / dt-df;
f = (0:N-1)*df;

% Neu 30.3.10: Sonderbehandlung für 1-Punkt-Achsen
% Special treatment for 1-point axes
if Nt == 1
    f = zeros (1, N);
end

s = size(t);
if s(1) > s(2)
    f = f';
end
