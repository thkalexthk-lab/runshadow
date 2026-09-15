local Player = require("src.player")
local Recorder = require("src.recorder")
local Ghost = require("src.ghost")


--------------------------------
-- NIVELES
--------------------------------

local levels = {
    require("levels.level1"),
    (require("levels.level2"))
}

local currentLevel = 1
local level


--------------------------------
-- OBJETOS DEL JUEGO
--------------------------------

local player
local recorder
local ghost

local platforms
local button
local door
local goal

local gameState


--------------------------------
-- TRANSICIÓN
--------------------------------

local transitionTimer = 0
local transitionDuration = 3


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
-- CARGAR NIVEL
--------------------------------

local function loadLevel(levelNumber)

    currentLevel = levelNumber

    level = levels[currentLevel]()

    platforms = level.platforms
    button = level.button
    door = level.door
    goal = level.goal

    ghost = nil

    recorder:reset()

    player:reset(
        level.startX,
        level.startY
    )

    recorder:update(0, player)
    button.pressed = false
    door.open = true

    gameState = "first_run"

    transitionTimer = 0

end


--------------------------------
-- INICIAR TRANSICIÓN
--------------------------------

local function startTransition()

    gameState = "transition"

    transitionTimer =
        transitionDuration

    player.vx = 0
    player.vy = 0

end


--------------------------------
-- INICIAR SEGUNDA VUELTA
--------------------------------

local function startGhostRun()

    ghost = Ghost.new(
        recorder:getRecording()
    )

    button.pressed = false
    door.open = false

    gameState = "ghost_run"

    player:reset(
        level.startX,
        level.startY
    )

end


--------------------------------
-- REINICIAR SEGUNDA VUELTA
--------------------------------

local function restartGhostRun()

    button.pressed = false
    door.open = false

    ghost = Ghost.new(
        recorder:getRecording()
    )

    player:reset(
        level.startX,
        level.startY
    )

end


--------------------------------
-- REINICIAR NIVEL
--------------------------------

local function restartLevel()

    loadLevel(currentLevel)

end


--------------------------------
-- SIGUIENTE NIVEL
--------------------------------

local function nextLevel()

    if currentLevel < #levels then

        loadLevel(
            currentLevel + 1
        )

    else

        gameState =
            "game_complete"

    end

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
        100,
        500
    )


    --------------------------------
    -- GRABADOR
    --------------------------------

    recorder =
        Recorder.new()


    --------------------------------
    -- PRIMER NIVEL
    --------------------------------

    loadLevel(1)

end


--------------------------------
-- LOVE UPDATE
--------------------------------

function love.update(dt)

    dt = math.min(math.max(dt, 0), 0.25)

    --------------------------------
    -- JUEGO TERMINADO
    --------------------------------

    if gameState == "game_complete" then
        return
    end


    --------------------------------
    -- TRANSICIÓN
    --------------------------------

    if gameState == "transition" then

        transitionTimer =
            transitionTimer - dt

        if transitionTimer <= 0 then

            startGhostRun()

        end

        return

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

        door.open = true

    elseif gameState == "ghost_run" then

        door.open =
            button.pressed

    end


    -- Esperar a que el jugador salga antes de cerrar la puerta.
    if not door.open and player:collides(door) then
        door.open = true
    end

    local solids = platforms
    if not door.open then
        solids = {}
        for i, platform in ipairs(platforms) do
            solids[i] = platform
        end
        solids[#solids + 1] = door
    end
    player:update(dt, solids)

    if gameState == "first_run" then
        recorder:update(dt, player)
    end

    --------------------------------
    -- CAÍDA DEL MAPA
    --------------------------------

    if player.y > 900 then

        if gameState == "first_run" then

            recorder:reset()

            player:reset(
                level.startX,
                level.startY
            )

            recorder:update(0, player)

        elseif gameState == "ghost_run" then

            restartGhostRun()

        end

        return

    end


    --------------------------------
    -- META
    --------------------------------

    if player:collides(goal) then

        --------------------------------
        -- TERMINA PRIMERA VUELTA
        --------------------------------

        if gameState == "first_run" then

            startTransition()


        --------------------------------
        -- TERMINA SEGUNDA VUELTA
        --------------------------------

        elseif gameState == "ghost_run" then

            nextLevel()

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

    if gameState ~= "transition" then

        player:draw()

    end


    --------------------------------
    -- INTERFAZ
    --------------------------------

    love.graphics.setColor(
        1,
        1,
        1,
        1
    )


    --------------------------------
    -- NOMBRE DEL NIVEL
    --------------------------------

    if gameState ~= "game_complete" then

        love.graphics.print(
            level.name,
            20,
            20
        )

    end


    --------------------------------
    -- PRIMERA VUELTA
    --------------------------------

    if gameState == "first_run" then

        love.graphics.print(
            "PRIMERA VUELTA - Llega a la meta",
            20,
            50
        )


    --------------------------------
    -- SEGUNDA VUELTA
    --------------------------------

    elseif gameState == "ghost_run" then

        love.graphics.print(
            "SEGUNDA VUELTA - Usa a tu fantasma",
            20,
            50
        )


    --------------------------------
    -- TRANSICIÓN
    --------------------------------

    elseif gameState == "transition" then

        --------------------------------
        -- OSCURECER PANTALLA
        --------------------------------

        love.graphics.setColor(
            0,
            0,
            0,
            0.80
        )

        love.graphics.rectangle(
            "fill",
            0,
            0,
            1280,
            720
        )


        --------------------------------
        -- TEXTO
        --------------------------------

        love.graphics.setColor(
            1,
            1,
            1,
            1
        )

        love.graphics.printf(
            "PRIMERA VUELTA COMPLETADA",
            0,
            270,
            1280,
            "center"
        )


        --------------------------------
        -- CUENTA REGRESIVA
        --------------------------------

        local countdown =
            math.ceil(
                transitionTimer
            )

        love.graphics.printf(
            tostring(countdown),
            0,
            320,
            1280,
            "center"
        )


        love.graphics.printf(
            "REPETICIÓN 01",
            0,
            380,
            1280,
            "center"
        )


    --------------------------------
    -- JUEGO COMPLETO
    --------------------------------

    elseif gameState == "game_complete" then

        love.graphics.printf(
            "¡HAS COMPLETADO TODOS LOS NIVELES!",
            0,
            300,
            1280,
            "center"
        )

        love.graphics.printf(
            "Presiona R para volver al Nivel 1",
            0,
            340,
            1280,
            "center"
        )

    end


    --------------------------------
    -- CONTROLES
    --------------------------------

    if
        gameState ~= "game_complete"
        and
        gameState ~= "transition"
    then

        love.graphics.print(
            "A/D = mover | ESPACIO = saltar | R = reiniciar nivel",
            20,
            80
        )

    end


    --------------------------------
    -- ESTADO DE PUERTA
    --------------------------------

    if gameState == "ghost_run" then

        if door.open then

            love.graphics.print(
                "PUERTA: ABIERTA",
                20,
                110
            )

        else

            love.graphics.print(
                "PUERTA: CERRADA",
                20,
                110
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

    if
        gameState ~= "game_complete"
        and
        gameState ~= "transition"
    then

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

        if gameState == "game_complete" then

            loadLevel(1)

        else

            restartLevel()

        end

    end

end