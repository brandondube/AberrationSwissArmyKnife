classdef MTFPlotter
    methods (Static)
        function [fig, ax] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of MTF

            if nargin < 2
                plotType = 'surf';
            end
            checkMTF(AberrationSwissArmyKnife);

            fig = figure;
            pt = lower(plotType);
            [Fx, Fy] = meshgrid(AberrationSwissArmyKnife.mtfAxis, AberrationSwissArmyKnife.mtfAxis');
            switch pt
                case 'mesh'
                    mesh(Fx, Fy, AberrationSwissArmyKnife.mtf);
                case 'surf'
                    surf(Fx, Fy, AberrationSwissArmyKnife.mtf, 'EdgeColor', 'none');
                    shading interp;
            end
            view(49,16);
            xlim([0 1]);
            ylim([0 1]);
            xlabel('lp/mm-x');
            ylabel('lp/mm-y');
            zlabel('MTF');
            c = colorbar();
            c.Label.String = 'Normalized Intensity';
            ax = gca;
        end

        function [] = plotTan(AberrationSwissArmyKnife)
            %plots slice of Tangential MTF

            checkMTF(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.mtfAxis, AberrationSwissArmyKnife.mtfTan)
            xlabel('lp/mm');
            ylabel('MTF');
            ylim([0 1]);
            grid on
        end
        
        function [] = plotSag(AberrationSwissArmyKnife)
            %plots slice of Tangential MTF

            checkMTF(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.mtfAxis, AberrationSwissArmyKnife.mtfSan)
            xlabel('lp/mm');
            ylabel('MTF');
            ylim([0 1]);
            grid on
        end

        function [fig, ax] = plotBoth(AberrationSwissArmyKnife, dashTan)
            % plots both the tangential and sagittal MTF

            a = AberrationSwissArmyKnife;
            if nargin < 2
                dashTan = false;
            end
            checkMTF(a);

            fig = figure;
            hold on;
            if dashTan
                plot(a.mtfAxis, a.mtfTan, 'LineStyle', '--');
                plot(a.mtfAxis, a.mtfSag, 'LineStyle', '-');
            else
                plot(a.mtfAxis, a.mtfTan, 'LineStyle', '-');
                plot(a.mtfAxis, a.mtfSag, 'LineStyle', '--');
            end
            hold off;
            xlabel('lp/mm');
            ylabel('MTF');
            ylim([0 1]);
            xlim([0, 200]);
            grid on
            legend('Tangential', 'Sagittal', 'Location', 'southwest', 'Orientation', 'vertical');
            ax = gca;
        end
    end
end

function [] = checkMTF(AberrationSwissArmyKnife)
    if (isempty(AberrationSwissArmyKnife.mtf))
        if (isempty(AberrationSwissArmyKnife.psf))
            if (isempty(AberrationSwissArmyKnife.w))
                AberrationSwissArmyKnife.buildPupil();
            end
            AberrationSwissArmyKnife.w2psf();
        end
        AberrationSwissArmyKnife.psf2mtf();
    end
end
