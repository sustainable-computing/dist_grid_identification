function E = expan(r)
% E = expan(r)
% Compute the expansion matrix of dimension r.
% E: Expansion matrix of dimension r.  E is an r ^ 2 by r(r + 1) / 2 matrix.

% For future reference, the (i, j)th (j >= i) element of a matrix A, corresponds to
% the r * (i - 1) + j th element in vec(A), but corresponds to the
% (2 * r - i) / 2 * (i - 1) + j th element in vech(A). If j < i, it corresponds to the
% (2 * r - j) / 2 * (j - 1) + i th element in vech(A), but r * (i - 1) + j th element in
% vec(A).

    E = zeros(r ^ 2,r * (r + 1) / 2);
    
    for i = 1 : r
        for j = 1 : r
            if (j >= i)
                E(r * (i - 1) + j, (2 * r - i) / 2 * (i - 1) + j) = 1;
            else
                E(r * (i - 1) + j, (2 * r - j) / 2 * (j - 1) + i) = 1;
            end
        end
    end
end
