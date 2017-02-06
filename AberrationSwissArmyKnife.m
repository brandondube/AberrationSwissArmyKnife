classdef AberrationSwissArmyKnife < handle
    %AberrationSwissArmyKnife computes wavefronts, point spread functions,
    %and MTF of aberrations in units of pupils, lambdaN and 1/lambdaN resp.
    % -version 0.4-

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
    % Example: (coefficients are in um, not in wavelengths)
    % s = AberrationSwissArmyKnife();
    % s.buildPupil();
    % s.w2psf();

    
    properties
        % variables
        lambda
        efl
        fno
        pupil
        pitch
        padding
        samples

        % results
        origin    % origin of wavefront and image
        w         % 2D aberrated wavefront
        wSliceX   % 1D slice of pupil amplitude along X
        wSliceY   % 1D slice of pupil amplitude along Y
        wAxis     % w slice coordinates (in normalized radii)
        psf       % 2D intensity PSF
        psfSliceX % 1D slice of PSF through X
        psfSliceY % 1D slice of PSF through Y
        psfAxis   % PSF slice coordinates (in units of lambdaN)
        mtf       % 2D MTF of PSF
        mtfTan    % 1D horizontal slice of MTF (?)
        mtfSag    % 1D vertical slice of MTF (?)
        mtfAxis   % MTF slice coordinates (in units of 1/lambdaN)
    end
    
    methods
        %% constructor
        function obj = AberrationSwissArmyKnife(varargin)          
            p = inputParser;
            p.KeepUnmatched = false;
            p.addParameter('lambda',  0.5,  @isnumeric);  % 
            p.addParameter('efl',     1,    @isnumeric);  % mm
            p.addParameter('fno',     1,    @isnumeric);  % unitless
            p.addParameter('pupil', PupilPrescription()); % aberrations are part of the pupil
            p.addParameter('pitch',   5,    @isnumeric);  % um
            p.addParameter('padding', 4,    @isnumeric);  % necessary for good FFT result, xPupils
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

            % build a a slice through the coordinates in pupil space, normalized to 1.
            obj.wAxis = linspace(-obj.padding, obj.padding, round(obj.samples));
            
            % extend this slice to 2D
            [xpX, xpY] = meshgrid(obj.wAxis);
            xpRho = sqrt(xpX.^ 2 + xpY.^ 2);
            xpPhi = atan2(xpY, xpX);
            
            % prefill the pupil with ones.
            obj.w = ones(obj.samples);

            % pull the terms, coefficients, and function library for the notation
            if obj.pupil.notation == 'Z'
                terms = obj.pupil.zernikeTerms;
                coefficients = obj.pupil.zernikeCoefficients;
                aberrationFn = @wfromzernikecoef;
            else
                terms = obj.pupil.seidelTerms;
                coefficients = obj.pupil.seidelCoefficients;
                aberrationFn = @wgenerator;
            end

            % compute the phase of each sample of the pupil
            netPhase = 0;
            for i = 1 : length(terms)
                Wexp = aberrationFn(terms(i));
                contrib = Wexp(coefficients(i), xpRho, xpPhi);
                netPhase = netPhase + contrib;
            end

            % compute the amplitude of the pupil from its phase.
            % we are interested in the amplitude (abs) not phase (atan2)
            obj.w = real(obj.w .* exp(1i .* 2 .* pi ./ obj.lambda .* netPhase));
            
            % annihilate outside the lens' pupil.
            obj.w(xpRho > 1) = 0;
            % obscure as needed
            obj.w(xpRho < obj.pupil.centralObscuration) = 0;
            
            % take X and Y slices
            obj.wSliceX = obj.w(obj.origin,:);
            obj.wSliceY = obj.w(:,obj.origin);
        end

        function w2psf(obj)
            %compute intensity pf the point spread function from the wavefront
            obj.psf = abs(ifftshift(fft2(fftshift(obj.w)))) .^ 2;
            obj.psf = obj.psf / sum(sum(obj.psf));
            obj.psfSliceX = obj.psf(obj.origin, :);
            obj.psfSliceY = obj.psf(:, obj.origin);
            obj.psfAxis = ((1 : obj.samples) - obj.origin) / obj.padding; 
        end

        function [] = psf2mtf(obj)
            obj.mtf = abs(fft2(obj.psf));

            l = obj.samples / 2;
            obj.mtf = obj.mtf(1 : l, 1 : l);
            obj.mtf = obj.mtf ./ obj.mtf(1, 1);
            obj.mtfTan = obj.mtf(:, 1);
            obj.mtfSag = obj.mtf(1, :);

            % sample = obj.psfAxis.X(2) - obj.psfAxis.X(1);
            obj.mtfAxis = ((1 : obj.samples) - obj.origin) / obj.padding;
            obj.mtfAxis = obj.mtfAxis(1:l);
            % obj.mtfAxis = linspace(0, 1, length(obj.psfAxis.X) / 2) ./ sample;

            obj.mtfTan = obj.mtf(:, 1);
            obj.mtfSag = obj.mtf(1, :);
            % obj.mtfAxis = obj.mtfAxis(1:l);
        end
        function mtfxx(obj, xx)
            %computes the spatial frequency at which the MTF (%) xx is reached
            if nargin < 2
                xx = 50;
            end
            xx = xx / 100;
            I = find(obj.mtfTan < xx, 1);   %to deal with non monotonicity
            
                obj.mtfxxTan = interp1(obj.mtfTan(1:I), ...
                    obj.mtfAxis(1 : I), xx);
                obj.mtfxxSag = interp1(obj.mtfSag(1:I), ...
                    obj.mtfAxis(1 : obj.origin), xx);
                fprintf('\nTangential MTF%.0f = %.3f c/p, %.2f lp/mm \n', xx * 100,...
                    obj.mtfxxTan / obj.in.lambda / obj.in.N * obj.in.pitch,...
                    obj.mtfxxTan / obj.in.lambda / obj.in.N * 1000)
                fprintf('Sagittal MTF%.0f   = %.3f c/p, %.2f lp/mm \n', xx * 100,...
                    obj.mtfxxSag / obj.in.lambda / obj.in.N * obj.in.pitch,...
                    obj.mtfxxSag / obj.in.lambda / obj.in.N * 1000)
                fprintf('Wavelength       = %.2fum\n', obj.in.lambda)
                fprintf('f-number         = %.0f\n', obj.in.N)
                fprintf('Pixel Pitch      = %.1fum\n', obj.in.pitch)
        end 
    end
end