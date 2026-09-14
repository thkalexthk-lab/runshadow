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

    self.time =
        self.time + dt


    table.insert(
        self.frames,
        {
            time = self.time,

            x = player.x,

            y = player.y
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

    return self.frames

end


return Recorder