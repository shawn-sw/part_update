function love.load()
    love.window.setMode(800, 600)
    font = love.graphics.newFont(14)
    love.graphics.setFont(font)

    screenWidth, screenHeight = love.graphics.getDimensions()
    displayHeight = screenHeight * 2 / 3
    playerHeight = screenHeight / 3

    carArea = {x = 0, y = 0, w = screenWidth / 3, h = displayHeight}
    infoArea = {x = screenWidth / 3, y = 0, w = screenWidth * 2 / 3, h = displayHeight}
    controlArea = {x = 0, y = displayHeight, w = screenWidth, h = playerHeight}

    car = {
        speed = 100,
        handling = 100,
        durability = 100,
        stability = 100
    }
    carAscii = {
        "        _____",
        "  ___/____\\___",
        " /   _|____|_   \\",
        "|___|        |___|",
        " O            O"
    }

    deck = generateDeck()
    hand = {}
    infoLog = {}
    drawHand()
end

function generateDeck()
    local cards = {
        {"Speed +15", function(c) c.speed = c.speed + 15 end},
        {"Handling +15", function(c) c.handling = c.handling + 15 end},
        {"Durability +15", function(c) c.durability = c.durability + 15 end},
        {"Stability +15", function(c) c.stability = c.stability + 15 end},
        {"Speed +25 / Handling -5", function(c) c.speed = c.speed + 25; c.handling = c.handling - 5 end},
        {"Handling +25 / Durability -5", function(c) c.handling = c.handling + 25; c.durability = c.durability - 5 end},
        {"Durability +25 / Stability -5", function(c) c.durability = c.durability + 25; c.stability = c.stability - 5 end},
        {"Stability +25 / Speed -5", function(c) c.stability = c.stability + 25; c.speed = c.speed - 5 end},
        {"Speed +10 / Durability +10", function(c) c.speed = c.speed + 10; c.durability = c.durability + 10 end},
        {"Handling +10 / Stability +10", function(c) c.handling = c.handling + 10; c.stability = c.stability + 10 end}
    }

    local deck = {}
    for i = 1, 2 do
        for _, v in ipairs(cards) do
            table.insert(deck, {text = v[1], apply = v[2]})
        end
    end
    return deck
end

function drawHand()
    hand = {}
    for i = 1, 5 do
        if #deck == 0 then break end
        local index = math.random(#deck)
        table.insert(hand, table.remove(deck, index))
    end
end

function love.mousepressed(x, y, button)
    if y > controlArea.y + 50 and y < controlArea.y + 110 then
        for i = 1, #hand do
            local cardX = 20 + (i - 1) * 150
            if x > cardX and x < cardX + 120 then
                hand[i].apply(car)
                table.insert(infoLog, 1, "Played: " .. hand[i].text)
                table.remove(hand, i)
                break
            end
        end
    end

    if x > 150 and x < 250 and y > controlArea.y + 5 and y < controlArea.y + 35 then
        applyAccidents(#hand)
        drawHand()
    end
end

function applyAccidents(n)
    local penalties = {
        function(c) c.speed = c.speed - 30; return "Accident: Speed -30" end,
        function(c) c.handling = c.handling - 30; return "Accident: Handling -30" end,
        function(c) c.durability = c.durability - 30; return "Accident: Durability -30" end,
        function(c) c.stability = c.stability - 30; return "Accident: Stability -30" end,
    }
    for i = 1, n do
        local effect = penalties[math.random(4)]
        table.insert(infoLog, 1, effect(car))
    end
    hand = {}
end

function love.draw()
    love.graphics.rectangle("line", carArea.x, carArea.y, carArea.w, carArea.h)
    love.graphics.print("CAR", carArea.x + 10, carArea.y + 10)
    for i, line in ipairs(carAscii) do
        love.graphics.print(line, carArea.x + 10, carArea.y + 140 + i * 15)
    end
    love.graphics.print("Speed: " .. car.speed, carArea.x + 10, carArea.y + 40)
    love.graphics.print("Handling: " .. car.handling, carArea.x + 10, carArea.y + 60)
    love.graphics.print("Durability: " .. car.durability, carArea.x + 10, carArea.y + 80)
    love.graphics.print("Stability: " .. car.stability, carArea.x + 10, carArea.y + 100)

    love.graphics.rectangle("line", infoArea.x, infoArea.y, infoArea.w, infoArea.h)
    love.graphics.print("INFO LOG", infoArea.x + 10, infoArea.y + 10)
    for i = 1, math.min(10, #infoLog) do
        love.graphics.print(infoLog[i], infoArea.x + 10, infoArea.y + 20 + i * 20)
    end

    love.graphics.rectangle("line", controlArea.x, controlArea.y, controlArea.w, controlArea.h)
    love.graphics.print("Cards Left: " .. #deck, controlArea.x + 10, controlArea.y + 10)
    love.graphics.rectangle("line", 150, controlArea.y + 5, 100, 30)
    love.graphics.print("End Turn", 160, controlArea.y + 10)

    for i = 1, #hand do
        local cardX = 20 + (i - 1) * 150
        local cardY = controlArea.y + 50
        love.graphics.rectangle("line", cardX, cardY, 120, 60)
        love.graphics.print(hand[i].text, cardX + 10, cardY + 25)
    end
end
