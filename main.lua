import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "Corelibs/timer"
import "paddle"
import "ball"
import "net"
import "score"
import "phosphortrail"

local gfx = playdate.graphics
local title = "BALL"
local manualText = "Press A or B to start. Right player uses crank.\n\n"..
                "A game: Left player uses D-pad. Hold left to slow.\n"..
                "B game: Left player uses tilt. Hold level to center.\n\n"..
                "Try playing face to face!\n"
local menuExitText= "press B to continue"
KGameOverState=0
KPlayState=1

KMaxScore=11
KResetDelay=1000 --milliseconds

KLeftPaddleX=48
KRightPaddleX=352

ImUsingTiltControls = false
InManual = false
ManualDrawn = false

function Setup()
    playdate.display.setRefreshRate(50) -- this method is capped at 50, but unrestricted can be faster

    PopulateSystemMenu()

    gfx.setColor(gfx.kColorBlack)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.fillRect(0, 0, 400, 240)

    ball = Ball()
    net = Net()
    ballTrail = PhosphorTrail()
    ballTrail:addParent(ball)
    ballTrail:setZIndex(1)
    leftPaddle = Paddle()
    leftPaddleTrail = PhosphorTrail()
    leftPaddleTrail:addParent(leftPaddle)
    leftPaddleTrail:setZIndex(1)
    rightPaddle = Paddle()
    rightPaddleTrail = PhosphorTrail()
    rightPaddleTrail:addParent(rightPaddle)
    rightPaddleTrail:setZIndex(1)
    leftPaddle:moveTo(KLeftPaddleX, 120) --leftPaddle.centerY
    rightPaddle:moveTo(KRightPaddleX, 120) --rightPaddle.centerY
    GameOver()
    LeftScore = Score()
    RightScore = Score()
    LeftScore:moveTo(100,16)
    RightScore:moveTo(300,16)
end

function PopulateSystemMenu()
    local menu = playdate.getSystemMenu()
    menu:addMenuItem("manual", function () InManual = true ManualDrawn = false end)
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

function RenderManual()
    if ManualDrawn then
        if playdate.buttonJustPressed(playdate.kButtonB) then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0,0,400,240)
            InManual = false
        end
    else
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0,0,400,240)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        local font = gfx.getSystemFont(gfx.font.kVariantBold)
        font:drawTextAligned(title, 200, 10, kTextAlignment.center)
        font = gfx.getSystemFont()
        font:drawTextAligned(manualText, 0, 45, kTextAlignment.left)
        font:drawTextAligned(menuExitText, 200, 220, kTextAlignment.center)
        ManualDrawn = true
    end
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
    end

end

Setup()