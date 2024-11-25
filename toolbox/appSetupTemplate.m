%% Blank Canvas
close all; clear all; %#ok<CLALL>

%% Create New Instance of the RealTimeApp Class
newApp = RealTimeApp;

%% Initialise local variables and objects which will be referenced in app functions
staticVar = 'foo';	% static variables can be used to pass fixed values to the functions

function myObj = createObj(name,colour,relativePosition)
arguments
	name
	colour = 'w';
	relativePosition = [0,0]; % assign default values to make arguments optional
end
	myObj = MobileEntity;
	myObj.Name = name;
	myObj.addprop('customProperty'); % Add properties to store anything you like with the object
	myObj.Position = relativePosition;
	myObj.PlotOptions = {'o','MarkerSize',12,'MarkerEdgeColor','w','MarkerFaceColor',colour};
end

userObj = createObj("User",'y');	% handle objects store data across workspaces	
autoObj = createObj("Auto",'r',[-0.5,0.5]);

%% Add custom objects to the app
objList = [userObj,autoObj];
newApp.Entities = objList;

%% Set the core app functions
function keyInput(press,varargin)
obj = varargin{2};
	switch press.Key
		case {'uparrow','w'}
		
		case {'downarrow','s'}
		
		otherwise
			disp([press.Key, ' ', varargin{1}]);
	end
end

function mainLoop(app,objList)
	if ~app.BeingDeleted
		frame = app.FrameCount;
		updateLocalObj(objList(2),frame);
	end
end

newApp.KeyPressFcn = @(press) keyInput(press,staticVar,userObj);
newApp.MainLoopFcn = @() mainLoop(newApp,objList);

%% Initialise and start the app
newApp.initialise;
% userObj.Speed = 0.2;
newApp.start;

%% Local functions
function updateLocalObj(obj,val)
	obj.customProperty = val;
end