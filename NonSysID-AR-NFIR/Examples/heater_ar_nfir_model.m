function [y] = heater_ar_nfir_model(n, u, e)
%{ 
Hammerstein model of a small electrical heater taken from [1], with the parameters re-estimated in [2]

A Hammerstein model with a polynomial static nonlinearity is an AR-NFIR NARX model, with a linear AR
part and a nonlinear FIR part. Here Np_AR = 1 and Np_NFIR = 2. The independent term of v(t) is omitted
so that y = 0 when u = 0, therefore no bias is required.

[1] L. A. Aguirre, M. C. S. Coelho, and M. V. Correa, "On the interpretation and practice of dynamical
differences between Hammerstein and Wiener models," IEE Proceedings - Control Theory and Applications,
vol. 152, no. 4, pp. 349-356, 2005.
[2] L. A. Tavares, P. E. O. G. B. Abreu, and L. A. Aguirre, "Identification of NARX models for compensation
design," arXiv:2011.10109, 2020.

y(t) = 1.205445y(t-1) - 0.30877507y(t-2) + 0.08985133v(t-1) + 0.009462358v(t-2)
v(t) = 0.4639331u(t)^2 + 0.05435865u(t)

which as a polynomial AR-NFIR NARX model is,
y(t) = 1.205445y(t-1) - 0.30877507y(t-2) + 0.0048842u(t-1) + 0.041685u(t-1)^2 + 0.00051436u(t-2) + 0.0043899u(t-2)^2

u(t) is the normalised electric power, 0 <= u(t) <= 1, and y(t) the normalised temperature, 0 <= y(t) <= 0.5.

Inputs:
  n - Number of time steps
  u - Input signal
  e - Noise signal
Outputs:
  y - Simulated output
%}
a1 = 1.205445;     % Coefficient for y(t-1), beta_1
a2 = -3.0877507e-1; % Coefficient for y(t-2), beta_3
b1 = 8.985133e-2;  % Coefficient for v(t-1), beta_2
b2 = 9.462358e-3;  % Coefficient for v(t-2), beta_4
c1 = 4.639331e-1;  % Coefficient for u(t)^2 of the static nonlinearity, p_1
c2 = 5.435865e-2;  % Coefficient for u(t) of the static nonlinearity, p_2

v = c1.*u.^2 + c2.*u; % Output of the static nonlinearity
y = zeros(n, 1); % Output signal initialized to zero
% Simulate the Hammerstein model
for k = 3:n
    y(k) = a1*y(k-1) + a2*y(k-2) + b1*v(k-1) + b2*v(k-2) + e(k);
end
end
