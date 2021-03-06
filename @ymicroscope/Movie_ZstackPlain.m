function [  ] = Movie_ZstackPlain( obj, varargin )
% do a movie squence, not zstack
% do not have drift control

if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if nargout == 0
    savedata = 1;
elseif nargout == 1
    savedata = 0;
else
    error('wrong number of output')
end

magic_number = 0; % guessing the milli second take to stablily wrap up exposure

if obj.exposure + magic_number >= 1000/obj.framerate
    msgbox('error: exposure is longer than the frame interval')
    return;
end

if strcmp(obj.status,'standing')
    obj.status = 'movie_running_zstack_plain';
    
    % set scanning parameters
%     stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
    stacks = zeros(1,obj.movie_cycles);
    width = obj.mm.getImageWidth(); % image width
    height = obj.mm.getImageHeight(); % image height
    
    % initialize ni daq
    rate_multiplier = 2;
    obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acuisition rate
    obj.nidaq.IsContinuous=0; % continuous writing
    
    % prepare data to send
    zdata=stacks*obj.volts_per_pix+obj.zoffset; % data to send
    numdata = length(zdata); % length and data
    zdata = reshape(ones(rate_multiplier,1)*zdata,...
        rate_multiplier*numdata,1); % data for z scan at clock rate
    camtrigger = reshape([0;1+zeros(rate_multiplier-1,1)]*ones(1,numdata),...
        rate_multiplier*numdata,1); % trigger for camera
    
    obj.nidaq.queueOutputData([zdata,camtrigger;zdata(end),0])
    
    % log piezo position
    piezopos = zeros(size(zdata));
    counter = 0;
    data_pointer = libpointer('doublePtr',piezopos);
    counter_pointer = libpointer('doublePtr',counter);
    lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
        @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
    
    % camera setting 
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
    obj.mm.setExposure(obj.exposure); % set exposure time, ????? work or not
    obj.mm.clearCircularBuffer(); % clear the buffer for image storage
    
    % prepare data acquisition
    obj.mm.initializeCircularBuffer();
    obj.mm.prepareSequenceAcquisition(andorCam);
        
    obj.SwitchLight('on');
    if UI_enabled
        set(hobj,'String','Movie Running')
        pause(.01)
    end
    
    % start acquisition
    obj.mm.startContinuousSequenceAcquisition(0);
    obj.nidaq.startBackground;
    
    % save data header
    istack=0;
    if savedata
        filename=obj.GetFileHeader('movie');
        imgtif=Tiff(filename,'w8');
        tagstruct = obj.GetImageTag('Andor Zyla 5.5');
    else
        img_3d=zeros(width,height,obj.numstacks);
    end
    
    % live in background
    while obj.nidaq.IsRunning
        if UI_enabled
            img=obj.mm.getLastImage();
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            axes(obj.imageaxis_handle);cla;
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
        end
        if obj.mm.getRemainingImageCount()>0
            istack=istack+1;
            imgtmp=obj.mm.popNextImage();
            img = reshape(imgtmp, [width, height]);
            if savedata
                imgtif.setTag(tagstruct);
                imgtif.write(img);
                imgtif.writeDirectory;
            else
                img_3d(:,:,istack)=img;
            end
        end
        pause(.01);
    end
    tic

    % warning for buffer overflow
    if obj.mm.isBufferOverflowed
        warning('camera buffer over flowed, try set larger memory for the camera');
    end
    
    % ending acquisition
    obj.nidaq.outputSingleScan([obj.zoffset,0]); % reset starting position
    obj.nidaq.stop;
    delete(lh);
    obj.mm.stopSequenceAcquisition;
    obj.SwitchLight('off');
    
    % continue to save
    if UI_enabled
        set(hobj,'String','Zstack Saving')
        pause(.01)
    end
    while obj.mm.getRemainingImageCount()>0
        istack=istack+1;
        imgtmp=obj.mm.popNextImage();
        img = reshape(imgtmp, [width, height]);
        if savedata
            imgtif.setTag(tagstruct);
            imgtif.write(img);
            imgtif.writeDirectory;
        else
            img_3d(:,:,istack)=img;
        end
    end
    
    toc
    
    if istack~=obj.numstacks 
        warning(['number of images in collected: ',...
            num2str(istack)]);
    end
    
    if savedata
        imgtif.close();
        %save setting        
        setting=obj.GetSetting;
        save([filename(1:end-3),'mat'],'setting');
    end
    
    if UI_enabled
        set(hobj,'String','Start Movie')
    end
    obj.status = 'standing';
else
    msgbox(['error: microscope is ',obj.status]);
end


end