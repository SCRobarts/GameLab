classdef FoodEntity < GameEntity
	%SNAKE Summary of this class goes here
	%   Detailed explanation goes here
	%
	%	Sebastian C. Robarts 2024 - sebrobarts@gmail.com
	
	properties
		Name = "Food";
	end
	properties(Transient)

	end
	
	methods
		function obj = FoodEntity(varargin)
			%SNAKE Construct an instance of this class
			%   Detailed explanation goes here
			if ~isempty(varargin)
				optArgs = varargin;
			else
				optArgs{1} = []; 
			end
			% Superclass constructor call, which can't be conditional
			obj@GameEntity(optArgs{:});
			obj.PlotOptions = {'o','MarkerSize',12,'MarkerEdgeColor','w','MarkerFaceColor',[0.8500 0.3250 0.0980]};
		end

		function gobj = initialise(obj,varargin)
			%INITIALISE Allow extension of superclass initialise method
			%   Detailed explanation goes here
			gobj = initialise@GameEntity(obj,varargin{:});
			obj.randomisePosition;
		end

		function randomisePosition(obj)
			% res = obj.Resolution;
			% xlims = obj.Parent.GridLimits(1:2);
			% ylims = obj.Parent.GridLimits(3:4);
			% obj.Position(1) = randi([(xlims(1)+res) (xlims(2)-res)]./res).*res; 
			% obj.Position(2) = randi([(ylims(1)+res) (ylims(2)-res)]./res).*res; 
			obj.Position = 2.*rand(1,2)-1;
			obj.calcXY;
			obj.redrawEntity;
		end

	end
end

