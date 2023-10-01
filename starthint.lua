import "CoreLibs/sprites.lua"
import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('StartHint').extends(playdate.graphics.sprite)

function StartHint:init()
    Score.super.init(self)
    self.hintFont = gfx.font.new('rains-2x-dither.pft')
    self:setCenter(0.5,1)
    self:setSize(400, 14)
    self:moveTo(200,239)
end

local startHintText = "B: RALLY     A: MATCH"

function StartHint:draw()
    gfx.setColor(gfx.kColorWhite)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.setFont(self.hintFont)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawTextAligned(startHintText, 200,0, kTextAlignment.center)
end