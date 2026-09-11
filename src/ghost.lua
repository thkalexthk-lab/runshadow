local Ghost = {}

Ghost.__index = Ghost

function Ghost.new(recording)

    local self = setmetatable({}, Ghost)

    self.recording = recording

    self.time = 0
    self.frame = 1

    self.x = 0
    self.y = 0

    self.width = 32
    self.height = 48

    if recording[1] then
        self.x = recording[1].x
        self.y = recording[1].y
        self.width = recording[1].width or self.width
        self.height = recording[1].height or self.height
    end

    return self

end

function Ghost:update(dt)

    self.time = self.time + math.max(dt, 0)

    while
        self.recording[self.frame + 1]
        and
        self.recording[self.frame + 1].time <= self.time
    do

        self.frame = self.frame + 1

    end

    local data = self.recording[self.frame]

    if data then

        self.x = data.x
        self.y = data.y
        local nextData = self.recording[self.frame + 1]
        if nextData and nextData.time > data.time then
            local alpha = math.max(0, math.min(1,
                (self.time - data.time) / (nextData.time - data.time)))
            self.x = data.x + (nextData.x - data.x) * alpha
            self.y = data.y + (nextData.y - data.y) * alpha
        end

    end

end

function Ghost:draw()
    if not self.recording[1] then return end

    love.graphics.setColor(
        0.3,
        0.8,
        1,
        0.45
    )

    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height
    )

    love.graphics.setColor(1, 1, 1, 1)

end

return Ghost
