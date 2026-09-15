-- Atlas original: las poses tienen anchos distintos y no forman una cuadrícula.
local Sprite = {}
local sheet
local quads = {{}, {}}
local columns = {
    {40, 200}, {295, 215}, {550, 260}, {825, 255},
    {1095, 255}, {1360, 270}, {1640, 255}, {1900, 220}
}
local animations = {
    idle = {1, 2},
    run = {3, 4, 5, 6},
    jump = {7},
    fall = {8}
}

function Sprite.frame(animation, time)
    local frames = animations[animation] or animations.idle
    local rate = animation == "run" and 10 or 3
    return frames[math.floor((time or 0) * rate) % #frames + 1]
end

local function load()
    if sheet then return end
    sheet = love.graphics.newImage("assets/player/assassin_sheet.png")
    sheet:setFilter("nearest", "nearest")
    local width, height = sheet:getDimensions()
    for row = 1, 2 do
        for i, column in ipairs(columns) do
            quads[row][i] = love.graphics.newQuad(
                column[1], (row - 1) * 362, column[2], 362, width, height)
        end
    end
end

function Sprite.draw(actor, isGhost)
    load()
    local frame = actor.spriteFrame or Sprite.frame(actor.animation, 0)
    local row = isGhost and 2 or 1
    local scale = actor.height / 270
    if isGhost then
        love.graphics.setColor(0.65, 0.85, 1, 0.55)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    -- Alinear los pies y centrar la pose en el cuerpo de colisión.
    love.graphics.draw(sheet, quads[row][frame],
        actor.x + actor.width / 2, actor.y + actor.height, 0,
        scale * (actor.direction or 1), scale,
        columns[frame][2] / 2, row == 1 and 342 or 316)
    love.graphics.setColor(1, 1, 1, 1)
end

return Sprite
