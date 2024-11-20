function [y] = DC_motor_narx_model(n, u, e)
%{ 
NARX model of a DC motor taken from [1]

[1] W. R. L. Junior, V. M. Almeida, and S. A. Milani, “Identificaçao de um motor/gerador cc por meio de modelos
polinomiais autorregressivos e redes neurais artificiais,” in Proc. XIII Simpósio Brasileiro De Automação Inteligente,
pp. 1–6, 2017.

$$y(t) = 1.7813y(t-1) - 0.7962y(t-2) + 0.0339u(t-1) + 0.0338u(t-2) - 0.1597y(t-1)u(t-1) - 0.1396y(t-1)u(t-2) + 0.1297y(t-2)u(t-1) + 0.1086y(t-2)u(t-2) + 0.0085y(t-2)^2$$
%}
a1 = 1.7813;
a2 = -0.7962;
b1 = 0.0339;
b2 = 0.0338;
b3 = -0.1597;
b4 = 0.1297;
b5 = -0.1396;
b6 = 0.1086;
c1 = 0.0085;
c2 = 0.0247;

y = zeros(n, 1); % Output signal initialized to zero
% Simulate the NARX model
for k = 3:n
    y(k) = a1*y(k-1) + a2*y(k-2) + b1*u(k-1) + b2*u(k-2) ...
        + b3*u(k-1)*y(k-1) + b4*u(k-1)*y(k-2) ...
        + b5*u(k-2)*y(k-1) + b6*u(k-2)*y(k-2) ...
        + c1*y(k-2)^2 + c2*e(k-1)*e(k-2) + e(k);
end
end