import "CoreLibs/sprites.lua"
import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('Paddle').extends(playdate.graphics.sprite)

function Paddle:init()
    Paddle.super.init(self)

    self.kWidth=4
    -- self.kHeight=16
    self.kHeight=20
    self.minY=self.kHeight/2 + 8 --8 open at top
    self.maxY = (240 - self.kHeight/2) - 4 -- 4 open at bottom 

    self.halfRange = (self.maxY - self.minY)/2
    self.centerY = self.minY + self.halfRange
    self.yControl = 0 -- from -1 to 1, top to bottom of range

    self:setCenter(0.5,0.5)
    self:setSize(self.kWidth, self.kHeight)
    self:setCollideRect(0,0,self:getSize())

end


function Paddle:draw(x, y, width, height)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0,0,self.kWidth, self.kHeight)
end

function Paddle:update()
    self.yControl = math.min(self.yControl, 1)
    self.yControl = math.max(self.yControl, -1)
    self:moveTo(self.x, self.yControl * self.halfRange + self.centerY)
end