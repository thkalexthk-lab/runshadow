local function createLevel()

    return {

        name = "Nivel 1 - Tu pasado",

        startX = 80,
        startY = 500,

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

            -- Plataforma introductoria
            {
                x = 250,
                y = 540,
                width = 150,
                height = 30
            },

            -- Plataforma después de la puerta
            {
                x = 850,
                y = 520,
                width = 180,
                height = 30
            }

        },

        --------------------------------
        -- BOTÓN
        --------------------------------

        button = {
            x = 430,
            y = 630,

            -- Lo hacemos grande para que
            -- el tutorial sea más fácil.
            width = 200,
            height = 20,

            pressed = false
        },

        --------------------------------
        -- PUERTA
        --------------------------------

        door = {
            x = 720,
            y = 500,

            width = 50,
            height = 150,

            open = true
        },

        --------------------------------
        -- META
        --------------------------------

        goal = {
            x = 1160,
            y = 570,

            width = 50,
            height = 80
        }

    }

end

return createLevel