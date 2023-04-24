import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('Bloom').extends(playdate.graphics.sprite)


function Bloom:init()
    self:setSize(5,5)
    self:setCenter(0.5,0.5)
    self:moveTo(0,0)

    self.kBorderWidth = 1
    self.parentWidth=0
    self.parentHeight=0

    self:setZIndex(32767) -- ensure this is updated after parent sprite

end

function Bloom:addParent(parentSprite)
    self.parent = parentSprite
    self:setSize(parentSprite.width + 2 * self.kBorderWidth,
        parentSprite.height+ 2 * self.kBorderWidth)
    self:addSprite()

end

function Bloom:update()
    if self.parent ~= nil then
        self:moveTo(self.parent.x, self.parent.y)
        -- self:markDirty()
    end
end

function Bloom:draw()
    if self.parent ~= nil and self.parent:isVisible() then
        gfx.setColor(gfx.kColorWhite)
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer4x4)
        gfx.fillRect(0,0,self.width, self.height)
    end
end