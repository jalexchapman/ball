local gfx = playdate.graphics

CrankSensitivity = 1.0
TiltSensitivity = 1.0


function InitializeSettings()
    MenuValues = playdate.datastore.read("MenuValues")
    if MenuValues == nil
     or MenuValues.ballTrailLength == nil
     or MenuValues.sensitivity == nil
     or MenuValues.leftPaddleControl == nil then
        MenuValues = {ballTrailLength = "M", sensitivity = "1", leftPaddleControl = "tilt"}
        playdate.datastore.delete("MenuValues")
    end
    PopulateSystemMenu()
end

function PopulateSystemMenu()
    playdate.setMenuImage(gfx.image.new("instructioncard.png"))
    local menu = playdate.getSystemMenu()
    
    menu:addOptionsMenuItem("trails", {"0", "S", "M", "L", "XL", "XXL"}, MenuValues.ballTrailLength, SetBallTrailLength)
    SetBallTrailLength(MenuValues.ballTrailLength)
    
    menu:addOptionsMenuItem("sensitivity", {"1", "2", "3", "4"}, MenuValues.sensitivity, SetSensitivity)
    SetSensitivity(MenuValues.sensitivity)

    menu:addOptionsMenuItem("left paddle", {"tilt", "pad"}, MenuValues.leftPaddleControl, SetLeftPaddleControl)
    SetLeftPaddleControl(MenuValues.leftPaddleControl)

    -- menu:addMenuItem("credits", function() InCredits = true CreditsDrawn = false end)
end

function SetBallTrailLength(lengthName)
    MenuValues.ballTrailLength = lengthName
    local len = 0
    if lengthName == "0" then
        len = 1
        ballBloom:removeSprite()
    elseif lengthName == "S" then
        ballBloom:removeSprite()
    elseif lengthName == "M" then
        len = 6
        ballBloom:addSprite()
    elseif lengthName == "L" then
        len = 13
        ballBloom:addSprite()
    elseif lengthName == "XL" then
        len = 25
        ballBloom:addSprite()
    elseif lengthName == "XXL" then
        len = 50
        ballBloom:addSprite()
    end
    ballTrail:setLength(len)
    leftPaddleTrail:setLength(math.min(len, 25))
    rightPaddleTrail:setLength(math.min(len, 25))
    playdate.datastore.write(MenuValues, "MenuValues")
end

function SetSensitivity(sensitivityName)
    MenuValues.sensitivity = sensitivityName
    if sensitivityName == "1" then
        TiltSensitivity = 1.0
        CrankSensitivity = 1.1
    elseif sensitivityName == "2" then
        TiltSensitivity = 1.1
        CrankSensitivity = 1.2
    elseif sensitivityName == "3" then
        TiltSensitivity = 1.3
        CrankSensitivity = 1.3
    else
        TiltSensitivity = 1.5
        CrankSensitivity = 1.5
    end
    playdate.datastore.write(MenuValues, "MenuValues")
end

function SetLeftPaddleControl(controlStyleName)
    MenuValues.leftPaddleControl = controlStyleName
    if controlStyleName == "tilt" then
        ImUsingTiltControls = true
        if GameState ~= KGameOverState then
            playdate.startAccelerometer()
        end
    else
        ImUsingTiltControls = false
        playdate.stopAccelerometer()
    end
    playdate.datastore.write(MenuValues, "MenuValues")
end
