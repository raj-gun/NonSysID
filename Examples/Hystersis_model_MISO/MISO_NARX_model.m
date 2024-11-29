function y = MISO_NARX_model(u1, u2, u3, n)
%{ 
NARX model of a DC motor taken from [1]

[1] S. A. M. Martins and L. A. Aguirre, ‘Sufficient conditions for rate-independent hysteresis in autoregressive identified models’, 
Mechanical Systems and Signal Processing, vol. 75, pp. 607–617, 2016.

y(t) =0.8536y(k−1) + 0.0388u3(k−1) + 0.6143u2(k−1)u1(k−1) − 0.4407u3(k−1)u2(k−1)y(k−1)

Inputs:
  u1, u2, u3 - Input signals
  n   - Number of time steps
Outputs:
  y   - Simulated output
%}
%%
% NARX Model Coefficients
a1 = 0.8536;              % Coefficient for y(k-1)
b1 = 0.0388;              % Coefficient for u3(k-1)
b2 = 0.6143;              % Coefficient for u2(k-1)u1(k-1)
b3 = -0.4407;             % Coefficient for u3(k-1)u2(k-1)y(k-1)

% Initialize Output
y = zeros(1, n);

% Simulation Loop
for k = 2:n
    y(k) = a1 * y(k-1) + ...
           b1 * u3(k-1) + ...
           b2 * u2(k-1) * u1(k-1) + ...
           b3 * u3(k-1) * u2(k-1) * y(k-1);
end


end
