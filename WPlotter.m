classdef WPlotter
    methods (Static = true)
        function [] = plotSliceX(AberrationSwissArmyKnife)
            %plots central horizontal slice of wavefront W

            checkW(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceX);
            xlabel('Normalized Pupil Radius');
            ylabel('OPD [\lambda]');
            xlim([-1, 1]);
            grid on
        end

        function [] = plotSliceY(AberrationSwissArmyKnife)
            %plots central horizontal slice of wavefront W

            checkW(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceY);
            xlabel('Normalized Pupil Radius');
            ylabel('OPD [\lambda]');
            xlim([-1, 1]);
            grid on
        end

        function [fig, ax] = plotSliceXY(AberrationSwissArmyKnife)
            %plots slice through both the X and Y axis of the pupil
            checkW(AberrationSwissArmyKnife);

            fig = figure;
            hold on
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceX, '.-');
            plot(AberrationSwissArmyKnife.wAxis, AberrationSwissArmyKnife.wSliceY, '.-');
            xlabel('Normalized Pupil Radius');
            ylabel('OPD [\lambda]');
            xlim([-1 1]);
            grid on
            ax = gca;
        end
        
        function [fig, ax] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of W.

            if nargin < 2
                plotType = 'surf';
            end
            checkW(AberrationSwissArmyKnife);
            
            fig = figure;
            axis square;

            wAxis = AberrationSwissArmyKnife.wAxis;
            [X, Y] = meshgrid(wAxis, wAxis');
            paddingPixels = length(wAxis) / (AberrationSwissArmyKnife.padding - 1);
            shift = ceil(paddingPixels / 2);
            ext = size(X, 1);
            plotX = X(shift : ext - shift, shift : ext - shift);
            plotY = Y(shift : ext - shift, shift : ext - shift);
            plotW = AberrationSwissArmyKnife.wPhase(shift : ext - shift, shift : ext - shift);
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
            c.Label.String = 'OPD [\lambda]';
            ax = gca;
        end
    end
end

function [] = checkW(AberrationSwissArmyKnife)
    if (isempty(AberrationSwissArmyKnife.w))
        AberrationSwissArmyKnife.buildPupil();
    end
end
