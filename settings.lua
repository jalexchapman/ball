local gfx = playdate.graphics

CrankSensitivity = 1.0
TiltSensitivity = 1.0


function InitializeSettings()
    MenuValues = playdate.datastore.read("MenuValues")
    if MenuValues == nil
     or MenuValues.ballTrailLength == nil
     or MenuValues.sensitivity == nil then
        MenuValues = {ballTrailLength = "M", sensitivity = "1"}
        playdate.datastore.delete("MenuValues")
    end
    PopulateSystemMenu()
end

function PopulateSystemMenu()
    playdate.setMenuImage(gfx.image.new("instructioncard.png"))
    local menu = playdate.getSystemMenu()
    
    menu:addOptionsMenuItem("trails", {"0", "S", "M", "L"}, MenuValues.ballTrailLength, SetBallTrailLength)
    SetSensitivity(MenuValues.sensitivity)
    
    menu:addOptionsMenuItem("sensitivity", {"1", "2", "3", "4"}, MenuValues.sensitivity, SetSensitivity)
    SetBallTrailLength(MenuValues.ballTrailLength)

    menu:addMenuItem("credits", function() InCredits = true CreditsDrawn = false end)
end

function SetBallTrailLength(lengthName)
    MenuValues.ballTrailLength = lengthName
    if lengthName == "0" then
        ballTrail:setLength(1)
        ballBloom:removeSprite()
    elseif lengthName == "S" then
        ballTrail:setLength(4)
        ballBloom:removeSprite()
    elseif lengthName == "M" then
        ballTrail:setLength(6)
        ballBloom:addSprite()
    elseif lengthName == "L" then
        ballTrail:setLength(13)
        ballBloom:addSprite()
    end
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
