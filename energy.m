function [energy] = energy(xi, n1, n2, n3, n4, yi, h, beta, eta)
    energy = xi * (h - (beta * (n1 + n2 + n3 + n4)) - (eta * yi));
end
