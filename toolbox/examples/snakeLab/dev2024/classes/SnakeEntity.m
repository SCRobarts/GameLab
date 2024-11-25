classdef SnakeEntity < GameEntity
	%SNAKE Summary of this class goes here
	%   Detailed explanation goes here
	%
	%	Sebastian C. Robarts 2024 - sebrobarts@gmail.com
	
	properties
		Name = "Snake"
		Speed = 0.5;	% Snake speed in relative units per second
		Direction	= [0,1];
	end
	properties(Transient)	
		Length		= 3;
		Dead = 0;
	end
	properties(Dependent)
		SegmentPositions;
	end
	
	methods
		%% Creation
		function obj = SnakeEntity(varargin)
			%SNAKEENTITY Construct an instance of this entity
			%   Currently designed to be called without arguments for
			%   generality and ease of implementation, changes to default
			%   properties can be made after creation.
			if ~isempty(varargin)
				optArgs = varargin;
			else
				optArgs{1} = []; 
			end
			% Superclass constructor call, which can't be conditional
			obj@GameEntity(optArgs{:});
			obj.PlotOptions = {'b-s','LineWidth',4,'MarkerEdgeColor','none','MarkerFaceColor','g'};
		end

		function gobj = initialise(obj,varargin)
			%INITIALISE Allow extension of superclass initialise method
			%   Allows app specific properties and dependencies to be
			%   controlled at runtime.
			obj.Position = repmat(obj.Position(1,:),obj.Length,1);
			gobj = initialise@GameEntity(obj,varargin{:});
			obj.XY = obj.XY-obj.Direction.*((0:obj.Length-1).*obj.Resolution)';
			obj.Position = obj.SegmentPositions;
			obj.redrawEntity;
		end
		
		% function calcXY(obj)
		% %CALCXY override superclass function
		% %	Calculate entity points for plotting based on position and
		% %	graphical resolution (called automatically when resolution
		% %	or position of the entity is updated).
		%
		% end

		%% Functionality
		function updatePosition(obj)
			oldPos = obj.Position;
			oldHeadPos = obj.Position(1,:);
			headSegPos = obj.SegmentPositions(1,:);
			deltaTime = 1./obj.Parent.InstantFPS;
			change = (obj.Speed.*deltaTime) .* obj.Direction; 
			% change = (obj.Speed/obj.Parent.TargetFPS) .* obj.Direction; %For debugging
			% disp(deltaTime)
			newHeadPos = oldHeadPos + change;
			if any(abs(newHeadPos)>1)
				obj.tunnel(newHeadPos);
				oldPos = [NaN,NaN; oldPos];
			else
				obj.Position(1,:) = newHeadPos;
			end
			obj.calcXY;
			if ~all(headSegPos(1,:) == obj.SegmentPositions(1,:))
				obj.advanceState(oldPos);
			end
		end

		function advanceState(obj,oldPos)
			obj.ActionQueued = 0;
			if all(isnan(oldPos(end,:)))
				oldPos = oldPos(1:end-1,:);
				obj.Position = obj.Position(1:end-1,:);
			end
			obj.Position(2:end,:) = oldPos(1:end-1,:);
			obj.calcXY;
		end

		function tunnel(obj,headPos)
			obj.Position(1,:) = mod(headPos+1,2)-1;
			if ~all(obj.Position(1,:) == headPos)
				obj.insertSegment(2,[NaN,NaN]);
			end
		end

		function grow(obj,n)
			arguments
				obj
				n = 1;
			end
			obj.Length = obj.Length + n;
			newSeg = repmat(obj.Position(end,:),n,1);
			obj.Position = [obj.Position; newSeg];
		end

		function insertSegment(obj,id,xy)
			fSeg = obj.Position(1:id-1,:);
			bSeg = obj.Position(id:end,:);
			obj.Position = [fSeg; xy; bSeg];
			if all(~isnan(xy))
				obj.Length = obj.Length + 1;
			end
		end

		function kill(obj)
			obj.Dead = 1;
		end

		%% Set. Methods
		% function set.Length(obj,len)
		% 	dl = len - obj.Length;
		% 	obj.Length = len;
		% 	obj.Position = [obj.Position; repmat(obj.Position(end,:),dl,1)]; 
		% end

		function set.Direction(obj,xy)
			if all(obj.Direction + xy) && norm(xy) == 1
				obj.Direction = xy;
			end
		end

		%% Get. Methods
		function segpos = get.SegmentPositions(obj)
			segpos = obj.XY./obj.Parent.GridScale;
		end
	end
end

