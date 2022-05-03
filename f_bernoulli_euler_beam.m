function Y = f_bernoulli_euler_beam(X)
% =========================================================================
% === Tapered cantilever beam subject to uniformly distributed loading  ===
% === based on American Society of Mechanical Engineers (ASME)          ===
% === Verification, Validation, and Uncertainty Quantification (VVUQ)   ===
% === Guidance document V&V10.1 for Computational Solid Mechanics (CSM) ===
% === and adapted as a data-driven modeling exercise for evaluations    ===
% =========================================================================
% Who: G. Banyay, assisted by: J. Kaizer, S. Sidener, C. Robeck
% Date: 2022 January
% References: 
% (1)   "On the Derivation of Exact Solutions of a Tapered Cantilever Timoshenko Beam", DOI: 10.9744/CED.21.2.89-96
% (2)   "An Illustration of the Concepts of Verification, Validation, and Uncertainty Quantification... 
%       in Computational Solid Mechanics", ASME VVUQ 10.1

%% inputs

L = X(1);
% L = 2;                                    % length [m] -- X(1)... 1.8 - 2.2

h = X(2);
% h = 0.05;                                 % "depth" / height [m] -- X(2)... 0.04 - 0.06

b0 = X(3);
% b0 = 0.20;                                % width at support [m] -- X(3)... 0.15 - 0.25

bTip = X(4);
% bTip = 0.10;                              % width at tip [m] -- X(4)... 0.08 - 0.12

t = 0.005;                                  % wall thickness [m]

E = X(5);
% E = 69.1e9;                               % elastic modulus [Pa] (aluminum) -- X(5)... 69.0e9 - 69.2e9

nu = 0.3;                                   % poisson's ratio

q = X(6);
% q = 500;                                  % uniform distributed load on outer half of beam [Nm] -- X(6)... 450 - 500

%% solution
alpha = 1 - bTip/b0;
a = (alpha - 1) / L;                        % eqn. (10a) from Timoshenko paper

x = 0;                                      % dimension FROM BASE at which to compute I [m]
I = (1/12) * (b0*(1-alpha*(x/L))*h^3 -...   % moment of inertia, from VV 10.1
    (b0*(1-alpha*(x/L))-2*t)*(h-2*t)^3);

if x == 0
    I_check = (1/12) *...                   % check I at base
            (b0*h^3 - (b0-2*t)*(h-2*t)^3);
    I0 = I;
end

G = E / (2*(1+nu));                         % shear modulus
A0 = b0*h - ((b0-2*t)*(h-2*t));             % cross sectional area at base

% ~~~ deflection as a function of length along beam, per Eqn. 20b ~~~
x_ = 0;                                                 % distance FROM TIP to compute deflection
w_bq_ = q/(6*E*I0) * ((1/4)*x_^4 - L^3*x_ + (3/4)*L^4); % bending (b), distributed load (q)
w_sq_ = -q/(2*G*A0) * (x_^2 - L^2);                     % shear (s), distributed load (q)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
w_q_fx = w_bq_ + w_sq_;
fprintf('\ndeflection at tip (per Eqn. 20b of Ref. 1 (Timoshenko)) = %5.4f [m]\n', w_q_fx);

%% using equation (5) from VV 10.1 as analytical solution
x4w = 2;                                                % distance x at which to compute w
LHS = (E * I0) / (q * L^4);                             % multiplier by defl. to normalize
     
w_norm =    (1/(2*alpha)) * ...                         % normalized deflection
            (((1/alpha)-1)^2 * ((x4w/L)+((1/alpha)-(x4w/L))*log(1-alpha*(x4w/L))) - ... 
            (1/6)*(x4w/L)^3 + (1-(1/(2*alpha)))*(x4w/L)^2);     
     
w = w_norm / LHS;                                       % deflection
fprintf('\ndeflection at tip (per Eqn. 5 of Ref. 2 (VVUQ 10.1)) = %5.4f [m]\n', w);

%% gather inputs and outputs for generalization to data-driven modeling problem
% X = [L, h, b0, bTip, E, q];

up = 1.1;       % set upper bound for uncertainty applied to result
lo = 0.9;       % set lower bound
r =  (up-lo).*rand(10,1) + lo;

Y = w * r;      % add some random noise

fprintf('\nInputs:');
fprintf('\n\tL[m]   \th[m]  \tb0[m] \tbTip[m]   \tE[Pa] \t\tq[N/m]');
fprintf('\n\tX(1)   \tX(2)  \tX(3)  \tX(4)      \tX(5)  \t\tX(6)');
fprintf('\n\t%3.2f  \t%3.3f \t%3.3f \t%3.3f     \t%3.2E \t%4.1f',...
        X(1), X(2), X(3), X(4), X(5), X(6));
fprintf('\nOutput (and range):');
fprintf('\n\tw[m]');
fprintf('\n\tY');
fprintf('\n\t%5.4f  \t%5.4f \t%5.4f \n\n', w, min(Y), max(Y));


%% save data to stand-alone text file
fID = fopen('_samples_for_ML.text', 'a');       % append content
fprintf(fID,'\n\t%3.2f \t%3.3f \t%3.3f \t%3.3f \t%3.2E \t%4.1f \t%5.4f, \t%5.4f \t%5.4f',...
        X(1), X(2), X(3), X(4), X(5), X(6), w, min(Y), max(Y));
fclose(fID);


%% scratch space

% % ~~~ at tip location, per Table 1 ~~~
% % alpha = 1 + a*L;                  % subsitute per note in Timoshenko paper (typo?)
% w_bq = q/(4*a^3*E*I0) * ((2*alpha^2-1)/(a*alpha) - (6*log(alpha)+1)/a + ((4*alpha-1)/alpha^2)*L);
% w_sq = q/(a^2*G*A0) * (a*L - log(alpha));
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% w_q = w_bq + w_sq;
% fprintf('\ndeflection at tip (per Table 1) = %5.4f [m]\n', w_q);
% fprintf('\tNot sure why this deflection is so off??\n');

