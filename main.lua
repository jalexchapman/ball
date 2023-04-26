import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "Corelibs/timer"
import "paddle"
import "ball"
import "net"
import "score"
import "phosphortrail"
import "bloom"
import "settings"
import "input"

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
    ballBloom = Bloom()
    ballBloom:addParent(ball)
    leftPaddle = Paddle()
    leftPaddleTrail = PhosphorTrail()
    leftPaddleTrail:addParent(leftPaddle)
    rightPaddle = Paddle()
    rightPaddleTrail = PhosphorTrail()
    rightPaddleTrail:addParent(rightPaddle)
    leftPaddle:moveTo(KLeftPaddleX, 120) --leftPaddle.centerY
    rightPaddle:moveTo(KRightPaddleX, 120) --rightPaddle.centerY
    GameOver()
    LeftScore = Score()
    RightScore = Score()
    LeftScore:moveTo(100,16)
    RightScore:moveTo(300,16)
    InitializeSettings()
end

function GameOver()
    GameState = KGameOverState
    playdate.stopAccelerometer()
    leftPaddle:setVisible(false)
    rightPaddle:setVisible(false)
    leftPaddle:removeSprite()
    rightPaddle:removeSprite()
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

function ResetPoint()
    ball:reset()
    ball:removeSprite()
    ball:setVisible(false)
    local delay = playdate.timer.performAfterDelay(KResetDelay, function() ball:addSprite() ball:setVisible(true) end)
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

function playdate.update()
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

Setup()