classdef WPlotter
    methods (Static = true)
        function [] = plotSliceX(AberrationSwissArmyKnife)
            %plots central horizontal slice of wavefront W

            checkW(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceX)
            xlabel('Pupil Radii');
            ylabel('Pupil Amplitude');
            title('Slices');
            grid on
        end

        function [] = plotSliceY(AberrationSwissArmyKnife)
            %plots central horizontal slice of wavefront W

            checkW(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceY)
            xlabel('Normalized Pupil Radius');
            ylabel('Pupil Amplitude'); 
            title('Slices');
            grid on
        end
        
        function [] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of W.

            if nargin < 2
                plotType = 'surf';
            end
            checkW(AberrationSwissArmyKnife);
            
            axis = AberrationSwissArmyKnife.wAxis;
            [X, Y] = meshgrid(axis, axis');
            paddingPixels = (AberrationSwissArmyKnife.padding - 1) * length(axis);
            shift = floor(paddingPixels / 2);
            ext = size(X, 1);
            plotX = X(shift + 1: ext - shift, shift + 1 : ext - shift);
            plotY = Y(shift + 1: ext - shift, shift + 1 : ext - shift);
            plotW = AberrationSwissArmyKnife.w(shift + 1: ext - shift, shift + 1: ext - shift);
            switch lower(plotType)
                case 'mesh'
                    mesh(plotX, plotY, plotW);
                case 'surf'
                    surf(plotX, plotY, plotW, 'EdgeColor', 'none');
            end
            xlim([-1, 1]);
            ylim([-1, 1]);
            view(0, 90);
            xlabel('Normalized Pupil X');
            ylabel('Normalized Pupil Y');
            c = colorbar();
            c.Label.String = 'Pupil Phase (modulo 2\pi)';
        end
    end
end

function [] = checkW(AberrationSwissArmyKnife)
    if (isempty(AberrationSwissArmyKnife.w))
        AberrationSwissArmyKnife.buildPupil();
    end
end
