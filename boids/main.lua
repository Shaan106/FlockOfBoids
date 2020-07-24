local _W = display.contentWidth
local _H = display.contentHeight
local rnd = math.random
display.setStatusBar( display.HiddenStatusBar )

require("util")
local math2d = require("plugin.math2d")

mouseX = 0
mouseY = 0

local buttonData = {
	{name = "green", col = {0,1,0, 0.5}},
	{name = "red", col = {1,0,0, 0.5}},
	{name = "blue", col = {0,0,1, 0.5}},
	{name = "cyan", col = {0,1,1, 0.5}},
	{name = "yellow", col = {1,1,0, 0.5}},
}

local currentButton = 1

local groupGame = display.newGroup()
local groupUI = display.newGroup()

--local numButtons = 5
local buttonH = _H/#buttonData
local buttons = {}

function buttonTouch( event )
	table.print(event)

	buttons[currentButton].strokeWidth = 0
	
	event.target:setStrokeColor(1,1,1)
	event.target.strokeWidth = 5

	currentButton = event.target.id

	return true

end

for i = 1, #buttonData do 
	buttons[i] = display.newRect(groupUI, buttonH/2, i*buttonH - buttonH/2, buttonH, buttonH)
	buttons[i]:setFillColor(unpack(buttonData[i].col))
	--buttons[i].name = buttonData[i].name
	buttons[i].id = i
	buttons[i]:addEventListener("touch", buttonTouch)
	if i == currentButton then
		buttons[i]:setStrokeColor(1,1,1)
		buttons[i].strokeWidth = 5
	end
end

local physics = require("physics")
physics.start()
physics.setScale(_W/37)
physics.setDrawMode("hybrid")
physics.setGravity(0,0)

obstructions = {}

function keyListener( event )
	print(event.keyName, event.phase, event.descriptor, event.device, event.name, event.nativeKeyCode)
	
--[[
	if event.phase == "up" and event.keyName == "o" then
		numObs = #obstructions + 1
		for i = 1, numObs do
			obstructions[i] =  display.newCircle(groupGame, mouseX, mouseY, 10)
			physics.addBody(obstructions[i], "static", {density = 1, friction = 0 , bounce = 0.5})
		end
	end
--]]
end

Runtime:addEventListener("key", keyListener)

function makeObstacle(x, y)
	
	numObs = #obstructions + 1
	obstructions[numObs] =  display.newCircle(groupGame, x, y, 25)
	physics.addBody(obstructions[numObs], "static", {density = 1, friction = 0 , bounce = 0.5, radius = 25})		
	obstructions[numObs].id = currentButton
end

local boids = {}
local force = 10

function touchScreen( event )



	if 	currentButton == 5 and event.phase == "ended" then
		makeObstacle( event.x, event.y )
	end
	if 	event.phase == "ended" and
		currentButton ~= 5 then
		local triSizeBase = _W/75
		local triSizeHeight = _W/25
		--local triangleVert = {0,0,triSizeBase,triSizeHeight,-triSizeBase,triSizeHeight}
		local triangleVert = {0,-0.75*triSizeHeight,triSizeBase,0.25*triSizeHeight,-triSizeBase,0.25*triSizeHeight}
		local i = #boids + 1
		boids[i] = display.newPolygon(groupGame, event.x, event.y, triangleVert)
		physics.addBody(boids[i], "dynamic", {shape = triangleVert, density = 1, friction = 0 , bounce = 0.5, filter = {categoryBits = 2 ^ (currentButton - 1), maskBits = 2 ^ (currentButton - 1)}})
		boids[i].linearDamping = 1.5
		boids[i].angularDamping = 5
		boids[i].anchorY = 0.75
		boids[i].rotation = 270--rnd(0,359)
		boids[i].id = currentButton
		local paint = {
			type = "gradient",
			color1 = {buttonData[currentButton].col[1], buttonData[currentButton].col[2], buttonData[currentButton].col[3]},
			color2 = {buttonData[currentButton].col[1]/4, buttonData[currentButton].col[2]/4, buttonData[currentButton].col[3]/4},
			direction = "down"
		}
		boids[i].fill = paint
	end
end
Runtime:addEventListener("touch", touchScreen)

local boidNear = 0.15 * _W
local boidTooNear = 0.05 * _W

function isClose( boidA, boidB )
	local distance = 	((boidA.y - boidB.y)^2 + (boidA.x - boidB.x)^2)^0.5
	if distance <= boidNear then 
		return true
	else
		return false
	end
end

local distance = 0

