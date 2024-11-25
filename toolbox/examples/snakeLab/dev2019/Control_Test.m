%Control Something

function Control_Test
clc;
clear all;

MyFig = figure ('color',[0.1 0.1 0.1],'KeyPressFcn',@TestFunction);		%Keyboard callback
MyAxes = axes('NextPlot','replacechildren','Xlim',[-10 10],'Ylim',[-10 10],'Box','on');
axis(MyAxes,'manual','off','square')

Dir = 1;

PlayerPos = [0,0];

DrawPlayer

while 1
	switch Dir
		case {1}
			PlayerPos(2) = PlayerPos(2)+1;
		case {2}
			PlayerPos(1) = PlayerPos(1)+1;
		case {3}
			PlayerPos(2) = PlayerPos(2)-1;
		case {4}
			PlayerPos(1) = PlayerPos(1)-1;			
	end
	pause (0.5)
	DrawPlayer
end

function DrawPlayer ()
	plot (PlayerPos(1),PlayerPos(2), 's')
end


function TestFunction (~,Press)
	DrawPlayer
	switch Press.Key
		case {'leftarrow'}
			PlayerPos(1) = PlayerPos(1)-1;
			Dir = 4;
		case {'rightarrow'}
			PlayerPos(1) = PlayerPos(1)+1;
			Dir = 2;
		case {'downarrow'}
			PlayerPos(2) = PlayerPos(2)-1;
			Dir = 3;
		case {'uparrow'}
			PlayerPos(2) = PlayerPos(2)+1;
			Dir = 1;
	end
end

end