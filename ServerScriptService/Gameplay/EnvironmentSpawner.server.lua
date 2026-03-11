local Lighting = game:GetService("Lighting")

------------------------------------------------
-- NATURAL SKY LIGHTING (NO PURPLE)
------------------------------------------------

Lighting.ClockTime = 18.5  -- around 5:30 PM

Lighting.Brightness = 2

Lighting.Ambient = Color3.fromRGB(128,128,128)
Lighting.OutdoorAmbient = Color3.fromRGB(140,140,140)

Lighting.FogStart = 300
Lighting.FogEnd = 1000

Lighting.FogColor = Color3.fromRGB(200,200,200)

------------------------------------------------
-- OPTIONAL SUNSET TONE
------------------------------------------------

Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)