function v_rot = quatRotateVec(q, v)
% quatRotateVec Rotate 3D vector(s) v by quaternion q.
%
%   q: 1x4 [qw qx qy qz] (scalar-first). Will be normalized internally.
%   v: Nx3 or 3x1 or 1x3 vectors.
%   v_rot: same size as v (Nx3).
%
% Rotation performed as: v' = q ⊗ (0,v) ⊗ conj(q)

    % Ensure v is Nx3
    if isvector(v) && numel(v)==3
        v = v(:).';  % 1x3
    end
    assert(size(v,2)==3, 'v must be Nx3 or a 3-vector.');

    % Normalize quaternion
    q = double(q(:).');                 % 1x4
    q = q ./ norm(q);

    qw = q(1); qx = q(2); qy = q(3); qz = q(4);

    % Efficient vector rotation formula (equivalent to q*(0,v)*q_conj)
    % t = 2 * cross(q_vec, v)
    % v' = v + qw*t + cross(q_vec, t)
    qvec = [qx qy qz];

    t = 2 * cross(repmat(qvec,size(v,1),1), v, 2);
    v_rot = v + qw * t + cross(repmat(qvec,size(v,1),1), t, 2);
end