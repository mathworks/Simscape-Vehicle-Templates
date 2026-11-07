%% Suspension system parameters
g            = 9.81;
m_tot        = 1865/4; % [kg] total mass of quarter car assuming 2000 kg car
m_us         = 0.1*m_tot; % [kg] unsprung mass assumed to be 10% of total quarter car mass
m_s          = m_tot - m_us; % [kg] sprung mass
f_n_sprung   = 1; % [Hz] assumed 1 Hz natural frequency of sprung mass
f_n_unsprung = 15; % [Hz] assumed 15 Hz natural frequency of unsprung mass
w_n_sprung   = f_n_sprung*2*pi;
w_n_unsprung = f_n_unsprung*2*pi;
k_s          = m_s*w_n_sprung^2; % [N/m] Approximate suspension stiffness based on mass and natural frequency
k_eq         = m_us*w_n_unsprung^2; % [N/m] Approximate combined stiffness based on suspension and tyre springs
k_t          = k_eq-k_s; % [N/m] Springs in parallel assumption to determine tyre stiffness
zeta         = 0.3; % [-] Damping ratio typically associated with ride comfort
% zeta = 0.707; % [-] Damping ratio typically associated with road holding
c_s          = 2*zeta*sqrt(k_s*m_s); % [Ns/m] Damping coefficient for suspension

k_s_soft     = k_s; % [N/m] Approximate suspension stiffness based on mass and natural frequency
c_s_soft     = c_s; % [N/m] Approximate combined stiffness based on suspension and tyre springs

k_s_stiff    = m_s*(2*w_n_sprung)^2;
c_s_stiff    = 2*zeta*sqrt(k_s_stiff*m_s);
