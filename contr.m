function C = contr(r)
% C = contr(r)
% Compute the contraction matrix of dimension r.
% C: Contraction matrix of dimension r.  C is an r(r+1)/2 by r^2 matrix.

% For future reference, the (i, j)th (j >= i) element of a matrix A, corresponds to
% the r * (i - 1) + j th element in vec(A), but corresponds to the
% (2 * r - i) / 2 * (i - 1) + j th element in vech(A). If j<i, it corresponds to the
% (2 * r - j) / 2 * (j - 1) + i th element in vech(A), but r * (i - 1) + j th element in
% vec(A).

    C = zeros(r * (r + 1) / 2, r ^ 2);
    
    for i = 1 : r
        for j = 1 : r
            if (j == i)
                C((2 * r - i) / 2 * (i - 1) + j, r * (i - 1) + j) = 1;
            elseif (j > i)
                C((2 * r - i) / 2 * (i - 1) + j,r * (i - 1) + j) = 1 / 2;
            else
                C((2 * r - j) / 2 * (j - 1) + i,r * (i - 1) + j) = 1 / 2;
            end
        end
    end
end
