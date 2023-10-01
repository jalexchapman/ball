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
import "starthint"


local gfx = playdate.graphics

KGameOverState=0
KPlayState=1

KMatchMode=0
KRallyMode=1

KMaxScore=11
KResetDelay=1000 --milliseconds

KLeftPaddleX=48
KRightPaddleX=352

ImUsingTiltControls = false

InCredits = false
CreditsDrawn = false

HintsEnabled = true

function Setup()
    playdate.display.setRefreshRate(50) -- this method is capped at 50, but unrestricted can be faster

    gfx.setColor(gfx.kColorBlack)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)

    GameMode=KMatchMode
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
    startHint = StartHint()
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
    if HintsEnabled then
        startHint:addSprite()
    end
end

function ResetGame()
    HintsEnabled = false -- no start hint after first game
    if GameMode == KMatchMode then
        LeftScore:setScore("0")
    else
        LeftScore:setScore("") --hide left score
    end
    RightScore:setScore(0)
    GameState = KPlayState
    leftPaddle:setVisible(true)
    rightPaddle:setVisible(true)
    leftPaddle:addSprite()
    rightPaddle:addSprite()
    startHint:removeSprite()
    ResetPoint()
end

function ResetPoint()
    ball:reset()
    ball:removeSprite()
    ball:setVisible(false)
    local delay = playdate.timer.performAfterDelay(KResetDelay, function() ball:addSprite() ball:setVisible(true) end)
end

function ScoreRight()
    if GameMode == KRallyMode then
        GameOver()
    else
        RightScore:setScore(RightScore.score + 1)
        if (RightScore.score >= KMaxScore) then
            GameOver()
        else
            ResetPoint()
        end
    end
end

function ScoreLeft()
    if GameMode == KRallyMode then
        GameOver()
    else
        LeftScore:setScore(LeftScore.score + 1)
        if (LeftScore.score >= KMaxScore) then
            GameOver()
        else
            ResetPoint()
        end
    end
end

function ScoreRally()
    if GameMode == KRallyMode then
        RightScore:setScore(RightScore.score + 1)
    end
end

function playdate.update()
    if InCredits then
        RenderCredits()
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
                GameMode = KMatchMode
                if ImUsingTiltControls then
                    playdate.startAccelerometer()
                end
                ResetGame()
            end
            if playdate.buttonJustPressed(playdate.kButtonB) then
                GameMode = KRallyMode
                if ImUsingTiltControls then
                    playdate.startAccelerometer()
                end
                ResetGame()
            end
        end

        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRect(0,0,15,12)
        -- playdate.drawFPS()
    end
end

function RenderCredits()
    if CreditsDrawn then
        if playdate.buttonJustPressed(playdate.kButtonB) then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0,0,400,240)
            InCredits = false
        end
    else
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0,0,400,240)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRoundRect(5,5,390,235,5)
        gfx.setColor(gfx.kColorBlack)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gfx.drawRoundRect(7,7,386,231,3)
        local boldFont = gfx.getSystemFont(gfx.font.kVariantBold)
        local font = gfx.getSystemFont()
        boldFont:drawTextAligned("BALL", 200, 30, kTextAlignment.center)
        boldFont:drawTextAligned("by Alex Chapman", 25, 55, kTextAlignment.left)
        boldFont:drawTextAligned("source:", 25, 75, kTextAlignment.left)
        font:drawTextAligned("https://github.com/jalexchapman/ball", 35, 95, kTextAlignment.left)
        boldFont:drawTextAligned("PONG original game design", 200, 145, kTextAlignment.center)
        boldFont:drawTextAligned("by Al Alcorn and Atari, Inc.", 25, 170, kTextAlignment.left)
        boldFont:drawTextAligned("(press B)", 200, 210, kTextAlignment.center)
        CreditsDrawn = true
    end
end

Setup()