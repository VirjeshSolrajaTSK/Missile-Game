local RunService = game:GetService("RunService")

local trafficFolder = Instance.new("Folder")
trafficFolder.Name = "Traffic"
trafficFolder.Parent = workspace


while true do
	
	task.wait(4)

	local car = Instance.new("Part")
	car.Size = Vector3.new(6,3,10)
	car.Anchored = true
	car.Color = Color3.fromRGB(200,0,0)

	car.Position = Vector3.new(20,3,-150)

	car.Parent = trafficFolder

	RunService.Heartbeat:Connect(function(dt)
		
		if car.Parent then
			car.Position = car.Position + Vector3.new(0,0,60*dt)
		end
		
	end)

end