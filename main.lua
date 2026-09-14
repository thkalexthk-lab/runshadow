local Player = require("src.player")
local Recorder = require("src.recorder")
local Ghost = require("src.ghost")

local player
local recorder
local ghost

local platforms
local goal
local button
local door

local gameState

local START_X = 100
local START_Y = 500


--------------------------------
-- COLISIÓN GENERAL
--------------------------------

local function checkCollision(
    x1, y1, w1, h1,
    x2, y2, w2, h2
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


--------------------------------
-- INICIAR SEGUNDA VUELTA
--------------------------------

local function startGhostRun()

    ghost = Ghost.new(
        recorder:getRecording()
    )

    gameState = "ghost_run"

    player:reset(
        START_X,
        START_Y
    )

end


--------------------------------
-- REINICIAR SEGUNDA VUELTA
--------------------------------

local function restartGhostRun()

    ghost = Ghost.new(
        recorder:getRecording()
    )

    player:reset(
        START_X,
        START_Y
    )

end


--------------------------------
-- REINICIAR TODO EL NIVEL
--------------------------------

local function restartGame()

    gameState = "first_run"

    ghost = nil

    recorder:reset()

    player:reset(
        START_X,
        START_Y
    )

    button.pressed = false
    door.open = true

end


--------------------------------
-- LOVE LOAD
--------------------------------

function love.load()

    love.window.setTitle(
        "Ghost Platformer"
    )

    love.window.setMode(
        1280,
        720,
        {
            resizable = false,
            vsync = true
        }
    )

    love.graphics.setDefaultFilter(
        "nearest",
        "nearest"
    )


    --------------------------------
    -- JUGADOR
    --------------------------------

    player = Player.new(
        START_X,
        START_Y
    )


    --------------------------------
    -- GRABADOR
    --------------------------------

    recorder = Recorder.new()


    --------------------------------
    -- ESTADO DEL JUEGO
    --------------------------------

    gameState = "first_run"


    --------------------------------
    -- PLATAFORMAS
    --------------------------------

    platforms = {

        -- Suelo
        {
            x = 0,
            y = 650,
            width = 1280,
            height = 70
        },

        -- Plataforma izquierda
        {
            x = 250,
            y = 540,
            width = 150,
            height = 30
        },

        -- Plataforma derecha
        {
            x = 900,
            y = 520,
            width = 150,
            height = 30
        }

    }


    --------------------------------
    -- BOTÓN
    --------------------------------

    button = {
        x = 500,
        y = 630,
        width = 80,
        height = 20,
        pressed = false
    }


    --------------------------------
    -- PUERTA
    --------------------------------

    door = {
        x = 750,
        y = 500,
        width = 50,
        height = 150,
        open = true
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


--------------------------------
-- LOVE UPDATE
--------------------------------

function love.update(dt)

    --------------------------------
    -- NIVEL COMPLETADO
    --------------------------------

    if gameState == "completed" then
        return
    end


    --------------------------------
    -- ACTUALIZAR JUGADOR
    --------------------------------

    player:update(
        dt,
        platforms
    )


    --------------------------------
    -- PRIMERA VUELTA
    --------------------------------

    if gameState == "first_run" then

        recorder:update(
            dt,
            player
        )

    end


    --------------------------------
    -- SEGUNDA VUELTA
    --------------------------------

    if gameState == "ghost_run" then

        if ghost then
            ghost:update(dt)
        end

    end


    --------------------------------
    -- BOTÓN
    --------------------------------

    button.pressed = false

    if gameState == "ghost_run" and ghost then

        if checkCollision(
            ghost.x,
            ghost.y,
            ghost.width,
            ghost.height,

            button.x,
            button.y,
            button.width,
            button.height
        ) then

            button.pressed = true

        end

    end


    --------------------------------
    -- PUERTA
    --------------------------------

    if gameState == "first_run" then

        -- Primera vuelta:
        -- puerta siempre abierta
        door.open = true

    elseif gameState == "ghost_run" then

        -- Segunda vuelta:
        -- solamente el fantasma
        -- puede abrirla
        door.open = button.pressed

    end


    --------------------------------
    -- COLISIÓN JUGADOR / PUERTA
    --------------------------------

    if not door.open then

        if player:collides(door) then

            if player.vx > 0 then

                player.x =
                    door.x - player.width

            elseif player.vx < 0 then

                player.x =
                    door.x + door.width

            end

        end

    end


    --------------------------------
    -- SI EL JUGADOR CAE
    --------------------------------

    if player.y > 900 then

        if gameState == "first_run" then

            -- Reiniciamos también
            -- la grabación
            recorder:reset()

            player:reset(
                START_X,
                START_Y
            )

        elseif gameState == "ghost_run" then

            -- Reinicia jugador y fantasma
            restartGhostRun()

        end

        return

    end


    --------------------------------
    -- META
    --------------------------------

    if player:collides(goal) then

        if gameState == "first_run" then

            startGhostRun()

        elseif gameState == "ghost_run" then

            gameState = "completed"

        end

    end

end


--------------------------------
-- LOVE DRAW
--------------------------------

function love.draw()

    --------------------------------
    -- FONDO
    --------------------------------

    love.graphics.clear(
        0.08,
        0.08,
        0.1
    )


    --------------------------------
    -- PLATAFORMAS
    --------------------------------

    love.graphics.setColor(
        0.4,
        0.4,
        0.4
    )

    for _, platform in ipairs(platforms) do

        love.graphics.rectangle(
            "fill",
            platform.x,
            platform.y,
            platform.width,
            platform.height
        )

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
            0.15
        )

    else

        love.graphics.setColor(
            0.8,
            0.2,
            0.2,
            1
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

    love.graphics.setColor(
        1,
        0.9,
        0.2
    )

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

    if gameState == "ghost_run" and ghost then

        ghost:draw()

    end


    --------------------------------
    -- JUGADOR
    --------------------------------

    player:draw()


    --------------------------------
    -- INTERFAZ
    --------------------------------

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )

    if gameState == "first_run" then

        love.graphics.print(
            "PRIMERA VUELTA - Llega a la meta",
            20,
            20
        )

    elseif gameState == "ghost_run" then

        love.graphics.print(
            "SEGUNDA VUELTA - Usa a tu fantasma",
            20,
            20
        )

    elseif gameState == "completed" then

        love.graphics.print(
            "¡NIVEL COMPLETADO!",
            20,
            20
        )

    end


    love.graphics.print(
        "A/D = mover | ESPACIO = saltar | R = reiniciar",
        20,
        50
    )


    --------------------------------
    -- INFORMACIÓN DE LA PUERTA
    --------------------------------

    if gameState == "ghost_run" then

        if door.open then

            love.graphics.print(
                "PUERTA: ABIERTA",
                20,
                80
            )

        else

            love.graphics.print(
                "PUERTA: CERRADA",
                20,
                80
            )

        end

    end

end


--------------------------------
-- TECLADO
--------------------------------

function love.keypressed(key)

    --------------------------------
    -- SALTO
    --------------------------------

    if gameState ~= "completed" then

        if
            key == "space"
            or key == "w"
            or key == "up"
        then

            player:jump()

        end

    end


    --------------------------------
    -- REINICIAR
    --------------------------------

    if key == "r" then

        restartGame()

    end

end