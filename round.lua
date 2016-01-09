ROUND = ROUND or {}
ROUND.make = false;
ROUND.nextMake = CurTime()
ROUND.money = 10 + (GAME.round*2)
function ROUND.start()
    --20 + math.pow(GAME.ROUND, 2)  HEALTH
    -- 10 + GAME.ROUND*2  MONEY
    
    ROUND.money = 10 + GAME.round
    
    GAME.round = GAME.round + 1
    hook.Call("OnRoundStart")
end

function ROUND.stop()
    hook.Call("OnRoundStop")
end

function ROUND.removeEnemy()
    ROUND.enemyDeaths = ROUND.enemyDeaths + 1
    
    if(ROUND.enemyDeaths >= ROUND.enemyCount)then
        ROUND.stop()
    end
end