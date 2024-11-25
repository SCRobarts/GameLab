classdef MobileEntity < GameEntity
	%MOBILEENTITY A concrete implementation of GameEntity for mobile entities
	%   Detailed explanation goes here
	
	properties
		Name = "Mobile Entity";
		Speed = 0;	% Speed in relative units per second/input
		Direction	= [0,1]; % Normalised direction vector
		AutoMove = 0;
		WillStep = 0;
		Bounded = 1;
	end
	
	methods
		function obj = MobileEntity(varargin)
			%LOCALENTITY Construct an instance of this entity
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
		end

		function updatePosition(obj)
			%UPDATEPOSITION Placeholder function to be implemented in subclasses.
			if obj.WillStep
				obj.takeStep;
			elseif obj.AutoMove
				deltaTime = 1./obj.Parent.InstantFPS;
				deltaPos = (obj.Speed.*deltaTime) .* obj.Direction;
				obj.Position = obj.Position + deltaPos;
			end
			obj.edgeCheck;
			obj.calcXY;
		end
		
		function takeStep(obj)
			deltaPos = obj.Speed .* obj.Direction;
			obj.Position = obj.Position + deltaPos;
			obj.WillStep = 0;
		end

		function edgeCheck(obj)
			if obj.Bounded
				obj.boundPosition;
			end
		end
	end
end

