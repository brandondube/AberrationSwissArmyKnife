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
        function obj = PupilPrescription(notation, seidelTerms, seidelCoefficients, zernikeTerms, zernikeCoefficients, centralObscuration)
            % the flying V of default parameters
            if nargin < 6
                if nargin < 5
                    if nargin < 4
                        if nargin < 3
                            if nargin < 2
                                if nargin < 1
                                    notation = 'Z';
                                end
                                seidelTerms = ['',''];
                            end
                            seidelCoefficients = [0,0];
                        end
                        zernikeTerms = [1,2,8];
                    end
                    zernikeCoefficients = [0,0,1];
                end
                centralObscuration = 0;
            end
            obj.notation = notation;
            obj.seidelTerms = seidelTerms;
            obj.seidelCoefficients = seidelCoefficients;
            obj.zernikeTerms = zernikeTerms;
            obj.zernikeCoefficients = zernikeCoefficients;
            obj.centralObscuration = centralObscuration;
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
