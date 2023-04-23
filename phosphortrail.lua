import "CoreLibs/graphics.lua"

local gfx = playdate.graphics

class('PhosphorTrail').extends(playdate.graphics.sprite)

function PhosphorTrail:init()
    self.kFrames = 5
    self.visibilities = {}
    self.positions = {}
    
    self:setSize(400, 240)
    self:setCenter(0.5,0.5)
    self:moveTo(0,0)

    self.parentWidth=0
    self.parentHeight=0


    for i=1,self.kFrames do
        table.insert(self.visibilities, false)
    end
    for i=1, self.kFrames do
        table.insert(self.positions, {0,0})
    end
    self:addSprite()
    --self:setZIndex(32767) -- ensure this is updated after parent sprite

end

function PhosphorTrail:addParent(parentSprite)
    self.parent = parentSprite
    self.parentWidth, self.parentHeight = self.parent:getSize()
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
        self:moveTo(math.floor(maxTrailX + minTrailX)/2,
                math.ceil((maxTrailY + minTrailY)/2))       
        self:markDirty()

        -- printTable(self:getPosition())
        -- printTable(self:getSize())
    end
end

function PhosphorTrail:draw()
    for i=1, self.kFrames - 1 do --no need to overdraw the actual sprite
        if self.visibilities[i] then
            local alpha = (i/self.kFrames) * 0.625 -- bit of rapid falloff
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(1 - alpha, gfx.image.kDitherTypeBayer4x4)
            local pos = self.positions[i]
            gfx.fillRect((pos[1]-self.x) + math.ceil(self.width/2) - math.ceil(self.parentWidth/2),
                (pos[2]-self.y) + math.ceil(self.height/2) - math.ceil(self.parentHeight/2),
                self.parentWidth, self.parentHeight)
        end
    end
    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.drawRect(0,0,self.width, self.height)
end