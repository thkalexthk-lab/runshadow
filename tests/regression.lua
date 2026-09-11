-- Ejecutar desde la raíz: lua tests/regression.lua
local keys, labels = {}, {}
local function noop() end
love = {
    window = {setTitle = noop, setMode = noop},
    graphics = {
        setDefaultFilter = noop, setColor = noop, rectangle = noop,
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
assert(p.grounded and p.y == 602)
p:jump()
local vy = p.vy
assert(vy < 0)
p:jump()
assert(p.vy == vy, "No debe haber doble salto")
for i = 1, 120 do p:update(1 / 60, floor) end
assert(p.grounded and p.y == 602)

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
love.update(1)
assert(r.time == 0.25, "Reloj de grabación limitado igual que la física")
p:reset(100, 950)
love.update(1 / 60)
assert(p.y == 500 and r.time == 0 and #r:getRecording() == 1)

keys.d = true
local transitioned = false
for i = 1, 600 do
    keys.d = p.x < 1150
    local previousX = p.x
    if p.grounded and ((p.y == 602 and p.x > 225 and p.x < 300)
        or (p.y == 472 and p.x > 460)
        or (p.y == 372 and p.x > 720)) then love.keypressed("space") end
    love.update(1 / 60)
    if p.x < previousX then transitioned = true; break end
end
keys.d = nil
assert(transitioned and g.time == 0 and g.x == 100, "Primera vuelta y creación del fantasma")
love.update(1 / 60)
assert(g.time > 0)
p:reset(100, 950)
love.update(1 / 60)
assert(p.y == 500 and g.time == 0, "Caer reinicia también al fantasma")

keys.d = true
for i = 1, 600 do
    keys.d = p.x < 1150
    if p.grounded and ((p.y == 602 and p.x > 225 and p.x < 300)
        or (p.y == 472 and p.x > 460)
        or (p.y == 372 and p.x > 720)) then love.keypressed("space") end
    love.update(1 / 60)
end
labels = {}
love.draw()
assert(labels[1]:find("Nivel completado", 1, true), "Final de la segunda vuelta")
local finalX = p.x
love.update(1 / 60)
assert(p.x == finalX, "La partida completada queda detenida")
love.keypressed("r")
keys.d = nil
assert(p.x == 100 and p.y == 500 and r.time == 0)
assert(#r:getRecording() == 1 and r:getRecording()[1].x == 100)
labels = {}
love.draw()
assert(labels[1]:find("PRIMERA VUELTA", 1, true))
-- La puerta está abierta durante la primera vuelta.
p:reset(760, 602)
keys.d = true
love.update(0.25)
assert(p.x > 800, "Primera vuelta transitable sin plataformas")
keys.d = nil
startGhostRun()
-- Puerta cerrada: ambos lados y aterrizaje sobre ella.
p:reset(760, 602)
keys.d = true
love.update(0.25)
assert(p.x == 768, "La puerta bloquea desde la izquierda")
keys.d = nil
p:reset(860, 602)
keys.a = true
love.update(0.25)
assert(p.x == 850, "La puerta bloquea desde la derecha")
keys.a = nil
p:reset(810, 440)
love.update(0.25)
assert(p.y == 452 and p.grounded, "Se puede aterrizar sobre la puerta")

-- El fantasma entra en el botón durante este mismo cuadro.
r:reset()
r:update(0, {x = 400, y = 602, width = 32, height = 48})
r:update(0.1, {x = 450, y = 602, width = 32, height = 48})
r:update(0.1, {x = 600, y = 602, width = 32, height = 48})
startGhostRun()
p:reset(768, 602)
keys.d = true
love.update(0.1)
assert(p.x > 768, "El botón abre la puerta sin un cuadro de retraso")
local insideX = p.x
keys.d = nil
love.update(0.1)
assert(p.x == insideX and p.y == 602, "La puerta no aplasta al jugador al cerrarse")
keys.d = true
love.update(0.25)
assert(p.x >= 850, "El jugador puede terminar de atravesar la puerta")
keys.d = nil
love.update(1 / 60)
p:reset(860, 602)
keys.a = true
love.update(0.1)
assert(p.x == 850, "La puerta vuelve a cerrar al quedar libre")
keys.a = nil
love.keypressed("r")
p:reset(760, 602)
keys.d = true
love.update(0.1)
assert(p.x > 768, "Reiniciar abre la puerta para la primera vuelta")
keys.d = nil
love.draw()
-- Visibilidad y colisión de las plataformas según la vuelta.
local elevatedDraws = 0
love.graphics.rectangle = function(_, _, _, width, height)
    if width == 200 and height == 30 then elevatedDraws = elevatedDraws + 1 end
end
love.keypressed("r")
love.draw()
assert(elevatedDraws == 0, "Las plataformas no se dibujan en la primera vuelta")
p:reset(350, 450)
for i = 1, 60 do love.update(1 / 60) end
assert(p.y == 602, "Primera vuelta: atraviesa la plataforma y aterriza en el suelo")
startGhostRun()
love.draw()
assert(elevatedDraws == 3, "Segunda vuelta: se dibujan las tres plataformas")
p:reset(350, 450)
for i = 1, 60 do love.update(1 / 60) end
assert(p.y == 472 and p.grounded, "Segunda vuelta: aterriza sobre la plataforma")
love.keypressed("r")
elevatedDraws = 0
love.draw()
assert(elevatedDraws == 0, "Reiniciar vuelve a ocultar las plataformas")
print("OK: física, grabación, dos vueltas, botón, puerta y reinicios (LÖVE simulado).")
