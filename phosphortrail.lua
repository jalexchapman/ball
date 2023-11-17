import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('PhosphorTrail').extends(playdate.graphics.sprite)

function PhosphorTrail:init()
    self.trailFrames = 3
    self.visibilities = {}
    self.positions = {}
    
    self:setSize(400, 240)
    self:setCenter(0,0)
    self:moveTo(0,0)

    self.parentWidth=0
    self.parentHeight=0


    for i=1,self.trailFrames do
        table.insert(self.visibilities, false)
    end
    for i=1, self.trailFrames do
        table.insert(self.positions, {0,0})
    end
    self:addSprite()
    self:setZIndex(32767) -- ensure this is updated after parent sprite

end

function PhosphorTrail:setLength(newFrames)
    if newFrames < 1 then
        newFrames = 1 -- always store curent pos, never empty
    end
    if newFrames < self.trailFrames then
        for i = 1, self.trailFrames - newFrames do
            table.remove(self.positions, 1)
            table.remove(self.visibilities, 1)
        end
    elseif newFrames > self.trailFrames then
        for i = 1, newFrames - self.trailFrames do
            table.insert(self.positions, {0,0})
            table.insert(self.visibilities, false)
        end
    end
    self.trailFrames = newFrames
end

function PhosphorTrail:addParent(parentSprite)
    self.parent = parentSprite
    self.parentWidth, self.parentHeight = self.parent:getSize()
end

function PhosphorTrail:update()
    if self.parent ~= nil then
        local lastPos = self.positions[self.trailFrames]
        local newPos = {self.parent.x, self.parent.y}
        table.remove(self.positions, 1)
        table.insert(self.positions, newPos)
        table.remove(self.visibilities, 1)
        table.insert(self.visibilities, self.parent:isVisible())

        --set size/center to bound draw area of all stored positions
        local minTrailX, maxTrailX, minTrailY, maxTrailY = 400,0,240,0
        for i, pos in ipairs(self.positions) do
            minTrailX = pos[1] < minTrailX and pos[1] or minTrailX
            maxTrailX = pos[1] > maxTrailX and pos[1] or maxTrailX
            minTrailY = pos[2] < minTrailY and pos[2] or minTrailY
            maxTrailY = pos[2] > maxTrailY and pos[2] or maxTrailY
        end
        -- print("trail x [", minTrailX, ",", maxTrailX,"] y [",minTrailY, ",", maxTrailY, "]")
        self:setSize(maxTrailX - minTrailX + self.parentWidth,
                maxTrailY - minTrailY + self.parentHeight)
        self:moveTo(minTrailX - math.floor(self.parentWidth/2),
            minTrailY - math.floor(self.parentHeight/2))
        self:markDirty()

        -- printTable(self:getPosition())
        -- printTable(self:getSize())
    end
end

function PhosphorTrail:draw()
    for i=1, self.trailFrames - 1 do --no need to overdraw the actual sprite
        if self.visibilities[i] then
            local alpha = (i/self.trailFrames) * 0.5 -- bit of rapid falloff
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(1 - alpha, gfx.image.kDitherTypeBayer4x4)
            local pos = self.positions[i]
            gfx.fillRect((pos[1]-self.x) - math.floor(self.parentWidth/2),
                (pos[2]-self.y) - math.floor(self.parentHeight/2),
                self.parentWidth, self.parentHeight)
        end
    end
    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.drawRect(0,0,self.width, self.height)
end