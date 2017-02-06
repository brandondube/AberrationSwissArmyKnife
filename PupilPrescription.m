classdef PupilPrescription < handle
    %PUPILPRESCRIPTION aberration description of a pupil
    
    properties
        notation
        seidelTerms
        seidelCoefficients
        zernikeTerms
        zernikeCoefficients
        centralObscuration
    end
    
    methods
        function obj = PupilPrescription(varargin)
            % parse inputs
            p = inputParser;
            p.KeepUnmatched = false;
            p.addParameter('notation',            'Z',     @ischar);
            p.addParameter('seidelTerms',         [040],   @isnumeric);
            p.addParameter('seidelCoefficients',  [0.125], @isnumeric);
            p.addParameter('zernikeTerms',        [8],     @isnumeric);
            p.addParameter('zernikeCoefficients', [0.125], @isnumeric);
            p.addParameter('centralObscuration',  0,       @isnumeric);
            p.parse(varargin{:});

            fields = fieldnames(p.Results);
            for i = 1 : numel(fields)
                obj.(fields{i}) = p.Results.(fields{i});
            end
        end
        function [] = setSeidel(terms, coefficients)
            obj.seidelTerms = terms;
            obj.seidelCoefficients = coefficients;
        end
        function [] = setZernike(terms, coefficients)
            obj.zernikeTerms = terms;
            obj.zernikeCoefficients = coefficients;
        end
        function [] = setObscuration(linearPercent)
            obj.centralObscuration = linearPercent;
        end
    end
    
end
