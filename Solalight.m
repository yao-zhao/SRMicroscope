classdef Solalight < Lightsource
    % class for sola light, fluorescent illumination
    %  Yao Zhao 11/7/2015
    
    properties
    end
    
    methods
        
        function obj = Solalight(comport)
            % add com port control
            try
                obj.com = serial(comport);
                fopen(obj.com);
                fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
                fprintf(obj.com,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
                disp('Sola connected!')
            catch 
                warning('Sola illuminator! not connected to com port');
            end
        end
        
        function setExposure(obj,exposure)
            obj.exposure = exposure;
        end
        
        function setIntensity(obj,intensity)
            % choose between 0-255
            if intensity<0
                obj.intensity=0;
                warning('zoffset goes below zero');
            elseif intensity>255
                obj.intensity=255;
                warning('zoffset goes above 255');
            else
                obj.intensity=intensity;
            end
            s=dec2hex(255-obj.intensity);
            if length(s)==1
                s=['0',s];
            end
            fprintf(obj.com,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') ...
                hex2dec('04') hex2dec(['F',s(1)]) hex2dec([s(2),'0']) hex2dec('50')]));
        end
        
        function turnOn(obj)
            
        end
        
        function turnOff(obj)
            
        end
        
        function delete(obj)
            fclose(obj.com);
        end
    end
    
end

