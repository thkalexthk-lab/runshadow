local Ghost = {}

Ghost.__index = Ghost


--------------------------------
-- CREAR FANTASMA
--------------------------------

function Ghost.new(recording)

    local self =
        setmetatable({}, Ghost)

    self.recording =
        recording

    self.time = 0

    self.frame = 1


    self.x = 0
    self.y = 0


    self.width = 40
    self.height = 60


    if recording[1] then

        self.x =
            recording[1].x

        self.y =
            recording[1].y

    end


    return self

end


--------------------------------
-- ACTUALIZAR FANTASMA
--------------------------------

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

    end

end


--------------------------------
-- DIBUJAR FANTASMA
--------------------------------

function Ghost:draw()

    love.graphics.setColor(
        0.3,
        0.8,
        1,
        0.40
    )


    love.graphics.rectangle(
        "fill",
        self.x,
        self.y,
        self.width,
        self.height
    )


    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

end


return Ghost