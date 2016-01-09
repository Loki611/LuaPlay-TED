include("bullet.lua")

TOWER = {}
TOWER.SNIPER = 1
TOWER.BOMB = 2
TOWER.GATTLING = 3

TOWER.selected = nil
TOWER.upgrade = Rect(1, GAME.height - 40, 42, 38)

TOWER.make = function(id, tab)
    if(id == TOWER.SNIPER)then
        tab.name = "PTower"
        tab.rate = 10 -- Seconds
        tab.damge = 7
        tab.cost = 150
        tab.peirce = true
        tab.pierceCount = 6
        tab.range = 200
        tab.color = Color(0, 150, 150)
    elseif(id == TOWER.BOMB)then
        tab.name = "Bomb Tower"
        tab.rate = 45 -- Seconds
        tab.damge = 30
        tab.blastRadius = 3
        tab.cost = 175
        tab.peirce = false
        tab.range = 150
        tab.color = Color(255, 0, 0)
    elseif(id == TOWER.GATTLING)then
        tab.name = "Gattling Tower"
        tab.rate = 3.3 -- Seconds
        tab.damge = 15
        tab.peirce = false
        tab.cost = 125
        tab.range = 125
        tab.color = Color(0, 255, 0)
    else
        return
    end
    
    tab.showRadius = false
    tab.pos = Vector(0, 0)
    tab.size = Size(35, 35)
    tab.bullets = {}
    tab.nextShoot = 0
    tab.level = 1
    
    function tab.getCenter()
        return Vector(tab.pos.x + (tab.size.w/2), tab.pos.y + (tab.size.h/2))
    end
    
    tab.render = function()
        if(tab.showRadius)then
            graphics.DrawCircle(tab.getCenter().x, tab.getCenter().y, tab.range, Color(255, 255, 255), true)
        end
        graphics.DrawRect(tab.pos.x, tab.pos.y, tab.size.w, tab.size.h, tab.color or Color(255, 255, 255))
        
        for i =1, #tab.bullets do
            tab.bullets[i].render()
        end
    end
    
    tab.shoot = function(x, y)
        local bullet = {};
        BULLET.make("base", bullet)
        
        bullet.pos.x = tab.getCenter().x - bullet.size.w/2
        bullet.pos.y = tab.getCenter().y - bullet.size.h/2
        local t = y - bullet.pos.y
        local t2 = x - bullet.pos.x
        
        bullet.angle = math.atan2(t, t2) * 180 / math.pi
        table.insert(tab.bullets, bullet)
    end
    
    tab.tick = function(delta)
        for i =1, #tab.bullets do
            tab.bullets[i].tick(delta)
        end
        
        tab.nextShoot = tab.nextShoot + 1 *(1+delta)
        
        if(tab.nextShoot > tab.rate/delta+1)then
            tab.targetEnt = MAP.getClosestEnemy(tab.pos.x, tab.pos.y, tab.range)
            if(tab.targetEnt ~= nil)then
                tab.shoot(tab.targetEnt.pos.x, tab.targetEnt.pos.y)
                
                tab.nextShoot = 0
            end
            
        end
        
        local pos = input.MousePos()
        
        if(util.IsColliding(pos.x, pos.y, 1, 1, tab.pos.x, tab.pos.y, tab.size.w, tab.size.h))then
            tab.showRadius = true
        
            if(input.MouseDown(MOUSE_LEFT))then
                TOWER.selected = tab
            end
        else
            tab.showRadius = false
        end
    end
    
    function tab.levelUp()
        tab.level = tab.level + 1
        TOWER.selected = nil
        
        tab.color.r = tab.color.r + 50
        tab.color.g = tab.color.g + 50
        tab.color.b = tab.color.b + 50
    end
end