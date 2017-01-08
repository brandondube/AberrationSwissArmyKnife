function [ W ] = wgenerator(aberration)

ab = lower(aberration);

switch ab
    % defocus
    case {'d', 'def', 'defocus'}
        W = @(a, rho, phi) a .* ...
            ( rho .* rho ...
            );
    % tilt
    case {'t', 'tlt', 'tilt'}
        W = @(a, rho, phi) a .* ...
            ( rho .* cos(phi) ...
            );
    % spherical
    case {'s', 'sph', 'sa3', 'spherical'}
        W = @(a, rho, phi) a .* ...
            ( rho .^ 4 ...
            );
    % coma
    case {'c', 'cma', 'coma'}
        W = @(a, rho, phi) a .* ...
            ( rho .^ 3 .* cos(phi) ...
            );
    % astigmatism
    case {'a', 'ast', 'astigmatism'}
        W = @(a, rho, phi) a .* ...
            ( rho .* rho .* cos(phi) .^ 2 ...
            );
    otherwise
        error('see wgenerator.m for valid aberration keys');
end
end
