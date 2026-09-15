local Sprite = require("src.sprite")
local Ghost = {}

Ghost.__index = Ghost


function Ghost.new(recording)

    local self =
        setmetatable({}, Ghost)

    self.recording = recording

    self.time = 0
    self.frame = 1

    self.x = 0
    self.y = 0

    self.width = recording[1] and recording[1].width or 40
    self.height = recording[1] and recording[1].height or 60

    self.direction = 1
    self.animation = "idle"
    self.spriteFrame = 1


    if recording[1] then

        self.x =
            recording[1].x

        self.y =
            recording[1].y

        self.direction =
            recording[1].direction or 1

        self.animation =
            recording[1].animation or "idle"

        self.spriteFrame = recording[1].spriteFrame or Sprite.frame(self.animation, 0)

    end


    return self

end


function Ghost:update(dt)

    self.time =
        self.time + dt


    while
        self.recording[self.frame + 1]

        and

        self.recording[self.frame + 1].time
        <= self.time
    do

        self.frame =
            self.frame + 1

    end


    local data =
        self.recording[self.frame]


    if data then

        self.x =
            data.x

        self.y =
            data.y

        local nextData = self.recording[self.frame + 1]
        if nextData and nextData.time > data.time then
            local alpha = math.max(0, math.min(1,
                (self.time - data.time) / (nextData.time - data.time)))
            self.x = data.x + (nextData.x - data.x) * alpha
            self.y = data.y + (nextData.y - data.y) * alpha
        end

        self.direction =
            data.direction or 1

        self.animation =
            data.animation or "idle"

        self.spriteFrame = data.spriteFrame or Sprite.frame(self.animation, 0)

    end

end


function Ghost:draw()
    Sprite.draw(self, true)
end

return Ghost
