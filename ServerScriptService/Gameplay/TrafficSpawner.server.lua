local RunService = game:GetService("RunService")

local trafficFolder = workspace:FindFirstChild("Traffic") or Instance.new("Folder")
trafficFolder.Name = "Traffic"
trafficFolder.Parent = workspace

local cars = {}

local function spawnCar()

    local car = Instance.new("Part")
    car.Size = Vector3.new(6,3,10)
    car.Anchored = true
    car.Color = Color3.fromRGB(200,0,0)

    car.Position = Vector3.new(20,3,-150)
    car.Parent = trafficFolder

    table.insert(cars,car)

end

RunService.Heartbeat:Connect(function(dt)

    for i=#cars,1,-1 do

        local car = cars[i]

        if not car.Parent then
            table.remove(cars,i)
        else
            car.Position += Vector3.new(0,0,60*dt)
        end

    end

end)

while true do
    task.wait(4)
    spawnCar()
end