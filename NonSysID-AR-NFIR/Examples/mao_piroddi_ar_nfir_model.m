function [y] = mao_piroddi_ar_nfir_model(n, u, e)
%{ 
AR-NFIR NARX model constructed from two benchmark systems [1], [2], as given in [3]

The NAR part is formed by the output-lagged terms of the Mao and Billings benchmark [1], with its
two cross-terms, y(t-1)u(t-1) and y(t-2)u(t-2)^2, removed. The NFIR part is the deterministic part
of the Piroddi and Spinelli benchmark [2]. There are no cross-terms between the two parts, and the
maximum polynomial orders are Np_AR = 3 and Np_NFIR = 3.

[1] K. Z. Mao and S. A. Billings, "Algorithms for minimal model structure detection in nonlinear dynamic
system identification," International Journal of Control, vol. 68, no. 2, pp. 311-330, 1997.
[2] L. Piroddi and W. Spinelli, "An identification algorithm for polynomial NARX models based on simulation
error minimization," International Journal of Control, vol. 76, no. 17, pp. 1767-1781, 2003.
[3] Y. Guo, L. Z. Guo, S. A. Billings, and H.-L. Wei, "An iterative orthogonal forward regression algorithm,"
International Journal of Systems Science, vol. 46, no. 5, pp. 776-789, 2015. (Eq. (17) and Eq. (18))

y(t) = 0.2y(t-1)^3 - 0.5y(t-2) + u(t-1) + 0.5u(t-2) + 0.25u(t-1)u(t-2) - 0.3u(t-1)^3

Note: with its cross-terms removed the y(t-1)^3 term is expansive, and the model is only stable for a
bounded input. Keep |u(t)| <= 0.6, e.g. u(t) ~ U(-0.6,0.6). The model diverges in roughly half of the
realisations for u(t) ~ U(-1,1).

Inputs:
  n - Number of time steps
  u - Input signal
  e - Noise signal
Outputs:
  y - Simulated output
%}
a1 = 0.2;   % Coefficient for y(t-1)^3
a2 = -0.5;  % Coefficient for y(t-2)
b1 = 1;     % Coefficient for u(t-1)
b2 = 0.5;   % Coefficient for u(t-2)
b3 = 0.25;  % Coefficient for u(t-1)u(t-2)
b4 = -0.3;  % Coefficient for u(t-1)^3

y = zeros(n, 1); % Output signal initialized to zero
% Simulate the AR-NFIR NARX model
for k = 3:n
    y(k) = a1*y(k-1)^3 + a2*y(k-2) ... % NAR part
        + b1*u(k-1) + b2*u(k-2) + b3*u(k-1)*u(k-2) + b4*u(k-1)^3 ... % NFIR part
        + e(k);
end
end
