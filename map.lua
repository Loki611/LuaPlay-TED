include("enemy.lua")
include("tower.lua")
include("round.lua")
include("gameInfo.lua")

MAP = MAP or {}

MAP.wasCreated = false
MAP.tiles = {}
MAP.mapPlaces = {}
MAP.enemies = {}
MAP.towers = {}
MAP.width = 0
MAP.selectedTower = nil

MAP.design = [[
00010000000000002
00100000000000002
00100000000000002
00100000000000002
00100000000000002
00100000000000002
00111111111100002
00000000000100002
00000000000100002
00000000000100002
00000000000100002
00000000000100002
00000000000100002]]

MAP.create = function()
    if(not wasCreated)then
        local x = 0
        local y = 0
        
        for i=1, string.len(MAP.design) do
            local char = string.char(string.byte(MAP.design, i));
            
            if(char == "1")then
                table.insert(MAP.tiles, {id=i, x=x, y=y})
            elseif(char == "2")then
                if(MAP.width == 0)then
                    MAP.width = 16
                end
               
                y = y + 50
                x = -50
            else
                table.insert(MAP.mapPlaces, {id=i, x=x, y=y})
            end
            
            x = x + 50
        end
        wasCreated = true
        
        hook.Call("OnMapCreated")
    end
end

function MAP.addEnemy()
    local tab = {}
    ENEMY.make(tab)
    tab.health = 20 + math.pow(GAME.round, 2)
    tab.maxHealth = tab.health
    
    table.insert(MAP.enemies, tab)
    MAP.enemies[#MAP.enemies].pos.x = MAP.tiles[1].x + 12
    MAP.enemies[#MAP.enemies].pos.y = -2
end

function MAP.addTower(x)
    local tab = {}
    TOWER.make(MAP.selectedTower, tab)
    
    if(GAME.money - tab.cost >= 0)then
        tab.pos.x = MAP.getMapTile(x).x + (25 - tab.size.w/2)
        tab.pos.y = MAP.getMapTile(x).y + (25 - tab.size.h/2)
        MAP.getMapTile(x).hasItem = true
        MAP.getMapTile(x).itemHeld = tab
        tab.tileID = x
        GAME.takeMoney(tab.cost)
        table.insert(MAP.towers, tab)
        print("Added: "..tab.name)
        
        MAP.selectedTower = nil
    end
end

function MAP.removeTower(x)
    MAP.getMapTile(MAP.towers[x].tileID).hasItem = false
    table.remove(MAP.towers, x)
end

function MAP.getNext(cur)
    local tile = MAP.tiles[cur + 1]
    return tile
end

function MAP.getMapTile(x)
    local tile = MAP.mapPlaces[x]
    return tile
end

function MAP.getTile(id)
    local tile = MAP.tiles[id]
    return tile
end

function MAP.maxTile()
    return #MAP.tiles
end

function MAP.render()
    for i=1, #MAP.tiles do
        local tile = MAP.tiles[i]
        if(i == MAP.maxTile())then
            graphics.DrawRect(tile.x, tile.y, 50, 50, Color(100, 100, 100))
        else
            graphics.DrawRect(tile.x, tile.y, 50, 50)
        end
    end
    
    for x=1, #MAP.enemies do
        local ene = MAP.enemies[x]
        ene.render()
    end
    
    for t=1, #MAP.towers do
        local tab = MAP.towers[t]
        tab.render()
    end
end

function MAP.getEnemies(x, y, rad)
    local gotEnts = {}
    for i = 1, #MAP.enemies do
        local enemy = MAP.enemies[i];
        local distance = math.sqrt(math.pow(y - enemy.pos.y, 2) + math.pow(x - enemy.pos.x, 2))
        
        if(distance < rad)then
            table.insert(gotEnts, enemy)
        end
    end
    return gotEnts;
end

function MAP.getClosestEnemy(x, y, rad)
    return MAP.getEnemies(x, y, rad)[1];
end

function MAP.tick(delta)
    for i=1, #MAP.towers do
        local tow = MAP.towers[i]
        tow.tick(delta)
        
        for bC = 1, #tow.bullets do
            local b = tow.bullets[bC]
            for k, e in pairs(MAP.enemies) do
                if(util.IsColliding(e.pos.x, e.pos.y, e.size.w, e.size.h, b.pos.x, b.pos.y, b.size.w, b.size.h))then
                    if(not tow.peirce)then
                        table.remove(tow.bullets, bC)
                    else
                        tow.bullets[bC].hitTest = (tow.bullets[bC].hitTest or 0) + 1
                        if(tow.bullets[bC].hitTest >= tow.pierceCount)then
                            table.remove(tow.bullets, bC)
                        end
                    end
                    
                    if(tow.name == "Bomb Tower")then
                        for eneID, ent in pairs(MAP.getEnemies(b.pos.x, b.pos.y, 100)) do
                           if(e ~= ent)then
                                ent.takeDamage(tow.damge/2)
                            end
                        end
                    end
                    
                    e.takeDamage(tow.damge)
                end
            end
        end
    end
    
    for i=1, #MAP.enemies do
        local ene = MAP.enemies[i]
        ene.tick(delta)
        
         if(ene.curTile == MAP.maxTile())then
            GAME.life = GAME.life - 1
            ene.killSilent()
            
            print("Current life: "..GAME.life)
         end
    end
end

hook.Add("KeyDown", function(key)
    local towerID = ""
    if(key == KEY_1)then
        MAP.selectedTower = TOWER.SNIPER
        towerID = "Pirce Tower"
    elseif(key == KEY_2)then
        MAP.selectedTower = TOWER.BOMB
        towerID = "Bomb Tower"
    elseif(key == KEY_3)then
        MAP.selectedTower = TOWER.GATTLING
        towerID = "Gattling Tower"
    end
    if(towerID ~= "")then
        print("Selected tower: "..towerID)
    end
end)

hook.Add("OnMouseLeft", function()
    local pos = input.MousePos()
    for i, p in pairs(MAP.mapPlaces)do
        if(not p.hasItem)then
            if(util.IsColliding(pos.x, pos.y, 1, 1, p.x, p.y, 50, 50))then
                MAP.addTower(i)
            end
        end
    end
end)

hook.Add("OnMouseRight", function()
    local pos = input.MousePos()
    for i, tower in pairs(MAP.towers)do
        if(util.IsColliding(pos.x, pos.y, 1, 1, tower.pos.x, tower.pos.y, 50, 50))then
            GAME.addMoney(tower.cost)
            MAP.removeTower(i)
        end
    end
end)

local function killEnemy(id)
    for i, e in pairs(MAP.enemies) do
        if(e.id == id)then
            table.remove(MAP.enemies, i)
        end
    end
end

hook.Add("OnEnemyDeath", function(id)
    killEnemy(id)
end)

hook.Add("SilentDeath", function(id)
    killEnemy(id)
end)

hook.Add("OnRoundStop", function()
    for t=1, #MAP.enemies do
        table.remove(MAP.enemies, t)
    end
    
    for x=1, #MAP.towers do
        MAP.towers[x].bullets = {}
    end
    
    print("ROUND: "..GAME.round)
end)