function isTooClose( boidA, boidB )
	distance = 	((boidA.y - boidB.y)^2 + (boidA.x - boidB.x)^2)^0.5
	if distance <= boidTooNear then 
		return true
	else
		return false
	end
end
local angleDiff = 4
function updateGame( event )

	local toX 
	local toY
	local distanceCheck = 300

	for i = 1, #boids do 

		--toX = math.sin(boids[i].rotation*math.pi/180)*force
		--toY = -math.cos(boids[i].rotation*math.pi/180)*force
		toX, toY = math2d.angle2Vector(boids[i].rotation)
		toXL, toYL = math2d.angle2Vector(boids[i].rotation-angleDiff)
		toXR, toYR = math2d.angle2Vector(boids[i].rotation+angleDiff)
		--boids[i]
		local hits = physics.rayCast( 	boids[i].x, boids[i].y, 
										boids[i].x + (toX*distanceCheck),
										boids[i].y + (toY*distanceCheck),
										"sorted" )
		local hitsL = physics.rayCast( 	boids[i].x, boids[i].y, 
										boids[i].x + (toXL*distanceCheck),
										boids[i].y + (toYL*distanceCheck),
										"sorted" )
		local hitsR = physics.rayCast( 	boids[i].x, boids[i].y, 
										boids[i].x + (toXR*distanceCheck),
										boids[i].y + (toYR*distanceCheck),
										"sorted" )


		if 	(hits and hits[1].object.id == 5) or
			(hitsL and hitsL[1].object.id == 5) or
			(hitsR and hitsR[1].object.id == 5) then

			boids[i].linearDamping = 15
			boids[i]:setStrokeColor(1)
			--boids[i]:setStrokeColor(unpack(buttonData[hits[1].object.id].col))
			boids[i].strokeWidth = 10

			--print(hits[1].object.id)
		else
			boids[i].linearDamping = 1.5 
			boids[i]:applyForce(toX * force, toY * force,
								boids[i].x, boids[i].y )
			boids[i].strokeWidth = 0
		end
---[[
		if hits or hitsL or hitsR then
			
			local currentAngle = angleDiff
			local rayX, rayY
			while currentAngle < 180 do


				-- anti-clockwise
				rayX, rayY = math2d.angle2Vector(boids[i].rotation - currentAngle)
				local hitsAW = 	physics.rayCast(boids[i].x, boids[i].y, 
									boids[i].x + (rayX*distanceCheck), 
									boids[i].y + (rayY*distanceCheck),
									"sorted" )
				if hitsAW == nil then
					--print(currentAngle, "AWAWAWAW")
					--boids[i].rotation = boids[i].rotation - currentAngle
					boids[i]:applyTorque(-6)
					break
				end
				-- clockwise first
				rayX, rayY = math2d.angle2Vector(boids[i].rotation + currentAngle)
				local hitsCW = 	physics.rayCast(boids[i].x, boids[i].y, 
									boids[i].x + (rayX*distanceCheck), 
									boids[i].y + (rayY*distanceCheck),
									"sorted" )
				if hitsCW == nil then
					--print(currentAngle, "CWCWCWCW")
					--boids[i].rotation = boids[i].rotation + currentAngle
					boids[i]:applyTorque(6)
					break
				end


				currentAngle = currentAngle + angleDiff
			end
			--print("-=-=-=-=-=-=-=-=-=-=-=-=-")
		end
--]]
		if boids[i].x >= _W + 1 then
			boids[i].x = 0
		elseif boids[i].x <= -1 then
			boids[i].x = _W
		end
		if boids[i].y >= _H + 1 then
			boids[i].y = 0
		elseif boids[i].y <= -1 then
			boids[i].y = _H
		end

		local numClose = 0
		local totRot = 0

		for j = 1, #boids do
			if i ~= j then
				if 	isClose(boids[i], boids[j]) == true and 
					boids[i].id == boids[j].id then
					numClose = numClose + 1
					totRot = totRot + boids[j].rotation 
				end

				--[[
				if isTooClose(boids[i], boids[j]) == true then
					boids[i].x = boids[i].x + distance 
					boids[i].y = boids[i].y + distance 
				end
				--]]
			end
		end
		if numClose > 0 then
			local avgRot = totRot/numClose
			local deltaRot = avgRot - boids[i].rotation
			if math.abs(deltaRot) >= 1 then
				if 	(deltaRot >= 0 and deltaRot <= 180) or
					(deltaRot >= -360 and deltaRot <= -180) then
					boids[i]:applyTorque(2.5)
				else
					boids[i]:applyTorque(-2.5)
				end
			end
		end
	end

end
Runtime:addEventListener("enterFrame", updateGame)