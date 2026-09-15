local Recorder = {}
Recorder.__index = Recorder

--------------------------------
-- CREAR GRABADOR
--------------------------------

function Recorder.new()
    local self =
        setmetatable({}, Recorder)
    self.frames = {}
    self.time = 0
    return self
end

--------------------------------
-- GRABAR
--------------------------------

function Recorder:update(dt, player)
    self.time = self.time + dt
    table.insert(self.frames,
        {
            time = self.time,
            x = player.x,
            y = player.y,
            width = player.width,
            height = player.height,
            direction = player.direction,
            animation = player.animation,
            spriteFrame = player.spriteFrame
        }
)
end

--------------------------------
-- REINICIAR GRABACIÓN
--------------------------------

function Recorder:reset()
    self.frames = {}
    self.time = 0
end

--------------------------------
-- OBTENER GRABACIÓN
--------------------------------

function Recorder:getRecording()
    local copy = {}
    for i, frame in ipairs(self.frames) do
        copy[i] = {}
        for key, value in pairs(frame) do
            copy[i][key] = value
        end
    end
    return copy
end

return Recorder
