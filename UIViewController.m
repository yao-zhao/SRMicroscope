classdef UIViewController < UIView
    %UIView Controller to control the UIView
    % Yao Zhao, 11/9/2015
    
    properties
        microscope_handle
        live
        capture
        zstack
        
    end
    
    methods
        function obj = UIViewController(microscope_handle)
            obj@UIView();
            obj.microscope_handle=microscope_handle;
            obj.actions=[ MicroscopeActionLive('live',...
                obj.microscope_handle,obj.imageaxis_handle),...
                MicroscopeActionCapture('capture',...
                obj.microscope_handle,obj.imageaxis_handle),...
                MicroscopeActionSequenceZstack('zstack',...
                obj.microscope_handle,obj.imageaxis_handle)];
  
            % add controls
            for i=1:length(obj.actions)
                ir= floor((i-1)/4);
                ic= mod((i-1),4);
                obj.addControlButton(ic,ir,obj.actions(i));
            end

            % add selectors
            obj.addControlSelector(0,2,'illumination','illumination',...
                obj.microscope_handle)
            obj.addControlSelector(1,2,'roi','Camera ROI',...
                obj.microscope_handle.camera)

            % add parameters
            obj.addParamCell(0,0,'exposure','brightfield exposure(ms)',...
                obj.microscope_handle.lightsources(1));
            obj.addParamCell(0,1,'intensity','brightfield itensity(1-10)',...
                obj.microscope_handle.lightsources(1));
            obj.addParamCell(0,2,'exposure','fluorescent exposure(ms)',...
                obj.microscope_handle.lightsources(2));
            obj.addParamCell(0,3,'intensity','fluorescent itensity(0-255)',...
                obj.microscope_handle.lightsources(2));
            obj.addParamCell(1,0,'zoffset','piezo center (volts)',...
                obj.microscope_handle.zstage);
            obj.addParamCell(1,1,'numstacks','number of stacks',...
                obj.microscope_handle.zstage);
            obj.addParamCell(1,2,'stepsize','step size (pixels)',...
                obj.microscope_handle.zstage);
            obj.addParamCell(2,0,'moviecycles','number of movie cycles',...
                obj);
            obj.addParamCell(2,1,'movieinterval','movie interval (mins)',...
                obj);


        end
    end
    
    events
    end
    
end

