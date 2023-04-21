import "CoreLibs/sprites.lua"
import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('Score').extends(playdate.graphics.sprite)

function Score:init()
    Score.super.init(self)
    self.scoreFont = gfx.font.new('pong.pft')
    self:setCenter(0.5,0)
    self:setSize(57,32)
    self:setScore(0)
    self:addSprite()
end

function Score:setScore(newNumber)
    self.score = newNumber
    gfx.setFont(self.scoreFont)
    self:markDirty()
end

function Score:draw(x, y, width, height)
    gfx.setColor(gfx.kColorWhite)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.setFont(self.scoreFont)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local scoreText = self.score
    if scoreText < 10 then scoreText = " "..scoreText end
    gfx.drawText(scoreText, 0,0)
    gfx.setBackgroundColor(gfx.kColorBlack)

end
