classdef UIViewController < UIView
    %UIView Controller to control the UIView
    % Yao Zhao, 11/9/2015
    
    properties
        microscope_handle
        uilooprunning 
        uilooprate =10;
        live
        capture
    end
    
    methods
        function obj = UIViewController(microscope_handle)
            obj@UIView();
            obj.microscope_handle=microscope_handle;
            obj.live=MicroscopeActionLive(obj.microscope_handle,obj.imageaxis_handle);
            obj.capture=MicroscopeActionCapture(obj.microscope_handle,obj.imageaxis_handle);
            % add controls
            obj.addControlButton(0,0,obj.live);
            obj.addControlButton(1,0,obj.capture);
%             obj.addControlButton(1,0,'capture','Capture',...
%                 @(hobj,eventdata)obj.callbackActions(hobj,eventdata));
%             obj.addControlButton(2,0,'zstack','Zstack',[]);
%             obj.addControlButton(3,0,'movie','Movie',[]);
%             obj.addControlButton(0,1,'light','Light',[]);
%             obj.addControlButton(1,1,'joystick','JoysTick',[]);
%             obj.addControlButton(2,1,'zfocus','ZFocus',[]);

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


        end
    end
    
    events
    end
    
end

