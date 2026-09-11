local Recorder = {}
Recorder.__index = Recorder

function Recorder.new()
    local self = setmetatable({}, Recorder)
    self:reset()
    return self
end

function Recorder:reset()
    self.time = 0
    self.frames = {}
end

function Recorder:update(dt, player)
    self.time = self.time + math.max(dt, 0)
    local frame = {
        time = self.time,
        x = player.x,
        y = player.y,
        width = player.width,
        height = player.height
    }
    local last = self.frames[#self.frames]
    if last and last.time == self.time then
        self.frames[#self.frames] = frame
    else
        self.frames[#self.frames + 1] = frame
    end
end

function Recorder:getRecording()
    local recording = {}
    for i, frame in ipairs(self.frames) do
        recording[i] = {
            time = frame.time, x = frame.x, y = frame.y,
            width = frame.width, height = frame.height
        }
    end
    return recording
end

return Recorder
