GAME = GAME or {}
GAME.money = 500 -- Starting amount
GAME.round = 0
GAME.life = 50
GAME.width = 800
GAME.height = 800
GAME.paused = false
GAME.speedMod = 1

function GAME.takeMoney(amount)
    GAME.money = GAME.money - amount
    print("Subtracted money: "..amount)
    hook.Call("OnTakeMoney", GAME.money)
end

function GAME.addMoney(amount)
    GAME.money = GAME.money + amount
    print("Added money: "..amount)
    print("Current Money "..GAME.money)
    hook.Call("OnAddMoney", GAME.money)
end