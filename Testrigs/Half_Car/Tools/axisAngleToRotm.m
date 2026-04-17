function R = axisAngleToRotm(u, theta)
%AXISANGLETOROTM Rodrigues' rotation formula

    ux = u(1); uy = u(2); uz = u(3);

    K = [  0   -uz   uy;
          uz    0   -ux;
         -uy   ux    0 ];

    R = eye(3) + sin(theta)*K + (1 - cos(theta))*(K*K);
end