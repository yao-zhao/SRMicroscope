% add control buttons for microscope actions
function addControlButton(obj,x,y,microscope_action)

% set up ui control
pos=obj.getControlPanelPosition(x,y);
uic=uicontrol('Parent',obj.controlpanel_handle,...
    'Style','pushbutton',...
    'Unit','Pixels','Position',[pos(1) pos(2) 200 60],...
    'String',microscope_action.getEventDisplay('DidFinish'),...
    'Fontsize',20,...
    'Callback',@(hobj,eventdata)callbackFunc(obj,microscope_action),...
    'Tag',microscope_action.label);

% set up all event listeners
eves=events(microscope_action);
for i=1:length(eves)
    numlh=length(obj.listeners);
    obj.listeners(numlh+1)=...
        addlistener(microscope_action,eves{i},...
        @(hobj,eventdata)updateDisplay(uic,microscope_action...
        .getEventDisplay(eves{i})));
end
% update display
    function updateDisplay(hobj,str)
        if ishandle(hobj) && ~isempty(str)
            set(hobj,'String',str);
        end
        % if action (e.g.,Live) is selected for the first time, set 
        % histogram index to 1
        obj.microscope_handle.setHistIdx(1);
    end
% call back actions
    function callbackFunc(obj,action)
        if action.isRunning
            action.stop;
        else
            try
                action.run;
            catch error
                warning(error.message);
                obj.popWarning();
                set(uic, 'String',microscope_action.getEventDisplay('DidFinish'));
            end
        end
    end
end