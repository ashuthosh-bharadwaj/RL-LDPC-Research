function y = Min(x)
    a = abs(x);
    y = ones(length(x),1);
    sign_x = sign(1 + 2*sign(x));

    parity = prod(sign_x);

    [min1, min1_pos] = min(a);
    a(min1_pos) = Inf;
    min2 = min(a);

    y = min1*y;
    y(min1_pos) = min2;
    y = (parity.*y.*sign_x')';


    