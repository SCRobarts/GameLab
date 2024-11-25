%Control Something

function Basic_Drawing
clc;
clearvars;

MyFig = figure ('color',[0.1 0.1 0.1],'KeyPressFcn',@TestFunction);		%Keyboard callback
MyAxes = axes(MyFig,'Xlim',[-10 10],'Ylim',[-10 10],'Box','on','ColorOrder', hsv);
hold on
axis(MyAxes,'off','square')

PlayerPos = [0 , 0];

DrawPlayer

function DrawPlayer ()
	plot (PlayerPos(1),PlayerPos(2), 's')
end

function TestFunction (~,Press)
	switch Press.Key
		case {'leftarrow'}
			PlayerPos(1) = PlayerPos(1)-1;
		case {'rightarrow'}
			PlayerPos(1) = PlayerPos(1)+1;
		case {'downarrow'}
			PlayerPos(2) = PlayerPos(2)-1;
		case {'uparrow'}
			PlayerPos(2) = PlayerPos(2)+1;
	end
DrawPlayer
end

end