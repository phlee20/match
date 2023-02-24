--[[
    GD50
    Match-3 Remake

    -- Board Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Board is our arrangement of Tiles with which we must try to find matching
    sets of three horizontally or vertically.
]]

Board = Class{}

-- game settings
local tileColours = 8
local levelUp = 3
local shinyProb = 40

function Board:init(x, y, level)
    self.x = x
    self.y = y
    self.matches = {}

    self:initializeTiles(level)
end

function Board:initializeTiles(level)
    self.tiles = {}

    -- start at level 1 and increase tile variety every levelUp levels 
    local tileVariety = math.min(6, math.floor(level / levelUp + 1))

    for tileY = 1, 8 do
        
        -- empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            -- create a new tile at X,Y with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(tileColours),
                math.random(tileVariety), math.random(shinyProb)))
        end
    end

    while self:calculateMatches() do
        
        -- recursively initialize if matches were returned so we always have
        -- a matchless board on start
        self:initializeTiles(level)
    end

    while self:noPotentialMatches() do

        -- recursively initialize if no potential matches exist
        self:initializeTiles(level)
    end
end

--[[
    Check that potential matches exist within one move
]]
function Board:noPotentialMatches()
    
    local noMatches = true

    -- horizontal swaps
    for y = 1, 8 do
        for x = 1, 7 do
            -- swap tiles
            local tempTile = self.tiles[y][x]
            self.tiles[y][x] = self.tiles[y][x + 1]
            self.tiles[y][x + 1] = tempTile

            -- check for matches
            if self:calculateMatches() then
                noMatches = false
            end
            
            -- revert tiles
            local tempTile = self.tiles[y][x]
            self.tiles[y][x] = self.tiles[y][x + 1]
            self.tiles[y][x + 1] = tempTile

            -- if match is found, return false to start game
            if not noMatches then
                return false
            end
        end
    end

    -- vertical swaps
    for x = 1, 8 do
        for y = 1, 7 do
            -- swap tiles
            local tempTile = self.tiles[y][x]
            self.tiles[y][x] = self.tiles[y + 1][x]
            self.tiles[y + 1][x] = tempTile

            -- check for matches
            if self:calculateMatches() then
                noMatches = false
            end
            
            -- revert tiles
            local tempTile = self.tiles[y][x]
            self.tiles[y][x] = self.tiles[y + 1][x]
            self.tiles[y + 1][x] = tempTile

            -- if match is found, return false to start game
            if not noMatches then
                return false
            end
        end
    end

    -- if no matches are found, returns true to be re-initialized
    return true
end

--[[
    Goes left to right, top to bottom in the board, calculating matches by counting consecutive
    tiles of the same color. Doesn't need to check the last tile in every row or column if the 
    last two haven't been a match.
]]
function Board:calculateMatches()
    local matches = {}

    -- how many of the same color blocks in a row we've found
    local matchNum = 1

    -- horizontal matches first
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1
        
        -- every horizontal tile
        for x = 2, 8 do
            
            -- if this is the same color as the one we're trying to match...
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                
                -- set this as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                -- if we have a match of 3 or more up to now, add it to our matches table
                if matchNum >= 3 then
                    local match = {}

                    local shinyExists = false

                    -- go backwards from here by matchNum
                    for x2 = x - 1, x - matchNum, -1 do

                        -- check for existence of shiny tiles
                        local tileShiny = self.tiles[y][x2].shiny and true or false
                        if shinyExists or tileShiny then
                            shinyExists = true
                        end
                    end

                    if shinyExists then
                        -- add all the tiles in the row to the match
                        for x = 1, 8 do
                            table.insert(match, self.tiles[y][x])
                        end
                    else
                        -- add just the regular tiles
                        for x2 = x - 1, x - matchNum, -1 do

                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y][x2])
                        end
                    end

                    -- add this match to our total matches table
                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if x >= 7 then
                    break
                end
            end
        end

        -- account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            local shinyExists = false

            -- go backwards from here by matchNum
            for x = 8, 8 - matchNum + 1, -1 do

                -- check for existence of shiny tiles
                local tileShiny = self.tiles[y][x].shiny and true or false
                if shinyExists or tileShiny then
                    shinyExists = true
                end
            end

            if shinyExists then
                -- add all the tiles in the row to the match
                for x = 1, 8 do
                    table.insert(match, self.tiles[y][x])
                end
            else
                -- add just the regular tiles
                -- go backwards from end of last row by matchNum
                for x = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- vertical matches
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    local shinyExists = false

                    -- go backwards from here by matchNum
                    for y2 = y - 1, y - matchNum, -1 do

                        -- check for existence of shiny tiles
                        local tileShiny = self.tiles[y2][x].shiny and true or false
                        if shinyExists or tileShiny then
                            shinyExists = true
                        end
                    end

                    if shinyExists then
                        -- add all the tiles in the row to the match
                        for y = 1, 8 do
                            table.insert(match, self.tiles[y][x])
                        end
                    else
                        -- add just the regular tiles
                        for y2 = y - 1, y - matchNum, -1 do

                            -- add each tile to the match that's in that match
                            table.insert(match, self.tiles[y2][x])
                        end
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            local shinyExists = false

            -- go backwards from here by matchNum
            for y = 8, 8 - matchNum + 1, -1 do

                -- check for existence of shiny tiles
                local tileShiny = self.tiles[y][x].shiny and true or false
                if shinyExists or tileShiny then
                    shinyExists = true
                end
            end

            if shinyExists then
                -- add all the tiles in the row to the match
                for y = 1, 8 do
                    table.insert(match, self.tiles[y][x])
                end
            else
                -- add just the regular tiles
                -- go backwards from end of last row by matchNum
                for y = 8, 8 - matchNum + 1, -1 do
                    table.insert(match, self.tiles[y][x])
                end
            end

            table.insert(matches, match)
        end
    end

    -- store matches for later reference
    self.matches = matches

    -- return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--[[
    Remove the matches from the Board by just setting the Tile slots within
    them to nil, then setting self.matches to nil.
]]
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

--[[
    Shifts down all of the tiles that now have spaces below them, then returns a table that
    contains tweening information for these new tiles.
]]
function Board:getFallingTiles(level)
    -- tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    -- start at level 1 and increase tile variety every 4 levels 
    local tileVariety = math.min(6, math.floor(level / levelUp + 1))

    -- for each column, go up tile by tile till we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            
            -- if our last tile was a space...
            local tile = self.tiles[y][x]
            
            if space then
                
                -- if the current tile is *not* a space, bring this down to the lowest space
                if tile then
                    
                    -- put the tile in the correct spot in the board and fix its grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    -- set its prior position to nil
                    self.tiles[y][x] = nil

                    -- tween the Y position to 32 x its grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    -- set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    -- set this back to 0 so we know we don't have an active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true
                
                -- if we haven't assigned a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            y = y - 1
        end
    end

    -- create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            -- if the tile is nil, we need to add a new one
            if not tile then

                -- new tile with random color and variety
                local tile = Tile(x, y, math.random(tileColours), 
                    math.random(tileVariety), math.random(shinyProb))
                tile.y = -32
                self.tiles[y][x] = tile

                -- create a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens
end

function Board:update(dt)
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:update(dt)
        end
    end
end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end