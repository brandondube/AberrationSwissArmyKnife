classdef AberrationSwissArmyKnife < handle
    %AberrationSwissArmyKnife computes wavefronts, point spread functions,
    %and MTF of aberrations.
    
    % to use it, you provide a pupil.  It computes the point spread
    % function (psf):
    % PSF = |FT(pupil)|^2
    % the PSF can be used to compute the modulation transfer function
    % (mtf):
    % MTF = FT(PSF) (normalized by FT(PSF)(1)
    
    properties
        lambda
        efl
        fno
        xpSamples
        padding
        pupil
        xp
        w
        psf
        psfDomain
        mtf
        mtfDomain
        mtfTan
        mtfSag
    end
    
    methods
        % constructor
        function obj = AberrationSwissArmyKnife(lambda, efl, fno, xpSamples, xpPadding, pupilSpec)
            % flying v of default parameters
            if nargin < 6
                if nargin < 5
                    if nargin < 4
                        if nargin < 3
                           if nargin < 2
                                if nargin < 1
                                    lambda = 0.5;
                                end
                                efl = 1;
                            end
                            fno = 1;
                        end
                        xpSamples = 1024;
                    end
                    xpPadding = 8;
                end
                pupilSpec = PupilPrescription();
            end
            obj.lambda = lambda;
            obj.efl = efl;
            obj.fno = fno;
            obj.xpSamples = xpSamples;
            obj.padding = xpPadding;
            obj.pupil = pupilSpec;
            return;
        end
        
        % methods
        function [] = buildPupil(obj)
            % compute XPD
            exitPupilDiameter = obj.efl / obj.fno;

            xpMax = exitPupilDiameter / 2; % exit pupil radius
            xpPad = xpMax * obj.padding; % pad the exit pupil plane for calculation

            obj.xp = linspace(-xpMax - xpPad, ...
                           xpMax + xpPad, ...
                           obj.xpSamples);

            [ xpX, xpY ] = meshgrid(obj.xp);
                   xpPhi = atan2(xpY, xpX);
            rPupil = sqrt(xpX .^ 2 + xpY .^ 2);
            xpRho  = rPupil / xpMax;
            
            obj.w = ones(obj.xpSamples, obj.xpSamples);
            pupilPhase = zeros(obj.xpSamples, obj.xpSamples);
            
            if (strcmpi(obj.pupil.notation, 'w')) % w polynomial / Seidel
                Wexp = cell(length(obj.pupil.seidelTerms), 1);
                for i = 1 : length(Wexp)
                    Wexp{i} = wgenerator(obj.pupil.seidelTerms{i});
                    if (obj.pupil.seidelCoefficients(i) == 0)
                        continue % short circuit for performance
                    end
                    currContrib = Wexp{i}(obj.pupil.seidelCoefficients(i), xpRho, xpPhi);
                    pupilPhase = pupilPhase + currContrib;
                end
            else %notation == 'Z' % Zernike
                Wexp = cell(length(obj.pupil.zernikeTerms), 1);
                for i = 1 : length(Wexp)
                    Wexp{i} = wfromzernikecoef(obj.pupil.zernikeTerms(i));
                    if (obj.pupil.zernikeCoefficients(i) == 0)
                        continue % short circuit zero value terms for speed
                    end
                    currContrib = Wexp{i}(obj.pupil.zernikeCoefficients(i), xpRho, xpPhi);
                    pupilPhase = pupilPhase +  currContrib;
                end
            end
            
            obj.w = exp(1i .* (2 .* pi ./ obj.lambda) .* pupilPhase);
            % delete obj.w outside the pupil
            obj.w(xpRho > 1) = 0;

            % obscure as needed
            obj.w(xpRho < obj.pupil.centralObscuration) = 0;
        end
        function [] = w2psf(obj)
            obj.psf = fftshift(abs(fft2(obj.w)) .^ 2);
            obj.psf = obj.psf / max(max(obj.psf));
            
            xpStep = (obj.xp(2) - obj.xp(1));
            psfStep = 1 / (xpStep * obj.xpSamples);
            rawPsfDomain = ...
                ( -fix( obj.xpSamples / 2  ) ...
                :  fix( (obj.xpSamples - 1) / 2) ) ...
                * psfStep / obj.lambda / obj.efl;
            [ psfDomainX , psfDomainY ] = meshgrid(rawPsfDomain);
            obj.psfDomain = struct(...
                'X', psfDomainX,...
                'Y', psfDomainY);
        end
        function [] = psf2mtf(obj)
            obj.mtf = abs( fft2( obj.psf ) );

            l = obj.xpSamples / 2;
            obj.mtf = obj.mtf(1 : l, 1 : l);
            obj.mtf = obj.mtf ./ obj.mtf(1, 1);
            obj.mtfTan = obj.mtf(:, 1);
            obj.mtfSag = obj.mtf(1, :);

            sample = obj.psfDomain.X(2) - obj.psfDomain.X(1);
            obj.mtfDomain = linspace(0, 1, length(obj.psfDomain.X) / 2) ./ sample;

            l = length(obj.mtfDomain) / 2;
            obj.mtfTan = obj.mtfTan(1:l);
            obj.mtfSag = obj.mtfSag(1:l);
            obj.mtfDomain = obj.mtfDomain(1:l);
        end
    end
end
