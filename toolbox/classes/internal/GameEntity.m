%Allows variable level copying, arrays of different subclasses, and dynamic
% property assignment.
classdef GameEntity < matlab.mixin.Copyable & matlab.mixin.Heterogeneous & dynamicprops
	%GAMEENTITY A game entity base definition
	%   Detailed explanation goes here
	%
	%	Sebastian C. Robarts 2024 - sebrobarts@gmail.com
	properties(Abstract)
		Name
	end
	properties(AbortSet)
		Position = [0,0];
	end
	properties
		PlotOptions = {};
	end
	properties(Transient)
		Resolution = 1;
		XY
		Visible = 0;
		ActionQueued = 0;
	end
	properties(Transient,WeakHandle)
		Parent RealTimeApp
		Graphic	matlab.graphics.Graphics
	end

	methods
		function obj = GameEntity(varargin)
			%GAMEENTITY Construct an instance of this class
			%   Currently designed to be called without arguments for
			%   generality and ease of implementation, changes to default
			%   properties can be made after creation.
		end
		
		function gobj = initialise(obj,parent)
			arguments
				obj
				parent = obj.Parent;
			end
			obj.Graphic = []; % Ensure no reference to deleted graphics object
			obj.Parent = parent;
			gobj = obj.drawEntity;
			obj.Graphic = gobj;
		end

		%% Display
		function gobj = drawEntity(obj,varargin)
			%DRAWENTITY Create a graphics object for the entity
			obj.Visible = 1;
			gobj = plot(obj.XY(:,1),obj.XY(:,2),obj.PlotOptions{:},varargin{:});
		end

		function redrawEntity(obj)
			%REDRAWENTITY Update the graphics properties
			%   Responsibilty for calling this will usually lie with the
			%   container app.
			if ~isempty(obj.Graphic)
				if obj.Visible
					set(obj.Graphic,'XData',obj.XY(:,1),'YData',obj.XY(:,2),'Visible',1);
				elseif obj.Graphic.Visible == 1
					obj.Graphic.Visible = 0;
				end
			end
		end

		% function update(obj)
		% 	obj.updatePosition
		% 	obj.calcXY;
		% end

		%% App Dependent Rendering
		function snaptogrid(obj)
			%% Needs rethinking 
			%  realistically, this kind of rendering method should belong 
			%  to the container rather than the entity.
			res = obj.Resolution;
			scale = obj.Parent.GridScale;
			xlims = obj.Parent.GridLimits(1:2) - res.*[-1,1];
			ylims = obj.Parent.GridLimits(3:4) - res.*[-1,1];
			rawXY = obj.Position;
			scaledXY = rawXY .* scale;
			xy = round(scaledXY ./ res) .* res;
			%%% Bounded Manifold
			obj.boundXY(xy,xlims,ylims);
			% xy(:,1) = min(max(xy(:,1),xlims(1)),xlims(2),"includemissing");
			% xy(:,2) = min(max(xy(:,2),ylims(1)),ylims(2),"includemissing");
			%%% Toroidal Manifold
			% xy(:,1) = mod(xy(:,1)+scale(1),2*scale(1)) - scale(1);
			% xy(:,2) = mod(xy(:,2)+scale(2),2*scale(2)) - scale(2);
			% obj.XY = xy;
		end

		function boundXY(obj,xy,xlims,ylims)
			incN = "includemissing";
			x = xy(:,1); y = xy(:,2);
			x = min(max(x,xlims(1),incN),xlims(2),incN);
			y = min(max(y,ylims(1),incN),ylims(2),incN);
			obj.XY = [x,y];
		end

		function updatePosition(obj)
			%UPDATEPOSITION Placeholder function to be implemented in subclasses.
			obj.Position = obj.Position;
		end

		function calcXY(obj)
			%CALCXY Placeholder function to be implemented in subclasses.
			%	Calculate entity points for plotting based on position and
			%	graphical resolution (called automatically when resolution
			%	or position of the entity is updated).
			obj.XY = obj.Position;
			obj.snaptogrid;
		end

		%% Set. Methods
		function set.Parent(obj,app)
			obj.Parent = app;
			obj.Resolution = obj.Parent.GridStep;
		end

		function set.Resolution(obj,res)
			% Should have universal application in updating position to
			% reflect valid grid points
			obj.Resolution = res;
			obj.calcXY;
		end

		function set.Position(obj,pos)
			% Round all positions to 4 d.p. to prevent f.p. errors
			obj.Position = round(pos,4);
		% 	obj.calcXY;
		end

		% function set.XY(obj,xy)
		% 	obj.XY = xy;
		% 	% obj.redrawEntity;
		% end

	end
end

