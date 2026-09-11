local Player = require("src.player")
local Recorder = require("src.recorder")
local Ghost = require("src.ghost")

local player
local recorder
local ghost

local platforms
local goal

local gameState

local button
local door


local function platformAvailable(platform)
    return platform.isGround or gameState ~= "first_run"
end

local function updateDoor()
    button.pressed = gameState == "ghost_run" and ghost ~= nil
        and checkCollision(ghost.x, ghost.y, ghost.width, ghost.height,
            button.x, button.y, button.width, button.height)
    -- No cerrar sobre el jugador mientras atraviesa la puerta.
    door.open = gameState == "first_run" or button.pressed
        or (door.open and player:collides(door))
end


function love.load()


    button = {
    x = 450,
    y = 630,
    width = 70,
    height = 20,
    pressed = false
}

door = {
    x = 800,
    y = 500,
    width = 50,
    height = 150,
    open = true
}


    love.window.setTitle("Ghost Platformer")

    love.window.setMode(1280, 720, {
        resizable = false,
        vsync = true
    })

    love.graphics.setDefaultFilter("nearest", "nearest")


    --------------------------------
    -- JUGADOR
    --------------------------------

    player = Player.new(100, 500)


    --------------------------------
    -- GRABADOR
    --------------------------------

    recorder = Recorder.new()
    recorder:update(0, player)
    ghost = nil


    --------------------------------
    -- ESTADO
    --------------------------------

    gameState = "first_run"


    --------------------------------
    -- PLATAFORMAS
    --------------------------------

    platforms = {

        -- Suelo
        {
            isGround = true,
            x = 0,
            y = 650,
            width = 1280,
            height = 70
        },

        {
            x = 300,
            y = 520,
            width = 200,
            height = 30
        },

        {
            x = 600,
            y = 420,
            width = 200,
            height = 30
        },

        {
            x = 900,
            y = 320,
            width = 200,
            height = 30
        }

    }


    --------------------------------
    -- META
    --------------------------------

    goal = {
        x = 1150,
        y = 570,
        width = 50,
        height = 80
    }

end


function love.update(dt)
    if gameState == "completed" then return end
    -- Usar el mismo tiempo para física, grabación y reproducción.
    dt = math.min(math.max(dt, 0), 0.25)

    --------------------------------
    -- JUGADOR
    --------------------------------

    if gameState == "ghost_run" and ghost then
        ghost:update(dt)
    end
    updateDoor()

    local solids = {}
    for _, platform in ipairs(platforms) do
        if platformAvailable(platform) then
            solids[#solids + 1] = platform
        end
    end
    if not door.open then
        solids[#solids + 1] = door
    end
    player:update(dt, solids)

    --------------------------------
    -- PRIMERA VUELTA
    --------------------------------

    if gameState == "first_run" then

        -- Grabar al jugador
        recorder:update(dt, player)

    end


    --------------------------------
    -- META
    --------------------------------

    if player:collides(goal) then

        if gameState == "first_run" then

            startGhostRun()

        elseif gameState == "ghost_run" then

            print("¡Segunda vuelta completada!")
            gameState = "completed"

        end

    end


    --------------------------------
    -- CAER DEL MAPA
    --------------------------------

    if player.y > 900 then

        player:reset(100, 500)
        if gameState == "first_run" then
            recorder:reset()
            recorder:update(0, player)
        elseif gameState == "ghost_run" then
            ghost = Ghost.new(recorder:getRecording())
        end
        door.open = false
        updateDoor()

    end

end


function love.draw()

    --------------------------------
    -- PLATAFORMAS
    --------------------------------

    love.graphics.setColor(0.4, 0.4, 0.4)

    for _, platform in ipairs(platforms) do
        if platformAvailable(platform) then
        love.graphics.rectangle(
            "fill",
            platform.x,
            platform.y,
            platform.width,
            platform.height
        )
        end
    end


    --------------------------------
-- BOTÓN
--------------------------------

if button.pressed then

    love.graphics.setColor(
        0.2,
        1,
        0.2
    )

else

    love.graphics.setColor(
        1,
        0.3,
        0.3
    )

end

love.graphics.rectangle(
    "fill",
    button.x,
    button.y,
    button.width,
    button.height
)


--------------------------------
-- PUERTA
--------------------------------

if door.open then

    love.graphics.setColor(
        0.2,
        1,
        0.2,
        0.3
    )

else

    love.graphics.setColor(
        0.7,
        0.2,
        0.2
    )

end

love.graphics.rectangle(
    "fill",
    door.x,
    door.y,
    door.width,
    door.height
)


    --------------------------------
    -- META
    --------------------------------

    love.graphics.setColor(0.2, 1, 0.3)

    love.graphics.rectangle(
        "fill",
        goal.x,
        goal.y,
        goal.width,
        goal.height
    )


    --------------------------------
    -- FANTASMA
    --------------------------------

    if ghost then

        ghost:draw()

    end


    --------------------------------
    -- JUGADOR
    --------------------------------

    player:draw()


    --------------------------------
    -- INTERFAZ
    --------------------------------

    love.graphics.setColor(1, 1, 1)

    if gameState == "first_run" then

        love.graphics.print(
            "PRIMERA VUELTA - Llega a la meta",
            20,
            20
        )

    elseif gameState == "ghost_run" then

        love.graphics.print(
            "SEGUNDA VUELTA - Sigue a tu fantasma",
            20,
            20
        )

    elseif gameState == "completed" then
        love.graphics.print("¡Nivel completado! Pulsa R para reiniciar", 20, 20)
    end

    love.graphics.print(
        "A/D o flechas = mover | ESPACIO = saltar | R = reiniciar",
        20,
        50
    )

end


function love.keypressed(key)

    --------------------------------
    -- SALTO
    --------------------------------

    if gameState ~= "completed" and (key == "space" or key == "w" or key == "up") then

        player:jump()

    end


    --------------------------------
    -- REINICIAR
    --------------------------------

    if key == "r" then

        restartGame()

    end

end


function startGhostRun()

    --------------------------------
    -- CREAR FANTASMA
    --------------------------------

    local recording =
        recorder:getRecording()

    ghost =
        Ghost.new(recording)


    --------------------------------
    -- CAMBIAR ESTADO
    --------------------------------

    gameState =
        "ghost_run"


    --------------------------------
    -- REINICIAR JUGADOR
    --------------------------------

    player:reset(
        100,
        500
    )
    door.open = false
    updateDoor()

end


function restartGame()

    gameState =
        "first_run"

    ghost =
        nil

    recorder:reset()

    player:reset(
        100,
        500
    )
    recorder:update(0, player)
    door.open = false
    updateDoor()

end

function checkCollision(
    x1,
    y1,
    w1,
    h1,
    x2,
    y2,
    w2,
    h2
)

    return
        x1 < x2 + w2
        and
        x1 + w1 > x2
        and
        y1 < y2 + h2
        and
        y1 + h1 > y2

end