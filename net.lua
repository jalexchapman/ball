import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('Net').extends(playdate.graphics.sprite)

function Net:init()
    Net.super.init(self)
    self:setCenter(0,0)
    self:setSize(2,240)
    self:moveTo(199,0)
    self:addSprite()
end

function Net:draw()
    gfx.setColor(gfx.kColorWhite)
    gfx.setBackgroundColor(gfx.kColorBlack)
    for i = 2, 234, 8 do
        gfx.fillRect(0, i, 2, 4)
    end
end