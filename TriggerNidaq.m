classdef TriggerNidaq < Trigger
    % trigger class for device synchronization
    %   Yao Zhao 11/10/2015

    properties (SetAccess = protected)
        zstage
        fluorescent
        brightfield
        camera
    end
    
    methods
        function obj=TriggerNidaq()
            obj@Trigger();
            obj.clock=daq.createSession('ni');
            obj.clockrate=1000;
            obj.framerate=10;
            obj.zstage = obj.clock.addAnalogOutputChannel('Dev1',0,'Voltage');
            obj.zstage.Name = 'Z scan (output)';
%                 ch12 = obj.nidaq.addAnalogInputChannel('Dev1',0,'Voltage');
%                 ch12.Name = 'Z position (input)';
            obj.camera = obj.clock.addDigitalChannel('Dev1','Port0/Line0','OutputOnly');
            obj.camera.Name = 'camera triggering (output)';
            % fluorescence
%             obj.fluorescent=obj.clock.addDigitalChannel('Dev1','Port1/Line0','OutputOnly');
%             obj.fluorescent.Name = 'Illumination Fluorescent (output)';
            obj.brightfield=obj.clock.addDigitalChannel('Dev1','Port0/Line1','OutputOnly');
            obj.brightfield.Name = 'Illumination Red (output)';
            % set output voltage zero
%             obj.clock.outputSingleScan([0 0 0 0]);
        end
        
        function setClockrate(obj,clockrate)
            
            setClockrate@Trigger(clockrate);
        end
        
        function setFramerate(obj,framerate)
            
            setFramerate@Trigger(clockrate);
        end
        
        function delete(obj)
        end
    end
    
    methods 
        function start(obj)
        end
        function bool =isRunning(obj)
%            
        end
    end
    
    events
    end
    
end