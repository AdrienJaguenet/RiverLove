settings = {
	ITEM_SPEED = 100,
}

inventory = {
	gold = 0,
	gems = 0
}

function filter_inplace(arr, func)
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do arr[i] = nil end
end

function newItem()
	local ni = {
		x = math.random(settings.MIN_SPAWN_X, settings.MAX_SPAWN_X),
		y = -32,
		w = settings.ITEM_RADIUS,
		h = settings.ITEM_RADIUS,
		gfx = gfx.items.steel_crate
	}
	local t = math.random(1, 2)
	if t == 1 then
		ni.prize = {
			gold = math.random(3,7) * 5,
		}
		ni.gfx = gfx.items.wooden_crate
		ni.particle = gfx.particles.wooden_crate
	elseif t == 2 then
		ni.prize = {
			gold = math.random(4,8) * 5,
			gems = math.random(1,3) * math.random(1,3)
		}
		ni.gfx = gfx.items.steel_crate
		ni.particle = gfx.particles.steel_crate
	end
	ni.w = ni.gfx:getWidth()
	ni.h = ni.gfx:getHeight()
	return ni
end

function newParticle(x, y, gfx)
	local np = {
		x = x,
		y = y,
		w = 8,
		h = 8,
		gfx = gfx,
		velocity_y = -math.random(100),
		velocity_x = math.random(-100, 100),
	}
	return np
end

function drawItem(item)
	love.graphics.draw(item.gfx, item.x, item.y)
end

function drawParticle(particle)
	love.graphics.draw(particle.gfx, particle.x, particle.y)
end

function drawBackground()
	love.graphics.draw(gfx.background)
end

function drawInventory()
	str = ""
	for k, v in pairs(inventory) do
		str = str..k..": "..v.."\n"
	end
	love.graphics.print(str, 0, 40)
end

function love.load()
	love.window.setMode(640, 480)
	items = {}
	particles = {}
	settings.MIN_SPAWN_X = love.graphics.getWidth() / 10
	settings.MAX_SPAWN_X = 9 * love.graphics.getWidth() / 10
	settings.DESPAWN_Y = 11 * love.graphics.getHeight() / 10
	gfx = {
		items = {
			wooden_crate = love.graphics.newImage('resources/crate-1.png'),
			steel_crate = love.graphics.newImage('resources/crate-2.png')
		},
		background = love.graphics.newImage('resources/background.png'),
		fonts = {
			ui = love.graphics.newFont('resources/fonts/BradBunR.ttf', 24)
		},
		particles = {
			wooden_crate = love.graphics.newImage('resources/particle-crate.png'),
			wooden_crate_2 = love.graphics.newImage('resources/particle-crate-2.png'),
			gold = love.graphics.newImage('resources/particle-coin.png'),
			gem = love.graphics.newImage('resources/particle-gem.png')
		},
	}
	sfx = {
		item_open = {
			love.audio.newSource('resources/open.wav', 'static'),
			love.audio.newSource('resources/open-2.wav', 'static')
		},
		music = love.audio.newSource('resources/music.wav', 'stream')
	}
	sfx.music:setVolume(0.3)
	sfx.music:setLooping(true)
	sfx.music:play()
end

function love.update(dt)
	if math.random(0, 10) == 0 then
		table.insert(items, newItem())
	end

	for k, v in pairs(items) do
		v.y = v.y + settings.ITEM_SPEED * dt
	end
	for k, v in pairs(particles) do
		v.velocity_y = v.velocity_y + 200 * dt
		v.x = v.x + v.velocity_x * dt
		v.y = v.y + v.velocity_y * dt
	end

	filter_inplace(items, function(item) return item.y < settings.DESPAWN_Y end)
	filter_inplace(particles, function(particle) return particle.y < settings.DESPAWN_Y end)

end

function love.draw()
	drawBackground()
	love.graphics.setFont(gfx.fonts.ui)
	love.graphics.print("Items in game: "..#items)
	for k, v in pairs(items) do
		drawItem(v)
	end
	for k, v in pairs(particles) do
		drawParticle(v)
	end
	drawInventory()
end

function collectItem(k, item)
	sfx.item_open[math.random(#sfx.item_open)]:play()

	-- Particles.
	table.insert(particles, newParticle(item.x, item.y, gfx.particles.wooden_crate))
	table.insert(particles, newParticle(item.x, item.y, gfx.particles.wooden_crate))
	table.insert(particles, newParticle(item.x, item.y, gfx.particles.wooden_crate_2))
	table.insert(particles, newParticle(item.x, item.y, gfx.particles.wooden_crate_2))
	
	for res, qty in pairs(item.prize) do
		inventory[res] = inventory[res] + qty
		print('Gained '..qty..' '..res..'!')

		if res == "gems" then
			table.insert(particles, newParticle(item.x, item.y, gfx.particles.gem))
		end

		if res == "gold" then
			table.insert(particles, newParticle(item.x, item.y, gfx.particles.gold))
		end
	end
	table.remove(items, k)
end

function love.mousepressed(x, y, k)
	if k == 1 then
		for k, v in pairs(items) do
			if x > v.x and x < v.x + v.w and y > v.y and y < v.y + v.h then
				collectItem(k, v)
			end
		end
	end
end

