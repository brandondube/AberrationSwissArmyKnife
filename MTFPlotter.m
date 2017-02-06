classdef MTFPlotter
    methods (Static)
        function [] = plot3D(AberrationSwissArmyKnife, plotType)
            %plot 3D rendition of MTF

            if nargin < 2
                plotType = 'surf';
            end
            checkMTF(AberrationSwissArmyKnife);

            figure;
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
            xlabel('1/\lambdaN');
            ylabel('1/\lambdaN');
            zlabel('MTF');
        end

        function [] = plotTan(AberrationSwissArmyKnife)
            %plots slice of Tangential MTF

            checkMTF(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.mtfAxis, AberrationSwissArmyKnife.mtfTan)
            xlabel('1/\lambdaN');
            ylabel('MTF');
            ylim([0 1]);
            grid on
        end
        
        function [] = plotSag(AberrationSwissArmyKnife)
            %plots slice of Tangential MTF

            checkMTF(AberrationSwissArmyKnife);
            plot(AberrationSwissArmyKnife.mtfAxis, AberrationSwissArmyKnife.mtfSan)
            xlabel('1/\lambdaN');
            ylabel('MTF');
            ylim([0 1]);
            grid on
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
