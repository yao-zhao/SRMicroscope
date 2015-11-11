classdef MicroscopeActionZstack < MicroscopeAction
    %zstack class for microscope actions
    %   Yao Zhao 11/10/2015
    
    properties (SetAccess = protected)

    end
    
    methods
        function obj = MicroscopeActionZstack(microscope,image_axes)
            obj@MicroscopeAction(microscope,image_axes);
            obj.label = 'zstack';
        end
        
        function startAction(obj)
            % call super
            startAction@MicroscopeAction(obj);
            % handles
            zstage_handle=obj.microscope_handle.zstage;
            trigger_handle=obj.microscope_handle.trigger;
            camera_handle=obj.microscope_handle.camera;
            % set light source
            trigger_handle.setLightsources...
                (obj.microscope_handle.getLightsource);
            % create tiff
            tif=TiffIO(obj.microscope_handle.datapath,obj.label);
            tif.fopen(obj.microscope_handle.camera.getSize);
            % clear image
            if ishandle(obj.image_axes)
                cla(obj.image_axes);axis equal;colormap gray;
            end
            % start camera
            camera_handle.prepareModeSequence();
            camera_handle.startSequenceAcquisition();
            % start nidaq in background
            zarray=zstage_handle.getZarray();
            trigger_handle.start(trigger_handle.getOutputQueueStack(zarray));
            % run event loop
            while trigger_handle.isRunning
                if ishandle(obj.image_axes)
                    cla(obj.image_axes);
                    imagesc(camera_handle.getLastImage);
                end
                for i=1:3
                    img=camera_handle.popNextImage;
                    if ~isempty(img)
                        tif.fwrite(img)
                    end
                end
            end
            while ~isempty(img)
                img=camera_handle.popNextImage;
                tif.fwrite(img)
            end
            % finish
            trigger_handle.finish(zstage_handle.zoffset);
            camera_handle.stopSequenceAcquisition();
            % save file
            tif.fclose(obj.microscope_handle.getSettings);
            % finish
            obj.finishAction;
        end
        
        function stopAction(obj)
            obj.microscope_handle.trigger.finish(...
                obj.microscope_handle.zstage.zoffset);
        end
        
        % get event display for UI
        function dispstr=getEventDisplay(obj,eventstr)
            switch eventstr
                case 'DidStart'
                    dispstr = 'Stop Zstack';
                case 'DidFinish'
                    dispstr = 'Zstack';
                otherwise
                    dispstr=getEventDisplay@MicroscopeAction(obj,eventstr);
            end
        end

    end
    
    events
    end
    
end

