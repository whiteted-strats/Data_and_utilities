Debugger = {}
Debugger.statistics = {}

function Debugger.on_event(_event)
	local function_name = debug.getinfo(2).name
	
	if not function_name then
		return
	end
	
	if (function_name == "sethook") or 
		(function_name == "start_profiling") or
		(function_name == "stop_profiling") then
		return
	end
	
	if not Debugger.statistics[function_name] then
		local statistics = {}
		
		statistics.call_count = 0
		statistics.call_time = 0.0
		statistics.total_execution_time = 0.0
		
		Debugger.statistics[function_name] = statistics
	end
	
	local statistics = Debugger.statistics[function_name]
	
	if (_event == "call") then
		statistics.call_time = os.clock()
	elseif (_event == "return") then
		local execution_time = (os.clock() - statistics.call_time)
	
		statistics.call_count = (statistics.call_count + 1)
		statistics.total_execution_time = (statistics.total_execution_time + execution_time)
	end
end

function Debugger.start_profiling()
	debug.sethook(Debugger.on_event, "cr")
end

function Debugger:stop_profiling()
	debug.sethook()
end

function Debugger.reset_results()
	Debugger.statistics = {}
end

function Debugger.print_results()
	local sorted_info = {}

	for function_name, statistics in pairs(Debugger.statistics) do	
		table.insert(sorted_info, {["function_name"] = function_name, ["statistics"] = statistics})
	end
	
	table.sort(sorted_info, (function(a, b) 
		return (a.statistics.total_execution_time > b.statistics.total_execution_time)
	end))
	
	for index, info in ipairs(sorted_info) do
		local average_execution_time = (info.statistics.total_execution_time / info.statistics.call_count)
	
		console.writeline(info.function_name)
		console.writeline("{")
		console.writeline("\ttotal_execution_time = " .. info.statistics.total_execution_time)
		console.writeline("\taverage_execution_time = " .. average_execution_time)
		console.writeline("\tcall_count = " .. info.statistics.call_count)
		console.writeline("}")
		console.writeline("")
	end
end