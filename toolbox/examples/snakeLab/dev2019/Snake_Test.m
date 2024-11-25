%Let's get snakey - Seb Robarts - scr2 - 5/11/2019
function Snake_Test
clc;
clear all;
close all;

Res = 0.5;							%Resolution of snake motion (Changing this will change length and cause graphical issues)
%%Change Speed in order to adjust difficulty and account for differences in
%%processor clock
Speed = 0.1;						%How long to pause each frame
Dir = 1;							%Sets direction (1,2,3,4 -> N,E,S,W)
SLength = 3;						%Initialise snake length
PlayerPos = [0,0];					%Starting position
Food = [10,10];
Snake = [0 0;0 -Res;0 -2*Res];		%Initialise the snake
P = 0;								%Start with pause off
Death = 0;							%Snake is no dead
Close = 0;							%Initialise the exit var

%%Initialise the figure and define the Keyboard callback
GameFig = figure ('WindowState','maximized','MenuBar','none','color',[0.1 0.1 0.1],'KeyPressFcn',@KeyAct);

TitleScreen = axes('color',[0.1 0.1 0.1],'OuterPosition',[0.25 0.25 0.5 0.5],...
	'Xcolor','none','Ycolor','none');
title({'Welcome to Seb''s Snake!';'WASD or Arrows to change direction';'p to pause, c to exit';...
	'Press any key to continue'},'FontSize',30,'Color','w')
w = waitforbuttonpress;

MyAxes = axes('NextPlot','replacechildren','Xlim',[-10 10],'Ylim',[-10 10],'Xtick',([]),'Ytick',([]),...
    'Xcolor','y','Ycolor','y','Color',[0.2 0.2 0.2],'Box','on','LineWidth',3,'Layer','top');
axis(MyAxes,'manual','square')
TitleScreen.Visible = 'off';

CreateFood

%%The main game loop
while ~Close
	while P == 1
		DrawFrame
	end
    DrawFrame
	AdvanceState
    CalcSnake
    pause(Speed)
end

close all;

    function CreateFood ()
       Food = randi([(-10+Res)/Res (10-Res)/Res],1,2)*Res; 
	end

%%Kill the snake
	function KillSnake ()
			DrawFrame
			title('You''ve killed him Paul...','Units','normalized','Position',[0.5, 0.5, 0],...
				'FontSize',34,'Color','r')
			pause(1)
			w = waitforbuttonpress;
			Snake_Test								%Restart and return to title
			Close = 1;
	end

%%Update the position of each snake 'block' and check for collisions
    function CalcSnake ()
		if abs(PlayerPos-Food)<0.1					%Food collision detection
			CreateFood
			TailPos = Snake(SLength,:);
			%%Make the snake longer
			SLength = SLength +1;
			NewSnake = zeros(SLength,2);
			NewSnake(1:SLength-1,:) = Snake(1:SLength-1,:);
			NewSnake(SLength,:) = TailPos;
			Snake = NewSnake;
		end
		if any(Snake(2:SLength,:) == PlayerPos)		%Kills snake on collision with self
			Death = 1;
		end			
        Snake(2:SLength,:)=Snake(1:(SLength-1),:);
        Snake(1,:)=PlayerPos;
		if abs(PlayerPos(1))>9.5 || abs(PlayerPos(2))>9.5	%Kills snake on collision with wall
			Death = 1;
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

%%Put some colour on the screen
    function DrawFrame ()
        plot (Snake(:,1),Snake(:,2),'b-s','LineWidth',4,'MarkerEdgeColor','none','MarkerFaceColor','g')
        MyAxes.NextPlot = 'add';
        plot (Food(1),Food(2),'h','MarkerSize',12,'MarkerEdgeColor','w','MarkerFaceColor',[0.8500 0.3250 0.0980])
        MyAxes.NextPlot = 'replacechildren';
        drawnow
	end

%%Control keyboard input
    function KeyAct (~,Press)
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
				if P
					P = 0;
				else
					P = 1;
				end
        end
    end

end