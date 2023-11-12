--[[
	Tables for Markov chains 
]]
local nodes = {}
nodes[1] = {
	[0.5] = {[0.5] = 0.5, [1] = 0.1, [12] = 0.2, [7] = 0.1, [64] = 0.1},
	[1] = {[1] = 0.4, [2] = 0.2, [7] = 0.2, [0.5] = 0.2 },
	[2] = {[2] = 0.3, [3] = 0.2, [1] = 0.4, [64] = 0.1}, 
	[3] = {[2] = 0.5, [3] = 0.5},
	[7] = {[2] = 0.3, [12] = 0.4, [3] = 0.2, [7] = 0.1},
	[12] = {[0.5] = 0.7, [3] = 0.05, [7] = 0.05, [64] = 0.1, [12] = 0.1},
	[64] = {[0.5] = 0.3, [2] = 0.3, [1] = 0.1, [64] = 0.1, [12] = 0.2}, 
}

nodes[2] = {
	[1] = {[1] = 0.98, [2] = 0.02},
	[2] = {[1] = 0.98, [2] = 0.02},
}

nodes[3] = {
	[1] = {[1] = 0.99, [2] = 0.01},
	[2] = {[1] = 0.99, [2] = 0.01},
}

nodes[4] = {
	[1] = {[1] = 0.1, [2] = 0.2, [3] = 0.3, [4] = 0.4},
	[2] = {[1] = 0.2, [2] = 0.1, [3] = 0.4, [4] = 0.3},
	[3] = {[1] = 0.3, [2] = 0.4, [3] = 0.1, [4] = 0.2},
	[4] = {[1] = 0.4, [2] = 0.3, [3] = 0.2, [4] = 0.1}
}

-- Main markov for main scheduler
nodes[7] = {
	[1] = {[1] = 0.2, [2] = 0.4, [3] = 0.3, [4] = 0.1},
	[2] = {[1] = 0.2, [2] = 0.1, [3] = 0.4, [4] = 0.3},
	[3] = {[1] = 0.3, [2] = 0.1, [3] = 0.2, [4] = 0.4},
	[4] = {[1] = 0.25, [2] = 0.25, [3] = 0.25, [4] = 0.25}
}

nodes[101] = {
	[1] = {[1] = 0.90, [2] = 0.02, [3] = 0.08},
	[2] = {[1] = 0.96, [2] = 0.02, [3] = 0.02},
	[3] = {[1] = 0.96, [2] = 0.02, [3] = 0.02},
}

nodes[102] = {
	[1] = {[1] = 0.70, [2] = 0.1, [3] = 0.2},
	[2] = {[1] = 0.8, [2] = 0.1, [3] = 0.1},
	[3] = {[1] = 0.7, [2] = 0.2, [3] = 0.1},
}

nodes[201] = {
	[1] = {[1] = 0.95, [2] = 0.05},
	[2] = {[1] = 0.2, [2] = 0.8}
}

nodes[202] = {
	[1] = {[1] = 0.7, [2] = 0.3},
	[2] = {[1] = 1, [2] = 0}
}

nodes[203] = {
	[1] = {[1] = 0.9, [2] = 0.1}, 
	[2] = {[1] = 1, [2] = 0}
}

nodes[204] = {
	[1] = {[1] = 0.50, [2] = 0.25, [3] = 0.25},
	[2] = {[1] = 0.25, [2] = 0.5, [3] = 0.25},
	[3] = {[1] = 0.25, [2] = 0.25, [3] = 0.5},
}

nodes[205] = {
	[1] = {[1] = 0.9, [2] = 0.1},
	[2] = {[1] = 0.7, [2] = 0.3}
}

nodes[301] = {
	[1] = {[1] = 0.90, [2] = 0.02, [3] = 0.08},
	[2] = {[1] = 0.96, [2] = 0.02, [3] = 0.02},
	[3] = {[1] = 0.96, [2] = 0.02, [3] = 0.02},
}

nodes[302] = {
	[1] = {[1] = 0.33, [2] = 0.33, [3] = 0.33},
	[2] = {[1] = 0.33, [2] = 0.33, [3] = 0.33},
	[3] = {[1] = 0.33, [2] = 0.33, [3] = 0.33}
}

nodes[303] = {
	[1] = {[1] = 0.98, [2] = 0.02},
	[2] = {[1] = 1, [2] = 0}
}

nodes[304] =  {
	[1] = {[1] = 0.5, [2] = 0.5},
	[2] = {[1] = 0.5, [2] = 0.5}
}

nodes[305] = {
	[1] = {[1] = 0.7, [2] = 0.15, [3] = 0.15},
	[2] = {[1] = 0.7, [2] = 0.15, [3] = 0.15},
	[3] = {[1] = 0.7, [2] = 0.15, [3] = 0.15}
}


function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
	Markov Class
]]
markov = {} -- first create an empty table
function markov:new(o) -- base constructor for lua classes
	o=o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function markov:scale()
	for k,v in pairs(self.nodes) do
		local cnt = 0
		for k2, v2 in pairs(v) do
			cnt = cnt + v2
		end
		if(v2 ~= 1) then
			-- rescale
			local factor = (1 + (1 - cnt));
			for k2, v2 in pairs(v) do
				v[k2] = v2 * factor
			end
		end
	end
end

function markov:init(node, first_value) 
	self.nodes = deepcopy(nodes[node])
	self.current = first_value
	math.randomseed(os.time())
	self:scale()
end


function markov:kperf(trig)
	if(trig == 0) then return self.current end
	local rnd = math.random()
	local cnt = 0
	for k, v in pairs(self.nodes[self.current]) do
		if(rnd > cnt and rnd < (cnt + v) ) then
			self.current = k
			break
		end
		cnt = cnt + v
	end
	return self.current
end

--[[
	Utility functions called from Csound
]]

function osciltype(kval)
	if(kval == 1) then 
		return "p1_oscil"
	elseif(kval == 2) then 
		return "p1_oscil_nofilter"
	elseif(kval == 3) then 
		return "p1_oscil_svf"
	end	
	return "p1_oscil"
end

function scramble(index, trig)
	if(trig ~= 0) then 
		local t = {
			[1] = nodes[#nodes[index]]
		}
		for k,v in pairs(nodes[index]) do 
			t[k] = v
		end


	end
end
