-- import 'CoreLibs/sprites.lua'
-- import 'CoreLibs/graphics.lua'

-- local gfx = playdate.graphics

-- class('Paddle').extends(playdate.graphics.sprite)

-- function Paddle:init()
--     Paddle.super.init(self)

    -- self.kWidth=4
    -- self.kHeight=16
    -- self.minY=16 --half bat open at top
    -- self.maxY=228 --quarter bat open at bottom
    -- self.halfRange = (self.maxY - self.minY)/2
    -- self.centerY = self.minY + self.halfRange
    -- self.yControl = 0 -- from -1 to 1, top to bottom of range

--     self:setSize(self.kWidth, self.kHeight)
--     self:setCenter(0.5,0.5)
--     self:setCollideRect(0,0,self:getSize())
--     self:addSprite()
--     print("Paddle:init() done")
-- end

-- function Paddle.draw(x, y, width, height)
--     gfx.setColor(gfx.kColorWhite)
--     gfx.fillRect(0,0,self.kWidth, self.kHeight)
-- end

-- function Paddle.yControl(height) -- from -1 to 1
-- end

-- function Paddle.update()
--     self:moveTo(self.x, self.yControl * self.halfRange + self.centerY)
-- end

import "CoreLibs/sprites.lua"
import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('Paddle').extends(playdate.graphics.sprite)

function Paddle:init()
    Paddle.super.init(self)

    self.kWidth=4
    -- self.kHeight=16
    self.kHeight=160
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
    self:moveTo(self.x, self.yControl * self.halfRange + self.centerY)
end