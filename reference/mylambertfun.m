function [V1, V2] = mylambertfun(R1, R2, t, mu, string)
%%本方程用于求解lambert问题
% 输入参数：
% R1 - 初始点位置向量 (km)
% R2 - 最终点位置向量 (km)
% t - 从R1到R2的飞行时间 (s)
% mu - 重力参数 (km^3/s^2)
% string - 'pro'表示轨道是顺行的，'retro'表示轨道是逆行的
% 输出参数：
% V1 - 初始点的速度向量 (km/s)
% V2 - 最终点的速度向量 (km/s)
    r1 = norm(R1);  % 计算R1的模
    r2 = norm(R2);  % 计算R2的模
    c12 = cross(R1, R2);    % 计算R1和R2的叉积
    theta = acos(dot(R1,R2)/r1/r2); % 计算R1和R2之间的夹角
    if string=="pro"
        if c12(3) <= 0
            theta = 2*pi - theta;
        end
    elseif string=="retro"
        if c12(3) >= 0
            theta = 2*pi - theta;
        end
    else
        error('string must be "pro" or "retro"');
    end
    A = sin(theta)*sqrt(r1*r2/(1 - cos(theta)));    % Equation 5.35
    z = -100;
    while F(z,t) < 0
        z = z + 0.1;
    end

    tol = 1.e-8;    % 收敛精度
    nmax = 5000;    % 最大迭代次数
    ratio = 1;
    n = 0;
    while (abs(ratio) > tol) && (n <= nmax)
        n = n + 1;
        ratio = F(z,t)/dFdz(z);
        z = z - ratio;
    end
    if n >= nmax
        fprintf('\n\n **Number of iterations exceeds')
        fprintf(' %g \n\n ', nmax)
    end
    %...Equation 5.46a:
    f = 1 - y(z)/r1;
    %...Equation 5.46b:
    g = A*sqrt(y(z)/mu);
    %...Equation 5.28:
    V1 = 1/g*(R2 - f*R1);
    %...Equation 5.29:
    V2 = 1/g*(gdot*R2 - R1);
    %...Equation 5.38:
    function dum = y(z)
        dum = r1 + r2 + A*(z*S(z) - 1)/sqrt(C(z));
    end
    %...Equation 5.40:
    function dum = F(z,t)
        dum = (y(z)/C(z))^1.5*S(z) + A*sqrt(y(z)) - sqrt(mu)*t;
    end
    %...Equation 5.43:
    function dum = dFdz(z)
        if z == 0
            dum = sqrt(2)/40*y(0)^1.5 + A/8*(sqrt(y(0)) ...
            + A*sqrt(1/2/y(0)));
        else
            dum = (y(z)/C(z))^1.5*(1/2/z*(C(z) - 3*S(z)/2/C(z)) ...
            + 3*S(z)^2/4/C(z)) ...
            + A/8*(3*S(z)/C(z)*sqrt(y(z)) ...
            + A*sqrt(C(z)/y(z)));
        end
    end
    %...Stumpff functions:
    function dum = C(z)
        if z > 0
            c = (1 - cos(sqrt(z)))/z;
        elseif z < 0
            c = (cosh(sqrt(-z)) - 1)/(-z);
        else
            c = 1/2;
        end
            dum = c;
    end
    %...Stumpff functions:
    function dum = S(z)
        if z > 0
            s = (sqrt(z) - sin(sqrt(z)))/(sqrt(z))^3;
        elseif z < 0
            s = (sinh(sqrt(-z)) - sqrt(-z))/(sqrt(-z))^3;
        else
            s = 1/6;
        end
        dum = s;
    end
end