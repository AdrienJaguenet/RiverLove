settings = {
	ITEM_SPEED = 200,
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
	return {
		x = math.random(settings.MIN_SPAWN_X, settings.MAX_SPAWN_X),
		y = 0,
	}
end

function drawItem(item)
	love.graphics.circle('fill', item.x, item.y, 10)
end

function love.load()
	items = {}
	settings.MIN_SPAWN_X = love.graphics.getWidth() / 10
	settings.MAX_SPAWN_X = 9 * love.graphics.getWidth() / 10
	settings.DESPAWN_Y = 11 * love.graphics.getHeight() / 10
end

function love.update(dt)
	if math.random(0, 10) == 0 then
		table.insert(items, newItem())
	end

	for k, v in pairs(items) do
		v.y = v.y + settings.ITEM_SPEED * dt
	end

	filter_inplace(items, function(item) return item.y < settings.DESPAWN_Y end)
end

function love.draw()
	love.graphics.print("Items in game: "..#items)
	for k, v in pairs(items) do
		drawItem(v)
	end
end

