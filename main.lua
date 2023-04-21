import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "Corelibs/timer"
import "paddle"
import "ball"
import "net"
import "score"

local gfx = playdate.graphics
playdate.display.setRefreshRate(60)

KGameOverState=0
KPlayState=1

KMaxScore=11
KResetDelay=1000 --milliseconds

KLeftPaddleX=48
KRightPaddleX=352

ImUsingTiltControls = false

function Setup()
    GameState = KGameOverState
    gfx.setColor(gfx.kColorBlack)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)

    ball = Ball()
    net = Net()

    leftPaddle = Paddle()
    rightPaddle = Paddle()
    leftPaddle:moveTo(KLeftPaddleX, 120) --leftPaddle.centerY
    rightPaddle:moveTo(KRightPaddleX, 120) --rightPaddle.centerY

    LeftScore = Score()
    RightScore = Score()
    LeftScore:moveTo(100,16)
    RightScore:moveTo(300,16)
end

function ResetGame()
    LeftScore:setScore(0)
    RightScore:setScore(0)
    GameState = KPlayState
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
    ball:removeSprite()
    ball:reset()
    local delay = playdate.timer.performAfterDelay(KResetDelay, function() ball:addSprite() end)
end

function GetLeftInput()
    if ImUsingTiltControls then
        local aX, aY, aZ = playdate.readAccelerometer()
        leftPaddle.yControl = aY * 2
        if leftPaddle.yControl < -1 then
            leftPaddle.yControl = -1
        elseif leftPaddle.yControl > 1 then
            leftPaddle.yControl = 1
        end
    else
        if (playdate.buttonIsPressed(playdate.kButtonUp)) then
            leftPaddle.yControl -= 0.1
            if leftPaddle.yControl < -1 then
                leftPaddle.yControl = -1
            end
        elseif playdate.buttonIsPressed(playdate.kButtonDown) then
            leftPaddle.yControl += 0.1
            if leftPaddle.yControl > 1 then
                leftPaddle.yControl = 1
            end
        end
    end
end

function GameOver()
    GameState = KGameOverState
    playdate.stopAccelerometer()
    leftPaddle:removeSprite()
    rightPaddle:removeSprite()
end


function GetRightInput()
    local crankDeg = playdate.getCrankPosition()
    if (crankDeg > 180) then
        crankDeg = 360 - crankDeg -- mirror front and back
    end
    local offset = crankDeg / 90
    offset -= 1 --range from -1 to 1, up to down
    rightPaddle.yControl = offset

    --consider doing sin(crankDeg) instead?
end

function playdate.update()
    if (GameState == KPlayState) then
        GetLeftInput()
        GetRightInput()
    end

    playdate.graphics.sprite.update()
    if (playdate.buttonIsPressed(playdate.kButtonA) and GameState == KGameOverState) then
        ImUsingTiltControls = false
        ResetGame()
    end
    if (playdate.buttonIsPressed(playdate.kButtonB) and GameState == KGameOverState) then
        ImUsingTiltControls = true
        playdate.startAccelerometer()
        ResetGame()
    end
    playdate.timer.updateTimers()
end

Setup()