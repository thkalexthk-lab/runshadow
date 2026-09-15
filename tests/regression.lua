-- Ejecutar desde la raíz: lua tests/regression.lua
local keys, labels = {}, {}
local spriteDraws = {}
local function noop() end
love = {
    window = {setTitle = noop, setMode = noop},
    graphics = {
        setDefaultFilter = noop, setColor = noop, rectangle = noop,
        clear = noop, printf = noop,
        newImage = function(path)
            assert(path == "assets/player/assassin_sheet.png")
            return {setFilter = noop, getDimensions = function() return 2172, 724 end}
        end,
        newQuad = function(x, y, w, h, sw, sh)
            assert(x >= 0 and y >= 0 and x + w <= sw and y + h <= sh)
            return {x = x, y = y}
        end,
        draw = function(...) spriteDraws[#spriteDraws + 1] = {...} end,
        print = function(label) labels[#labels + 1] = label end
    },
    keyboard = {isDown = function(...)
        for i = 1, select("#", ...) do
            if keys[select(i, ...)] then return true end
        end
        return false
    end}
}

local Player = require("src.player")
local Recorder = require("src.recorder")
local Ghost = require("src.ghost")
local p = Player.new(100, 500)
local r = Recorder.new()
r:update(0, p)
p.x = 200
r:update(1, p)
local recording = r:getRecording()
recording[1].x = -1
assert(r:getRecording()[1].x == 100, "La copia no debe modificar la grabación")
local g = Ghost.new(r:getRecording())
r:reset()
assert(g.x == 100 and g.width == p.width and g.height == p.height)
g:update(0.5)
assert(g.x == 150, "Interpolación del fantasma")
g:update(2)
assert(g.x == 200, "El fantasma se detiene en la última posición")
Ghost.new({}):draw()

local floor = {{x = 0, y = 650, width = 1280, height = 70}}
for i = 1, 120 do p:update(1 / 60, floor) end
assert(p.onGround and p.y == 590)
p:jump()
local vy = p.vy
assert(vy < 0)
p:jump()
assert(p.vy == vy, "No debe haber doble salto")
for i = 1, 120 do p:update(1 / 60, floor) end
assert(p.onGround and p.y == 590)

-- Capturar instancias sin modificar las variables locales del juego.
for _, module in ipairs({Player, Recorder, Ghost}) do
    local new = module.new
    module.new = function(...)
        local instance = new(...)
        if module == Player then p = instance
        elseif module == Recorder then r = instance
        else g = instance end
        return instance
    end
end
dofile("main.lua")
love.load()
assert(r:getRecording()[1].time == 0)
assert(p.x == 80 and p.y == 500)
love.update(1)
assert(r.time == 0.25, "Grabación y física comparten el límite de tiempo")
p:reset(100, 950)
love.update(1 / 60)
assert(p.y == 500 and r.time == 0 and #r:getRecording() == 1)

local function secondRun(goalX)
    p:reset(goalX, 570)
    love.update(1 / 60)
    love.draw()
    for i = 1, 12 do love.update(0.25) end
    assert(g.time == 0 and g.x == 80, "El fantasma inicia en el punto de salida")
end

secondRun(1160)
love.update(1 / 60)
assert(g.time > 0)
p:reset(100, 950)
love.update(1 / 60)
assert(p.y == 500 and g.time == 0, "Caer reinicia también al fantasma")

-- Puerta cerrada: ambos lados y aterrizaje.
p:reset(670, 590)
keys.d = true
love.update(0.25)
assert(p.x == 680, "La puerta bloquea desde la izquierda")
keys.d = nil
p:reset(780, 590)
keys.a = true
love.update(0.25)
assert(p.x == 770, "La puerta bloquea desde la derecha")
keys.a = nil
p:reset(725, 430)
love.update(0.25)
assert(p.y == 440 and p.onGround, "Se puede aterrizar sobre la puerta")

-- Usar una grabación controlada para comprobar botón y cierre seguro.
g.recording = {
    {time = 0, x = 400, y = 590},
    {time = 0.1, x = 450, y = 590},
    {time = 0.2, x = 640, y = 590}
}
g.time, g.frame = 0, 1
p:reset(680, 590)
keys.d = true
love.update(0.1)
assert(p.x > 680, "El botón abre la puerta en el mismo cuadro")
local insideX = p.x
keys.d = nil
love.update(0.1)
assert(p.x == insideX and p.y == 590, "La puerta no aplasta al jugador")
keys.d = true
love.update(0.25)
assert(p.x >= 770)
keys.d = nil
love.update(1 / 60)
p:reset(780, 590)
keys.a = true
love.update(0.1)
assert(p.x == 770, "La puerta cierra al quedar libre")
keys.a = nil

p:reset(1160, 570)
love.update(1 / 60)
labels = {}
love.draw()
assert(labels[1] == "Nivel 2", "La segunda vuelta avanza al siguiente nivel")
assert(p.x == 80 and r.time == 0)
secondRun(1180)
p:reset(1180, 570)
love.update(1 / 60)
local finalX = p.x
love.update(0.25)
assert(p.x == finalX, "El juego completo queda detenido")
love.draw()
love.keypressed("r")
assert(p.x == 80 and p.y == 500 and r.time == 0)
assert(#r:getRecording() == 1)
labels = {}
love.draw()
assert(labels[1] == "Nivel 1 - Tu pasado")
assert(labels[2]:find("PRIMERA VUELTA", 1, true))

-- Un cuadro lento no debe atravesar una plataforma delgada.
p:reset(500, 0)
p.vy = 5000
p:update(0.25, floor)
assert(p.y == 590 and p.onGround)
print("OK: física, grabación, fantasma, dos niveles, botón, puerta y reinicios (LÖVE simulado).")

-- Las poses y la orientación se conservan en la repetición.
p:reset(100, 590)
keys.a = true
p:update(0.12, floor)
assert(p.direction == -1 and p.animation == "run")
p:update(0.12, floor)
assert(p.spriteFrame == 4)
r:reset()
r:update(0, p)
local replay = Ghost.new(r:getRecording())
assert(replay.direction == -1 and replay.spriteFrame == 4)
p:draw()
replay:draw()
local normal = spriteDraws[#spriteDraws - 1]
local shadow = spriteDraws[#spriteDraws]
assert(normal[2].y == 0 and shadow[2].y == 362)
assert(normal[6] < 0 and shadow[6] < 0, "Ambos sprites miran a la izquierda")
p:jump()
assert(p.animation == "jump" and p.spriteFrame == 7)
r:update(0.1, p)
replay = Ghost.new(r:getRecording())
replay:update(0.1)
assert(replay.animation == "jump" and replay.spriteFrame == 7)
keys.a = nil
p:reset(80, 500)
assert(p.direction == 1 and p.spriteFrame == 1 and p.animationTime == 0)
print("OK: atlas, animaciones, orientación y poses grabadas.")
