local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ESCAPE_DISTANCE = 1200

local event = Instance.new("RemoteEvent")
event.Name = "DistanceUpdate"
event.Parent = ReplicatedStorage

-- expose distance value
_G.EscapeDistance = ESCAPE_DISTANCE