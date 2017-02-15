classdef AberrationSwissArmyKnife < handle
    %AberrationSwissArmyKnife computes wavefronts, point spread functions,
    %and MTF of pupils, both perfect and aberrated.
    % version 0.9.0
    %
    % a note on FFT units,
    % when a FFT is computed, the pupil and PSF plane are linked by the
    % equation:
    % N*dp = (lambda*efl)/(di)
    % where
    %   N is the number of FFT samples
    %   dp is the sample spacing in the pupil plane
    %   lambda is the wavelength of light
    %   efl is is the effective focal length of the lens
    %   di is the sample spacing in the image plane

    % It can compute:
    % - W = the aberrated wavefront at the pupil               (buildPupil)
    % - PSF = |FT(W)|^2                                             (w2psf)
    % - MTF = |FT(PSF)| normalized to 1 at the origin             (psf2mtf)
    %
    % a set of plotting modules that consume AberationSwissArmyKnives are
    % included.  All methods are static.  If you try to plot something before it
    % has been computed, the plotting module will compute it for you first.
    % - WPlotter.m
    % - PSFPlotter.m
    % - MTFPlotter.m
    % - ComboPlotter.m
    %
    
    properties
        % inputs
        lambda
        efl
        fno
        pupil
        padding
        samples

        % outputs
        origin    % origin of wavefront and image
        w         % 2D aberrated wavefront (complex)
        wPhase    % phase map of w, for plotting
        wSliceX   % 1D slice of pupil amplitude along X
        wSliceY   % 1D slice of pupil amplitude along Y
        wSample   % "pixel" size in the pupil plane
        wAxis     % w slice coordinates (in normalized radii)
        psf       % 2D normalized intensity PSF
        psfSliceX % 1D slice of PSF through X
        psfSliceY % 1D slice of PSF through Y
        psfSample % "pixel" size in the PSF plane
        psfAxis   % PSF slice coordinates
        mtf       % 2D MTF of PSF
        mtfTan    % 1D horizontal slice of MTF
        mtfSag    % 1D vertical slice of MTF
        mtfAxis   % MTF slice coordinates
    end
    
    methods
        %% constructor
        function obj = AberrationSwissArmyKnife(varargin)          
            p = inputParser;
            p.KeepUnmatched = false;
            p.addParameter('lambda',  1,    @isnumeric);  % um
            p.addParameter('efl',     50,   @isnumeric);  % mm
            p.addParameter('fno',     4,    @isnumeric);  % unitless
            p.addParameter('pupil', PupilPrescription()); % aberrations are part of the pupil
            p.addParameter('padding', 8,    @isnumeric);  % necessary for good FFT result, xPupils
            p.addParameter('samples', 1024, @isnumeric);  % image width
            p.parse(varargin{:});
            fields = fieldnames(p.Results);
            for i = 1 : numel(fields)
                obj.(fields{i}) = p.Results.(fields{i});
            end
            
            obj.origin = floor(obj.samples / 2) + 1; %image origin
        end


        function [] = buildPupil(obj)
            %constructs a model of the lens' exit pupil

            % build a a slice through the coordinates of the normalized
            % pupil
            xpd = obj.efl / obj.fno * 1000; % *1000 converts mm to um
            pupilPlaneWidth = obj.padding * xpd;
            obj.wSample = pupilPlaneWidth / obj.samples * 2;
            
            obj.wAxis =(-1 : 2 / obj.samples : 1 - 2 / obj.samples) * (2 * obj.padding);
            
            % extend this slice to 2D
            [xpX, xpY] = meshgrid(obj.wAxis);
            xpRho = sqrt(xpX.^ 2 + xpY.^ 2);
            xpPhi = atan2(xpY, xpX);
            % Y, X is not a bug -- this is the convention of the 
            % zernike polynomials
            
            % prefill the pupil with ones.
            obj.w = ones(obj.samples);

            % pull the terms, coefficients, and function library for the notation
            if strcmpi(obj.pupil.notation, 'z')
                aberrationFn = @wfromzernikecoef;
            else
                aberrationFn = @wgenerator;
            end

            % compute the phase of each sample of the pupil
            netPhase = zeros(size(obj.w));
            pupilWasChanged = false;
            for i = 1 : length(obj.pupil.terms)
                if (obj.pupil.coefficients(i) == 0)
                    continue % short circuit 0 terms for better performance
                end
                Wexp = aberrationFn(obj.pupil.terms(i));
                contrib = Wexp(obj.pupil.coefficients(i), xpRho, xpPhi);
                netPhase = netPhase + contrib;
                pupilWasChanged = true;
            end
            obj.wPhase = netPhase;
            % compute the amplitude of the pupil from its phase.
            % we are interested in the amplitude (abs) not phase (atan2)
            if pupilWasChanged % need to handle offset from prefilling with ones
                obj.w = obj.w + exp(1i .* 2 .* pi ./ obj.lambda .* netPhase) - 1;
            end
            % annihilate outside the lens' pupil.
            obj.w(xpRho > 1) = 0;
            obj.wPhase(xpRho > 1) = NaN;
            
            % obscure as needed
            obj.w(xpRho < obj.pupil.centralObscuration) = 0;
            obj.wPhase(xpRho < obj.pupil.centralObscuration) = NaN;
            
            % take X and Y slices
            obj.wSliceX = obj.wPhase(obj.origin, :);
            obj.wSliceY = obj.wPhase(:, obj.origin)';
        end

        function w2psf(obj)
            % uses a fresnel diffraction calculation to compute the PSF
            % from a wavefront
            obj.psf = abs(ifftshift(fft2(fftshift(obj.w)))) .^ 2;
            obj.psf = obj.psf / max(max(obj.psf));
            obj.psfSliceX = obj.psf(obj.origin, :);
            obj.psfSliceY = obj.psf(:, obj.origin)';
            
            obj.psfSample = (obj.lambda * (obj.efl * 1e3)) ...
                          / (obj.wSample * obj.samples);
            obj.psfAxis = (-obj.samples / 2 : obj.samples / 2 - 1) .* obj.psfSample;
        end

        function [] = psf2mtf(obj)
            % computes the MTF from the PSF
            
            obj.mtf = abs(fft2(obj.psf));

            l = obj.samples / 2;
            obj.mtf = obj.mtf(1 : l, 1 : l);
            obj.mtf = obj.mtf ./ obj.mtf(1, 1);
            obj.mtfTan = obj.mtf(:, 1)';
            obj.mtfSag = obj.mtf(1, :);
            
            % everything to the right of 1/
            % uses the sampling frequency in the image plane to compute the
            % unit in "Hz".  It is inverted to produce lp/mm.
            obj.mtfAxis = 1 / (obj.psfSample / 1e3) * (0 : (obj.samples / 2)) / obj.samples; %1e3 = um to mm
            
            obj.mtfAxis = obj.mtfAxis(1 : l);
        end
    end
end
