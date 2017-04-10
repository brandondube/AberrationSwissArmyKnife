classdef PSFPlotter
    methods (Static)
        function [fig, ax] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of PSF
            
            if nargin < 2
                plotType = 'surf';
            end
            checkPSF(AberrationSwissArmyKnife);

            fig = figure;
            axis square;
            pAxis = AberrationSwissArmyKnife.psfAxis;
            [U,V] = meshgrid(pAxis, pAxis');

            pt = lower(plotType);
            switch pt
                case 'mesh'
                    mesh(U, V, AberrationSwissArmyKnife.psf);
                case 'surf'
                    surf(U, V, AberrationSwissArmyKnife.psf, 'EdgeColor', 'none');
                    shading interp;
            end
            xlim([-15, 15]);
            ylim([-15, 15]);
            view(0, 90);
            xlabel('\mum');
            ylabel('\mum');
            zlabel('PSF Rel. Intensity');
            c = colorbar();
            c.Label.String = 'Normalized Intensity';
            ax = gca;
        end

        function [] = plotSliceX(AberrationSwissArmyKnife)
            %plots slice of the PSF through the X axis

            checkPSF(AberrationSwissArmyKnife);

            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSliceX,'.-');
            xlabel('\mum');
            ylabel('Relative Intensity');
            xlim([-10 10]);
            grid on
        end

        function [] = plotSliceY(AberrationSwissArmyKnife)
            %plots slice of the PSF through the Y axis

            checkPSF(AberrationSwissArmyKnife);

            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSliceY, '.-');
            xlabel('\mum');
            ylabel('Relative Intensity');
            xlim([-10 10]);
            grid on
        end

        function [fig, ax] = plotSliceXY(AberrationSwissArmyKnife)
            %plots slice through both the X and Y axis of the pupil

            fig = figure;
            hold on
            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice, '.-');
            plot(AberrationSwissArmyKnife.psfAxis, AberrationSwissArmyKnife.psfSlice, '.-');
            xlabel('\mum');
            ylabel('Relative Intensity');
            xlim([-10 10]);
            grid on
            ax = gca;
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
