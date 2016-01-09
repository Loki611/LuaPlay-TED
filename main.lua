include("gameInfo.lua")
include("map.lua")
include("round.lua")

window.Create(GAME.width, GAME.height, "TEG")

hook.Add("OnLoad", function()
    MAP.create()
end)

local lastSpawn = 400
local speedINC = 1

hook.Add("Update", function(delta)
    delta = delta * speedINC
    if(GAME.paused)then
        delta = delta*0
    end
    
   if(ROUND.make and ROUND.nextMake < CurTime())then
        ROUND.start()
    end
   
   lastSpawn = lastSpawn + 1*(1+delta)
   
    if(ROUND.enemySpawned < ROUND.enemyCount and lastSpawn > 10/delta)then
        MAP.addEnemy()
    
        lastSpawn = 0
        ROUND.enemySpawned = ROUND.enemySpawned + 1
    end
    MAP.tick(delta)
end)

local wasLetGo = true
hook.Add("KeyDown", function(key)
    if(key == KEY_P)then
        if(wasLetGo)then
            if(GAME.paused)then
                print("Resumed")
                GAME.paused = false
            else
                GAME.paused = true
                print("Paused")
                hook.Call("OnPause")
            end
            wasLetGo = false
        end
    end

    if(key == KEY_RIGHT)then
        speedINC = speedINC + 0.01
    end
    
    if(key == KEY_LEFT)then
        speedINC = speedINC - 0.01
    end
end)

hook.Add("KeyUp", function(key)
    if(key == KEY_P)then
        wasLetGo = true
    end
end)

hook.Add("OnMouseClick", function(key)
    if(key == MOUSE_LEFT)then
        hook.Call("OnMouseLeft")
    end
    
    if(key == MOUSE_RIGHT)then
        hook.Call("OnMouseRight")
    end
end)
    
hook.Add("Render", function()
    hook.Call("HudRender")

    MAP.render()
end)

hook.Add("HudRender", function()
    if(TOWER.selected ~= nil)then
        graphics.DrawRect(TOWER.upgrade.x, TOWER.upgrade.y, TOWER.upgrade.w, TOWER.upgrade.h)
    end
end)

hook.Add("OnMouseLeft", function()
    local pos = input.MousePos()
    
    if(util.IsColliding(TOWER.upgrade.x, TOWER.upgrade.y, TOWER.upgrade.w, TOWER.upgrade.h, pos.x, pos.y, 1, 1))then
        TOWER.selected.levelUp()
    end
end)

hook.Add("OnRoundStart", function()
    ROUND.enemyCount = 20
    ROUND.enemySpawned = 0
    ROUND.enemyDeaths = 0
    ROUND.make = false
end)

hook.Add("OnRoundStop", function()
    ROUND.make = true
    ROUND.nextMake = CurTime() + 1000
    
    if(GAME.life <= 0)then
        GAME.paused = true
    end
    
end)

hook.Add("OnEnemyDeath", function()
    GAME.addMoney(ROUND.money)
    ROUND.removeEnemy()
end)

hook.Add("SilentDeath", function()
    ROUND.removeEnemy()
end)

hook.Add("OnMapCreated", function()
    GAME.money = 5454545445
    GAME.round = 0
    
    ROUND.start()
end)


