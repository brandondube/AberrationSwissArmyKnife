classdef PSFPlotter
    methods (Static)
        function [] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of PSF
            
            if nargin < 2
                plotType = 'surf';
            end
            checkPSF(AberrationSwissArmyKnife);

            figure;
            axis = AberrationSwissArmyKnife.psfAxis;
            [U,V] = meshgrid(axis, axis');

            pt = lower(plotType);
            switch pt
                case 'mesh'
                    mesh(U,V,AberrationSwissArmyKnife.psf);
                case 'surf'
                    surf(U,V,AberrationSwissArmyKnife.psf, 'EdgeColor', 'none');
                    shading interp;
            end
            xlim([-AberrationSwissArmyKnife.padding, AberrationSwissArmyKnife.padding]);
            ylim([-AberrationSwissArmyKnife.padding, AberrationSwissArmyKnife.padding]);
            view(0, 90);
            xlabel('\lambdaN'); ylabel('\lambdaN');
            zlabel('PSF Rel. Intensity');
            c = colorbar();
            c.Label.String = 'Normalized Intensity';
        end

        function [] = plotSliceX(AberrationSwissArmyKnife)
            %plots slice of the PSF through the X axis

            checkPSF(AberrationSwissArmyKnife);

            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice,'.-');
            xlabel('\lambdaN');
            ylabel('Relative Intensity');
            xlim([-4 4]);
            grid on
        end

        function [] = plotSliceY(AberrationSwissArmyKnife)
            %plots slice of the PSF through the Y axis

            checkPSF(AberrationSwissArmyKnife);

            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice, '.-');
            xlabel('\lambdaN');
            ylabel('Relative Intensity');
            xlim([-4 4]);
            grid on
        end

        function [] = plotSliceXY(AberrationSwissArmyKnife)
            %plots slice through both the X and Y axis of the pupil

            figure;
            hold on
            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice, '.-');
            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice, '.-');
            xlabel('\lambdaN');
            ylabel('Relative Intensity');
            xlim([-4 4]);
            grid on
        end
    end
end

function [] = checkPSF(AberrationSwissArmyKnife)
    if (isempty(AberrationSwissArmyKnife.psf))
        if (isempty(AberrationSwissArmyKnife.w))
            AberrationSwissArmyKnife.buildPupil();
        end
        AberrationSwissArmyKnife.w2psf();
    end
end
