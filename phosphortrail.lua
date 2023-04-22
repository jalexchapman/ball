import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('PhosphorTrail').extends(playdate.graphics.sprite)

function PhosphorTrail:init()
    self.kFrames = 8
    self.visibilities = {}
    self.positions = {}
    
    --paint as a full screen overlay
    self:setSize(400, 240)
    self:setCenter(0,0)
    self:moveTo(0,0)

    self.parentWidth=0
    self.parentHeight=0
    self.parentCenterX=0
    self.parentCenterY=0

    for i=1,self.kFrames do
        table.insert(self.visibilities, false)
    end
    for i=1, self.kFrames do
        table.insert(self.positions, {0,0})
    end
    self:addSprite()
end

function PhosphorTrail:addParent(parentSprite)
    self.parent = parentSprite
    self.parentWidth, self.parentHeight = self.parent:getSize()
    self.parentCenterX, self.parentCenterY = self.parent:getCenter()
end

function PhosphorTrail:update()
    if self.parent ~= nil then
        local lastPos = self.positions[self.kFrames]
        local newPos = {self.parent.x, self.parent.y}
        local midPos = {(lastPos[1]+newPos[1])/2, (lastPos[2]+newPos[2])/2}
        table.remove(self.positions, 1)
        table.insert(self.positions, midPos)
        table.remove(self.positions, 1)
        table.insert(self.positions, newPos)
        table.remove(self.visibilities, 1)
        table.insert(self.visibilities, self.parent:isVisible())
        table.remove(self.visibilities, 1)
        table.insert(self.visibilities, self.parent:isVisible())
        self:markDirty()
    end
end

function PhosphorTrail:draw()
    for i=1, self.kFrames - 1 do --no need to overdraw the actual sprite
        if self.visibilities[i] then
            local alpha = (i/self.kFrames) * 0.75 -- bit of rapid falloff
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(1 - alpha, gfx.image.kDitherTypeBayer4x4)
            local pos = self.positions[i]
            local topLeftX = pos[1] - (math.ceil(self.parentWidth/2))
            local topLeftY = pos[2] - (math.ceil(self.parentHeight/2))
            gfx.fillRect(topLeftX, topLeftY, self.parentWidth, self.parentHeight)
        end
    end
end