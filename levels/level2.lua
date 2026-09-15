local function createLevel()

    return {

        name = "Nivel 2",

        startX = 80,
        startY = 500,

        platforms = {

            -- Suelo
            {
                x = 0,
                y = 650,
                width = 1280,
                height = 70
            },

            {
                x = 200,
                y = 550,
                width = 150,
                height = 30
            },

            {
                x = 420,
                y = 470,
                width = 160,
                height = 30
            },

            {
                x = 650,
                y = 390,
                width = 160,
                height = 30
            },

            {
                x = 900,
                y = 500,
                width = 180,
                height = 30
            }

        },

        button = {
            x = 350,
            y = 630,
            width = 80,
            height = 20,
            pressed = false
        },

        door = {
            x = 850,
            y = 500,
            width = 50,
            height = 150,
            open = true
        },

        goal = {
            x = 1180,
            y = 570,
            width = 50,
            height = 80
        }

    }

end

return createLevel