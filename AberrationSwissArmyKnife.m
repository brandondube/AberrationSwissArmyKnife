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
        pupilPrescription
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
            obj.lambda = lambda;
            obj.efl = efl;
            obj.fno = fno;
            obj.xpSamples = xpSamples;
            obj.padding = xpPadding;
            obj.pupilPrescription = pupilSpec;
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
            obj.w = zeros(obj.xpSamples, obj.xpSamples);

            if (strcmpi(obj.pupilPrescription.notation, 'w')) % w polynomial / Seidel
                Wexp = cell(length(obj.pupilPrescription.seidelTerms), 1);
                for i = 1 : length(Wexp)
                    Wexp{i} = wgenerator(obj.pupilPrescription.seidelTerms{i});
                    if (coefs(i) == 0)
                        continue % short circuit for performance
                    end
                    currContrib = Wexp{i}(coefs(i), xpRho, xpPhi);
                    obj.w = obj.w + exp(1i .* 2 .* pi ./ obj.lambda .* currContrib);
                end
            else %notation == 'Z' % Zernike
                Wexp = cell(length(obj.pupilPrescription.zernikeTerms), 1);
                for i = 1 : length(Wexp)
                    Wexp{i} = wfromzernikecoef(obj.pupilPrescription.zernikeTerms(i));
                    if (obj.pupilPrescription.zernikeCoefficients(i) == 0)
                        continue % short circuit zero value terms for speed
                    end
                    currContrib = Wexp{i}(obj.pupilPrescription.zernikeCoefficients(i), xpRho, xpPhi);
                    obj.w = obj.w + exp(1i .* ( 2 .* pi ./ obj.lambda) .* currContrib);
                end
            end

            % delete obj.w outside the pupil
            obj.w(xpRho > 1) = 0;
        end
        function [] = w2psf(obj)
            obj.psf = ...
                abs(...
                    ifftshift(...
                        fft2(...
                            fftshift(obj.w)...
                        )...
                    )...
                ) .^ 2;
            obj.psf = obj.psf / max(obj.psf(:));
            
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

