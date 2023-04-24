import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "Corelibs/timer"
import "paddle"
import "ball"
import "net"
import "score"
import "phosphortrail"
import "bloom"

local gfx = playdate.graphics

KGameOverState=0
KPlayState=1

KMaxScore=11
KResetDelay=1000 --milliseconds

KLeftPaddleX=48
KRightPaddleX=352

ImUsingTiltControls = false

function Setup()
    playdate.display.setRefreshRate(50) -- this method is capped at 50, but unrestricted can be faster

    gfx.setColor(gfx.kColorBlack)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)

    ball = Ball()
    net = Net()
    ballTrail = PhosphorTrail()
    ballTrail:addParent(ball)
    ballTrail:setLength(6)
    ballBloom = Bloom()
    ballBloom:addParent(ball)
    ballBloom:removeSprite()
    leftPaddle = Paddle()
    leftPaddleTrail = PhosphorTrail()
    leftPaddleTrail:addParent(leftPaddle)
    leftPaddleTrail:setLength(3)
    rightPaddle = Paddle()
    rightPaddleTrail = PhosphorTrail()
    rightPaddleTrail:addParent(rightPaddle)
    rightPaddleTrail:setLength(3)
    leftPaddle:moveTo(KLeftPaddleX, 120) --leftPaddle.centerY
    rightPaddle:moveTo(KRightPaddleX, 120) --rightPaddle.centerY
    GameOver()
    LeftScore = Score()
    RightScore = Score()
    LeftScore:moveTo(100,16)
    RightScore:moveTo(300,16)
    PopulateSystemMenu()
end

function PopulateSystemMenu()
    playdate.setMenuImage(gfx.image.new("instructioncard.png"))
    local menu = playdate.getSystemMenu()
    menu:addOptionsMenuItem("trails", {"0", "S", "M", "L"}, "M", SetBallTrailLength)
    menu:addCheckmarkMenuItem("ballglow", false, SetBallBloom)
end

function SetBallBloom(enabled)
    if enabled then
        ballBloom:addSprite()
    else
        ballBloom:removeSprite()
    end
end

function SetBallTrailLength(lengthName)
    if lengthName == "0" then
        ballTrail:setLength(1)
    elseif lengthName == "S" then
        ballTrail:setLength(4)
    elseif lengthName == "M" then
        ballTrail:setLength(6)
    elseif lengthName == "L" then
        ballTrail:setLength(13)
    end
end

function ResetGame()
    LeftScore:setScore(0)
    RightScore:setScore(0)
    GameState = KPlayState
    leftPaddle:setVisible(true)
    rightPaddle:setVisible(true)
    leftPaddle:addSprite()
    rightPaddle:addSprite()
    ResetPoint()
end

function ScoreRight()
    RightScore:setScore(RightScore.score + 1)
    if (RightScore.score >= KMaxScore) then
        GameOver()
    else
        ResetPoint()
    end
end

function ScoreLeft()
    LeftScore:setScore(LeftScore.score + 1)
    if (LeftScore.score >= KMaxScore) then
        GameOver()
    else
        ResetPoint()
    end
end

function ResetPoint()
    ball:reset()
    ball:removeSprite()
    ball:setVisible(false)
    local delay = playdate.timer.performAfterDelay(KResetDelay, function() ball:addSprite() ball:setVisible(true) end)
end

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

        local newControl = rY * 1.67
        --local newControl = aY * 2
        leftPaddle.yControl = (leftPaddle.yControl + newControl) / 2 --avg for dejitter

    else
        if (playdate.buttonIsPressed(playdate.kButtonUp)) then
            if playdate.buttonIsPressed(playdate.kButtonLeft) then
                leftPaddle.yControl -= 0.04
            else
                leftPaddle.yControl -= 0.1
            end
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            if playdate.buttonIsPressed(playdate.kButtonLeft) then
                leftPaddle.yControl += 0.04
            else
                leftPaddle.yControl += 0.1
            end
        end
    end
end

function GameOver()
    GameState = KGameOverState
    playdate.stopAccelerometer()
    leftPaddle:setVisible(false)
    rightPaddle:setVisible(false)
    leftPaddle:removeSprite()
    rightPaddle:removeSprite()
end


function GetRightInput()
    local crankDeg = playdate.getCrankPosition()
    rightPaddle.yControl = -1 * math.cos(math.rad(crankDeg))
end

function playdate.update()
    if InManual then
        RenderManual()
    else
        --input and animation
        if (GameState == KPlayState) then
            GetLeftInput()
            GetRightInput()
        end
        playdate.graphics.sprite.update()
        playdate.timer.updateTimers()

        --game over options
        if GameState == KGameOverState then
            if playdate.buttonJustPressed(playdate.kButtonA) then
                ImUsingTiltControls = false
                ResetGame()
            end
            if playdate.buttonJustPressed(playdate.kButtonB) then
                ImUsingTiltControls = true
                playdate.startAccelerometer()
                ResetGame()
            end    
        end

        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRect(0,0,15,12)
        -- playdate.drawFPS()
    end

end

Setup()