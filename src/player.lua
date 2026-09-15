local Sprite = require("src.sprite")
local Player = {}
Player.__index = Player

--------------------------------
-- CREAR JUGADOR
--------------------------------

function Player.new(x, y)
    local self =
        setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 40
    self.height = 60
    self.vx = 0
    self.vy = 0
    self.speed = 300
    self.jumpForce = -600
    self.gravity = 1500
    self.onGround = false
    self.direction = 1
    self.animation = "idle"
    self.animationTime = 0
    self.spriteFrame = 1
    return self
end

--------------------------------
-- ACTUALIZAR JUGADOR
--------------------------------

function Player:update(dt, platforms)
    dt = math.min(math.max(dt, 0), 0.25)
    local steps = math.ceil(dt * 120)
    for _ = 1, steps do
        self:updateStep(dt / steps, platforms)
    end
    self:updateAnimation(dt)
end

function Player:updateAnimation(dt)
    local animation
    if not self.onGround then
        animation = self.vy < 0 and "jump" or "fall"
    else
        animation = self.vx == 0 and "idle" or "run"
    end
    if animation ~= self.animation then
        self.animationTime = 0
    else
        self.animationTime = self.animationTime + dt
    end
    self.animation = animation
    self.spriteFrame = Sprite.frame(animation, self.animationTime)
end

function Player:updateStep(dt, platforms)

    --------------------------------
    -- MOVIMIENTO HORIZONTAL
    --------------------------------
    local direction = 0
    if love.keyboard.isDown("a", "left") then
        direction = direction - 1
    end
    if love.keyboard.isDown("d", "right") then
        direction = direction + 1
    end
    if direction ~= 0 then self.direction = direction end
    self.vx = direction * self.speed
    self.x = self.x + self.vx * dt

    --------------------------------
    -- COLISIONES HORIZONTALES
    --------------------------------
    for _, platform in ipairs(platforms) do
        if self:collides(platform) then
            if self.vx > 0 then
                self.x = platform.x - self.width
            elseif self.vx < 0 then
                self.x = platform.x + platform.width
            end
        end
    end

    --------------------------------
    -- GRAVEDAD
    --------------------------------
    self.vy = self.vy + self.gravity * dt
    self.y = self.y + self.vy * dt

    --------------------------------
    -- COLISIONES VERTICALES
    --------------------------------
    self.onGround = false
    for _, platform in ipairs(platforms) do
        if self:collides(platform) then

            --------------------------------
            -- CAYENDO
            --------------------------------
            if self.vy > 0 then
                self.y = platform.y - self.height
                self.vy = 0
                self.onGround = true

            --------------------------------
            -- GOLPE DESDE ABAJO
            --------------------------------
            elseif self.vy < 0 then
                self.y = platform.y + platform.height
                self.vy = 0
            end
        end
    end
end

--------------------------------
-- SALTAR
--------------------------------

function Player:jump()
    if self.onGround then
        self.vy = self.jumpForce
        self.onGround = false
        self:updateAnimation(0)
    end
end

--------------------------------
-- COLISIÓN
--------------------------------

function Player:collides(object)
    return self.x < object.x + object.width and self.x + self.width > object.x and self.y <
        object.y + object.height and self.y + self.height > object.y
end

--------------------------------
-- DIBUJAR JUGADOR
--------------------------------

function Player:draw()
    Sprite.draw(self, false)
end

--------------------------------
-- REINICIAR JUGADOR
--------------------------------

function Player:reset(x, y)
    self.x = x
    self.y = y
    self.vx = 0
    self.vy = 0
    self.onGround = false
    self.direction = 1
    self.animation = "idle"
    self.animationTime = 0
    self.spriteFrame = 1
end

return Player
