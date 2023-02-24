--[[
    GD50
    Match-3 Remake

    -- Tile Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The individual tiles that make up our game board. Each Tile can have a
    color and a variety, with the varietes adding extra points to the matches.
]]

Tile = Class{}

function Tile:init(x, y, color, variety, shinyProb)
    
    -- board positions
    self.gridX = x
    self.gridY = y

    -- coordinate positions
    self.x = (self.gridX - 1) * 32
    self.y = (self.gridY - 1) * 32

    -- tile appearance/points
    self.color = color
    self.variety = variety

    -- probability for shiny tile
    self.shiny = shinyProb == 1 and true or false
    self.alpha = 100/255
end

function Tile:update(dt)
    -- tween alpha on shiny tiles
    if self.alpha == 100/255 then
        Timer.tween(0.75, {
            [self] = {alpha = 0}
        })
    elseif self.alpha == 0 then
        Timer.tween(0.75, {
            [self] = {alpha = 100/255}
        })
    end
end

function Tile:render(x, y)
    
    -- draw shadow
    love.graphics.setColor(34/255, 32/255, 52/255, 255/255)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x + 2, self.y + y + 2)

    -- draw tile itself
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
        self.x + x, self.y + y)

    if self.shiny then
        -- draw shiny overlay
        love.graphics.setBlendMode('add')

        love.graphics.setColor(1, 1, 1, self.alpha)
        love.graphics.rectangle('fill', self.x + x, self.y + y, 32, 32, 4)

        love.graphics.setBlendMode('alpha')
    end
end