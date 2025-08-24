--[[
	Angeryy05 Signal Library
	Modern signal system for Angeryy05 UI Library
]]

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {}
	}, Signal)
end

function Signal:Connect(callback)
	assert(typeof(callback) == "function", "Callback must be a function")
	
	local connection = {
		Connected = true,
		_callback = callback,
		_signal = self
	}
	
	function connection:Disconnect()
		if self.Connected then
			self.Connected = false
			local index = table.find(self._signal._connections, self)
			if index then
				table.remove(self._signal._connections, index)
			end
		end
	end
	
	table.insert(self._connections, connection)
	return connection
end

function Signal:Fire(...)
	local connections = table.clone(self._connections)
	for _, connection in ipairs(connections) do
		if connection.Connected then
			task.spawn(connection._callback, ...)
		end
	end
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

function Signal:DisconnectAll()
	for _, connection in ipairs(self._connections) do
		connection.Connected = false
	end
	table.clear(self._connections)
end

return Signal
