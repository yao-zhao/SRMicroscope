classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    properties (Constant)
       status_options = {'idle','stopping','live','zstack','movie'};
       % piezo conversion
        um_per_pix=6.5/100;
        datapath='I:\microscope_pics';
    end
    
    properties (Dependent)
        volts_per_pix
    end
    
    % handles to devices
    properties (SetAccess = public)
        camera % camera
        lightsources % light sources
        xystage % xy stage
        zstage % z stage
        joystick % joystick
        status % current status
        illumination % current light source
        illumination_options % current light source
    end
    
    % current status of the microscope
    properties
    end    
    
    methods
        % constructor
        function obj=Microscope()
            display('initiallizing...')
            % add camera
            obj.camera = CameraAndorZyla ();
%             %create nidaq session
%             obj.nidaq=daq.createSession('ni');
            % add light sources
            obj.lightsources=[LightsourceRGB('com4','brightfield'),...
                LightsourceSola('com3','fluorescent')];
            obj.illumination_options={obj.lightsources.label};
            obj.illumination=obj.illumination_options{1};
            obj.camera.setExposure(obj.getLightsource.exposure);
            % add xy stage
            obj.xystage = StageXYPrior('com5');
            % add z stage
            obj.zstage = StageZPrior.finescan;
            % add joystick
            obj.joystick = JoystickLogitech();
            % set status
            obj.setStatus('idle');
            display('done')
        end
        
        function setStatus (obj, status_in)
           for ii=1:length(obj.status_options)
                if strcmp(obj.status_options{ii},status_in)
                    obj.status = status_in;
                    return;
                end
           end
           warning('invalid status input');
        end
        
        function value=get.volts_per_pix(obj)
            value=obj.um_per_pix/obj.zstage.um_per_volts;
        end
        
        % switch the light on or off
        function switchLight(obj, on_or_off)
            if strcmpi(on_or_off,'on')
                obj.getLightsource.turnOn;
            elseif strcmpi(on_or_off,'off')
                obj.getLightsource.turnOff;
            else
                throw(MException('Microscope:SwitchLight',...
                    'unrecognized switch light command'));
            end
        end
        
        % set property value
        function didset=setProperty(obj,name, value)
            % set properties for the devices and processes
            try
                names=strsplit(name,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                handle.(['set',captalize(propname)])(value);
            catch exception
                warning(['error setProperty:',exception.message])
                didset=false;
            end
            function Name=captalize(name)
                Name=[upper(name(1)),lower(name(2:end))];
            end
        end
        
        % get property value
        function value=getProperty(obj,tag)
            try
                names=strsplit(tag,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                value=handle.(propname);
            catch exception
                warning(['error getProperty:',exception.message])
                value=[];
            end
        end
        
        % get device handle with label
        function handle=getDeviceHandle(obj,label)
            props=properties(obj);
            for i=1:length(props)
                for j=1:length(obj.(props{i}))
                if isprop(obj.(props{i})(j),'label')
                    if strcmp(obj.(props{i})(j).label,label)
                        handle=obj.(props{i})(j);
                        return
                    end
                end
                end
            end
            handle=[];
            warning(['cant not find device with label:',label])
        end
        
        function lock(obj,action)
            if strcmp(obj.status,'idle')
                obj.status = action.label;
            else
                exception=MException('Microscope:LockUnable',...
                    ['can''t lock the microscope while ',obj.status]);
                throw(exception);
            end
        end
                
        function unlock(obj,action)
            if strcmp(obj.status,action.label)
                obj.status = 'idle';
            else
                exception=MException('Microscope:UnLockUnable',...
                    'can''t unlock the microscope');
                throw(exception);
            end
        end
        
        function settings=getSettings(obj)
            settings=[];
            props=properties(obj);
            for i=1:length(props)
                for j=1:length(obj.(props{i}))
                    htmp=obj.(props{i})(j);
                    if isprop(htmp,'label')
                        label=htmp.label;
                        props2=properties(htmp);
                        for k=1:length(props2)
                            if ~strcmp(props2{k},'label')
                                settings.([label,'_',props2{k}])...
                                    =htmp.(props2{k});
                            end
                        end
                    end
                end
            end
        end
        
        % select light source with index
        function setIllumination(obj,str)
            value=find(strcmp(str,obj.illumination_options));
            if length(value)==1
                obj.illumination=obj.illumination_options{value};
                obj.camera.setExposure(...
                    obj.lightsources(value).exposure);
            else
                throw(MException('Microscope:IlluminationNotSupported',...
                    ['illumination mode not supported for ',str]))
            end
        end
        
        % get current light source
        function handle=getLightsource(obj)
            handle=obj.lightsources(strcmp(obj.illumination,...
                obj.illumination_options));
        end
        
        % destructor
        function delete(obj)
            display('closing...');
        end
    end
    
    methods (Static)

    end
    
    events
        IlluminationDidSet
%         DidStart
%         DidFinish
    end
    
end
