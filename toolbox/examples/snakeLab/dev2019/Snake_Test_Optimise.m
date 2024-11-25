%Let's get snakey - Seb Robarts - scr2 - 5/11/2019
function Snake_Test_Optimise

clc;
clear all;
%%Resolution of snake motion (Changing this will change length and cause graphical issues)
Res = 0.5;			

%%%%%%%%%%%%%% Edit this value to increase or decrease difficulty %%%%%%%%%%%%%%
Speed = 0.1;

Dir = 1;							%Sets direction (1,2,3,4 -> N,E,S,W)
SLength = 3;						%Initialise snake length
PlayerPos = [0,0];					%Starting position
Food = [10,10];
FoodPic = 0;
Snake = [0 0;0 -Res;0 -2*Res];		%Initialise the snake
SnakePic = 0;
Death = 0;							%Snake is no dead
Close = 0;							%Initialise the exit var
Pause = 0;
KeyDown = 0;
	
%%Initialise the figure and define the Keyboard callback
GameFig = figure ('Renderer','painters','WindowState','maximized','MenuBar','none','color',[0.1 0.1 0.1],'KeyPressFcn',@KeyAct);

TitleScreen = axes('color',[0.1 0.1 0.1],'OuterPosition',[0.25 0.25 0.5 0.5],...
	'Xcolor','none','Ycolor','none');
title({'Welcome to Seb''s Snake!';'WASD or Arrows to change direction';'p to pause, c to exit';...
	'OPTIMISATION UPDATE';'Enemies to be added in a later patch, stay tuned!';'Press any key to continue'},'FontSize',30,'Color','w')
try
	waitforbuttonpress;
catch
	Close = 1;
	return
end

%% Change Speed in order to adjust difficulty and account for differences in processor clock %%
MyTimer = timer('StartDelay',0.5,'Period',Speed,'ExecutionMode','fixedRate','BusyMode','drop',...
	'StartFcn',@(~,~)StartGame,'TimerFcn',@(~,~)MainLoop,'StopFcn',@(~,~)TCleaner);

	start(MyTimer)
	
%%Create the game screen and initialise it to begin
	function StartGame ()
		MyAxes = axes('NextPlot','add','Xlim',[-10 10],'Ylim',[-10 10],'Xtick',([]),'Ytick',([]),...
			'Xcolor','y','Ycolor','y','Color',[0.2 0.2 0.2],'Box','on','LineWidth',3,'Layer','top');
		axis(MyAxes,'manual','square')
		TitleScreen.Visible = 'off';
		
		CreateFood
		SnakePic = plot (Snake(:,1),Snake(:,2),'b-s','LineWidth',4,'MarkerEdgeColor','none','MarkerFaceColor','g');
		FoodPic = plot (Food(1),Food(2),'h','MarkerSize',12,'MarkerEdgeColor','w','MarkerFaceColor',[0.8500 0.3250 0.0980]);
	end

%%The main game loop
	function MainLoop ()
		if Close
			stop(MyTimer)
		else
			if ~Pause
				AdvanceState
				CalcSnake
				DrawFrame
				KeyDown = 0;
			end
		end
	end

%%Simply move the snake in the direction of travel
    function AdvanceState ()
		if Death				%Check if snake is dead
			KillSnake
		end
        switch Dir				%Change position based on current direction
		case {1}
			PlayerPos(2) = PlayerPos(2)+Res;
		case {2}
			PlayerPos(1) = PlayerPos(1)+Res;
		case {3}
			PlayerPos(2) = PlayerPos(2)-Res;
		case {4}
			PlayerPos(1) = PlayerPos(1)-Res;			
        end
	end

%%Control keyboard input
    function KeyAct (~,Press)
		if ~KeyDown
			switch Press.Key
				case {'leftarrow','a'}
					if Dir ~=2
						Dir = 4;
					end
				case {'rightarrow','d'}
					if Dir ~=4
						Dir = 2;
					end
				case {'downarrow','s'}
					if Dir ~=1
						Dir = 3;
					end
				case {'uparrow','w'}
					if Dir ~=3
						Dir = 1;
					end
				case {'c'}
					Close=1;
				case {'p'}
					if ~Pause
						Pause = 1;
					else
						Pause = 0;
					end
			end
			KeyDown = 1;
		end
    end

%%Put some colour on the screen
    function DrawFrame ()
        set(SnakePic,'XData',Snake(:,1),'YData',Snake(:,2));
        set(FoodPic,'XData',Food(1),'YData',Food(2));
		drawnow
	end

%%Kill the snake
	function KillSnake ()
			DrawFrame
			title('You''ve killed him Paul...','Units','normalized','Position',[0.5, 0.5, 0],...
				'FontSize',34,'Color','r')
			waitforbuttonpress;
			Close = 1;
	end

%Make some noms
    function CreateFood ()
       Food = randi([(-10+Res)/Res (10-Res)/Res],1,2)*Res; 
	end

%%Update the position of each snake 'block' and check for collisions
    function CalcSnake ()
		if abs(PlayerPos-Food)<0.1			%Food collision detection
			CreateFood
			TailPos = Snake(SLength,:);
			%%Make the snake longer
			SLength = SLength +1;
			NewSnake = zeros(SLength,2);
			NewSnake(1:SLength-1,:) = Snake(1:SLength-1,:);
			NewSnake(SLength,:) = TailPos;
			Snake = NewSnake;
		end		
        Snake(2:SLength,:)=Snake(1:(SLength-1),:);
        Snake(1,:)=PlayerPos;
		if abs(PlayerPos(1))>9.5 || abs(PlayerPos(2))>9.5	%Kills snake on collision with wall
			Death = 1;
		end
		if sum(Snake(2:SLength,1) == Snake(1,1) & Snake(2:SLength,2) == Snake(1,2)) > 0			
			Death = 1;										%Kills snake on collision with self
		end	
	end

%%Attempt to clean up the timer!
	function TCleaner()
		delete(MyTimer)
		T = timerfindall;
		if ~isempty(T)
			stop(T)
			delete(T)
		end
		close all
		if Death
			Snake_Test_Optimise
		end
	end
end