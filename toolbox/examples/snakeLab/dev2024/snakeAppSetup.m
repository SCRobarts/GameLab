% SNAKEAPPSETUP.m
%
%	Sebastian C. Robarts 2024 - sebrobarts@gmail.com

%% Blank Canvas
close all; clear all; %#ok<CLALL>

%% Defaults
if size(groot().MonitorPositions,1) > 1
	set(0, 'DefaultFigurePosition', [groot().MonitorPositions(2,1:2)+100 800 800])
end

%% Create App and Entities
snakeApp = RealTimeApp;
snakeApp.TargetFPS = 120;
snake = SnakeEntity;
% snake.grow(5);
food = FoodEntity;
snakeApp.KeyPressFcn = @(press) snakeInput(snake,press);
snake.Speed = 1;
snakeApp.Entities = snake;
snakeApp.Entities = [snakeApp.Entities,food];
snakeApp.MainLoopFcn = @() mainLoop(snakeApp,snake,food);

% food2 = FoodEntity;
% snakeApp.Entities(3) = food2;
% food2.XY = [-5,-5];
% snake.Length = 5;
% snakeApp.Speed = 1;

%% App Specific Functionality
function snakeInput(snake,press)
	if ~snake.ActionQueued
		snake.ActionQueued = 1;
		switch press.Key
			case {'uparrow','w'}
				snake.Direction = [0,1];
			case {'leftarrow','a'}
				snake.Direction = [-1,0];
			case {'downarrow','s'}
				snake.Direction = [0,-1];
			case {'rightarrow','d'}
				snake.Direction = [1,0];
			otherwise
				snake.ActionQueued = 0;
				disp(press.Key);
		end
	end
end

function hitTest(snake,food)
headXY = snake.XY(1,:);
tailXY = snake.XY(2:end,:);
res = snake.Resolution;
	if abs(headXY-food.XY) < res
		food.randomisePosition;
		snake.grow;
	end
	if any(all(tailXY == headXY,2))
		segID = (all(tailXY == headXY,2));
		segXY = tailXY(segID,:);
		plot(segXY(1),segXY(2),'rh','MarkerSize',12,'MarkerFaceColor','r');
		plot(segXY(1),segXY(2),'rh','MarkerSize',9,'MarkerFaceColor','y');
		snake.kill;
	end
end

%% Launch
snakeApp.initialise;
% snakeApp.Pause = 1;
snakeApp.start;

%% Main Loop Function
function mainLoop(app,snake,food)
	if snake.Dead && ~app.Pause
		snakeAppSetup;
	else
		hitTest(snake,food)
		if snake.Dead
			app.Pause = 1;
		end
	end
end