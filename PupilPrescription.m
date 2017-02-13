classdef PupilPrescription < handle
    %PUPILPRESCRIPTION aberration description of a pupil

    properties
        notation
        terms
        coefficients
        centralObscuration
    end

    methods
        function obj = PupilPrescription(varargin)
            % parse inputs
            p = inputParser;
            p.KeepUnmatched = false;
            p.addParameter('notation',           'Z',     @ischar);
            p.addParameter('terms',              [040],   @isnumeric);
            p.addParameter('coefficients',       [0.000], @isnumeric);
            p.addParameter('centralObscuration',  0,      @isnumeric);
            p.parse(varargin{:});

            fields = fieldnames(p.Results);
            for i = 1 : numel(fields)
                obj.(fields{i}) = p.Results.(fields{i});
            end
        end
        function [] = setObscuration(linearPercent)
            obj.centralObscuration = linearPercent;
        end
    end

end
