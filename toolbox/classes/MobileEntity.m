classdef MobileEntity < GameEntity
	%LOCALENTITY A concrete basic implementation of GameEntity
	%   Detailed explanation goes here
	
	properties
		Name = "Mobile Entity";
		Speed = 0;	% Speed in relative units per second
		Direction	= [0,1]; % Normalised direction vector
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
			deltaTime = 1./obj.Parent.InstantFPS;
			deltaPos = (obj.Speed.*deltaTime) .* obj.Direction;
			obj.Position = obj.Position + deltaPos;
			obj.calcXY;
		end
		
	end
end

