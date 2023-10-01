import "settings"

function GetLeftInput()
    if ImUsingTiltControls then
        local aX, aY, aZ = playdate.readAccelerometer()
        aY = math.min(1, aY)
        aY = math.max(-1, aY)
        aZ = math.min(1, aZ)
        aZ = math.max(-1, aZ)
        local rY = math.asin(aY)
        local rotSign = rY > 0 and 1 or -1
        local rZ = math.acos(aZ) * rotSign
        local rot = (rY + rZ) / 2
        -- print(rY, "|", rZ, " : ", rot)

        local newControl = rY * 1.67 * TiltSensitivity
        --local newControl = aY * 2
        leftPaddle.yControl = (leftPaddle.yControl + newControl) / 2 --avg for dejitter

    else
        if (playdate.buttonIsPressed(playdate.kButtonUp)) then
            if playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight) then
                leftPaddle.yControl -= 0.04
            else
                leftPaddle.yControl -= 0.1
            end
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            if playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight) then
                leftPaddle.yControl += 0.04
            else
                leftPaddle.yControl += 0.1
            end
        end
    end
end

function GetRightInput()
    local crankDeg = playdate.getCrankPosition()
    rightPaddle.yControl = -1 * math.cos(math.rad(crankDeg)) * CrankSensitivity
end
