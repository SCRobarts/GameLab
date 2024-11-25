%Control Something

clc;
clearvars;

MyFig = figure('KeyPressFcn',@TestFunction);		%Keyboard callback


function TestFunction (~,Press)
	Press.Key
end
