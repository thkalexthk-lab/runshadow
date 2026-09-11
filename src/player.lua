local Player = {}
Player.__index = Player

function Player.new(x, y)
    local self = setmetatable({
        width = 32,
        height = 48,
        speed = 300,
        gravity = 1500,
        jumpSpeed = 650
    }, Player)
    self:reset(x, y)
    return self
end

function Player:reset(x, y)
    self.x, self.y = x, y
    self.vy = 0
    self.grounded = false
end

local function overlaps(a, b)
    return a.x < b.x + b.width and a.x + a.width > b.x
        and a.y < b.y + b.height and a.y + a.height > b.y
end

function Player:collides(other)
    return overlaps(self, other)
end

function Player:update(dt, platforms)
    local direction = 0
    if love.keyboard.isDown("a", "left") then direction = direction - 1 end
    if love.keyboard.isDown("d", "right") then direction = direction + 1 end

    -- Pasos pequeños evitan atravesar plataformas cuando baja la tasa de cuadros.
    local remaining = math.min(math.max(dt, 0), 0.25)
    while remaining > 1e-9 do
        local step = math.min(remaining, 1 / 240)
        remaining = remaining - step

        local dx = direction * self.speed * step
        self.x = self.x + dx
        for _, platform in ipairs(platforms) do
            if overlaps(self, platform) then
                if dx > 0 then
                    self.x = platform.x - self.width
                elseif dx < 0 then
                    self.x = platform.x + platform.width
                end
            end
        end

        self.vy = self.vy + self.gravity * step
        local dy = self.vy * step
        self.y = self.y + dy
        self.grounded = false
        for _, platform in ipairs(platforms) do
            if overlaps(self, platform) then
                if dy > 0 then
                    self.y = platform.y - self.height
                    self.grounded = true
                    self.vy = 0
                elseif dy < 0 then
                    self.y = platform.y + platform.height
                    self.vy = 0
                end
            end
        end
    end
end

function Player:jump()
    if self.grounded then
        self.vy = -self.jumpSpeed
        self.grounded = false
    end
end

function Player:draw()
    love.graphics.setColor(0.75, 0.9, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Player
