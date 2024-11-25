classdef RealTimeApp < handle
	%REALTIMEAPP A class to implement figure based game apps with tick cycle, real time execution.
	%   Detailed explanation goes here
	%
	%	Sebastian C. Robarts 2024 - sebrobarts@gmail.com
	properties
		Name = "Game"
		TargetFPS = 20;
		GridStep = 1;
		GridScale = [25 25];
		% StartFcnHdl		function_handle
		MainLoopFcn		function_handle		
		KeyPressFcn		function_handle
		% StopFcnHdl		function_handle
	end
	properties %(WeakHandle)
		Entities	GameEntity
	end
	properties (Transient)
		Pause = 0;
		BeingDeleted = 0;
		BlockInput = 0;
		Window		matlab.ui.Figure
		Board		matlab.graphics.axis.Axes
		Clock		timer
		InfoText
	end
	properties (Dependent)
		TickDuration
		FrameCount
		InstantFPS
		AverageFPS
		GridLimits
	end
	
	methods
		%% Creation
		function obj = RealTimeApp()
			%REALTIMEAPP Construct an instance of this class
			%   Detailed explanation goes here
			obj.KeyPressFcn = @obj.specificInput;
			obj.MainLoopFcn = @obj.specificMainLoop;
		end

		function initialise(obj)
			obj.makeWindow;
			obj.makeBoard;
			obj.makeClock;
			obj.adoptEntities;
			obj.makeInfoText;
		end

		function makeWindow(obj)
			obj.Window = figure('MenuBar','none','color',[0.1 0.1 0.1],'Visible','off');
			obj.Window.NumberTitle = 'off';
			obj.Window.Name = obj.Name;
			obj.Window.KeyPressFcn = @obj.commonInput;
			obj.Window.CloseRequestFcn = @obj.closeAppReq;
		end

		function makeBoard(obj)
			obj.Board = axes(obj.Window,'NextPlot','add','Xtick',([]),'Ytick',([]),...
							 'Xcolor','y','Ycolor','y','Color',[0.2 0.2 0.2],...
							 'Box','on','LineWidth',3,'Layer','top');
			% Fix the data unit lengths to be equal and set limits
			axis(obj.Board,'equal','manual',obj.GridLimits);
			obj.Board.Toolbar.Visible = 'off';
			disableDefaultInteractivity(obj.Board);
		end

		function makeClock(obj)
			tick = obj.TickDuration;
			obj.Clock = timer('StartDelay',0.5,'Period',tick,'ExecutionMode','fixedRate','BusyMode','drop');
							% 'StartFcn',@(~,~)StartGame,'TimerFcn',@(~,~)MainLoop,'StopFcn',@(~,~)TCleaner);
			obj.Clock.Name = "Game Clock";
			obj.loadFcns;
		end

		function loadFcns(obj)
			% obj.Clock.StartFcn = @obj.StartFcn;
			obj.Clock.TimerFcn = @obj.commonMainLoop;
			% obj.Clock.StopFcn  = obj.StopFcnHdl;
		end

		function adoptEntities(obj)
			if ~isempty(obj.Entities)
				for entityID = 1:length(obj.Entities)
					obj.Entities(entityID).initialise(obj);
				end
			end
		end

		function makeInfoText(obj)
			% Create textbox
			obj.InfoText = annotation(obj.Window,'textbox',...
							[0.015 0.9 0.15 0.1],...
							'Color',[1 1 1],...
							'FontSize',12,...
							'EdgeColor','none');
		end

		function start(obj)
			set(obj.Window,'Visible','on');
			start(obj.Clock);
		end
		
		%% Interactivity
		function commonInput(obj,~,press)
			%keypress Common functionality for app hotkeys
			%   Detailed explanation goes here
			if ~obj.BlockInput
				switch press.Key
					case {'escape'}
						close(obj.Window)
					case {'p'}
						if ~obj.Pause
							obj.Pause = 1;
						else
							obj.Pause = 0;
						end
					case {'f5'}
						close(obj.Window)
						obj.initialise;
						obj.start;
					otherwise
						obj.KeyPressFcn(press)
				end
				obj.BlockInput = 1;
			end
		end

		function specificInput(~,press)
			disp(press.Key);
		end

		%% Main
		function commonMainLoop(obj,src,evt)
			if ~obj.Pause && ~obj.BeingDeleted
				obj.advanceState
				obj.drawFrame;
				obj.MainLoopFcn();
				obj.BlockInput = 0;
			else
				obj.BlockInput = 0;
			end
		end

		function advanceState(obj)
			if ~isempty(obj.Entities)
				for entityID = 1:length(obj.Entities)
					obj.Entities(entityID).updatePosition;
				end
			end
		end

		function drawFrame(obj)
			if ~isempty(obj.Entities)
				for entityID = 1:length(obj.Entities)
					obj.Entities(entityID).redrawEntity;
				end
			end
			fnum = num2str(obj.FrameCount,'%i');
			fps  = num2str(obj.AverageFPS,'%.2f');
			fstr = ['Frame: ', fnum, newline, 'FPS: ', fps];
			obj.InfoText.String = fstr;
			drawnow;
		end

		function specificMainLoop(~)

		end
		%% Cleanup
		function closeAppReq(obj,src,evt)
		% Callback to execute on close request
			obj.BeingDeleted = 1;
			obj.TimerCleaner;
			pause(0.1)
			delete(src);
		end

		function TimerCleaner(obj)
			stop(obj.Clock);
			pause(0.1)
			delete(obj.Clock)
			T = timerfindall;
			if ~isempty(T)
				stop(T)
				pause(0.1)
				delete(T)
			end
		end

		%% Set. Methods
		% function set.KeyPressFcn(obj,keyfcn)
		% 	obj.KeyPressFcn = @(press) keyfcn(press);
		% end
		%% Get. Methods
		function tickdur = get.TickDuration(obj)
			tickdur_ms = round(1e3./obj.TargetFPS);
			tickdur = tickdur_ms*1e-3;
		end

		function frame = get.FrameCount(obj)
			frame = obj.Clock.TasksExecuted;
		end

		function fps = get.InstantFPS(obj)
			fps = 1./obj.Clock.InstantPeriod;
			if isnan(fps) || fps > obj.TargetFPS
				fps = obj.TargetFPS;
			end
		end

		function fps = get.AverageFPS(obj)
			fps = 1./obj.Clock.AveragePeriod;
			if isnan(fps)
				fps = obj.TargetFPS;
			end
		end

		function gridlims = get.GridLimits(obj)
			xlims = [-1,1] .* obj.GridScale(1);
			ylims = [-1,1] .* obj.GridScale(2);
			gridlims = [xlims,ylims];
		end
	end
end

