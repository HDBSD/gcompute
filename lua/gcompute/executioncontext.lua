local ExecutionContext = {}
GCompute.ExecutionContext = GCompute.MakeConstructor (ExecutionContext)

function ExecutionContext:ctor (process, thread)
	if not thread then ErrorNoHalt ("ExecutionContexts should only be created by Threads.\n") GCompute.PrintStackTrace () end
	self.Process = process
	self.Thread = thread

	self.ScopeLookup = GCompute.ScopeLookup ()
	
	self.InterruptFlag = false
	
	self.BreakFlag = false
	self.ContinueFlag = false
	self.ReturnFlag = false
	self.ReturnValue = nil
	self.ReturnValueReference = nil
end

function ExecutionContext:Break ()
	self.BreakFlag = true
	self.InterruptFlag = true
end

function ExecutionContext:Continue ()
	self.ContinueFlag = true
	self.InterruptFlag = true
end

function ExecutionContext:ClearInterrupt ()
	self.InterruptFlag = false
	
	self.BreakFlag = false
	self.ContinueFlag = false
	self.ReturnFlag = false
end

function ExecutionContext:ClearBreak ()
	self.BreakFlag = false
	self.InterruptFlag = false
end

function ExecutionContext:ClearContinue ()
	self.ContinueFlag = false
	self.InterruptFlag = false
end

function ExecutionContext:ClearReturn ()
	self.ReturnFlag = false
	self.InterruptFlag = false
	
	local returnValue = self.ReturnValue
	local returnValueReference = self.ReturnValueReference
	
	self.ReturnValue = nil
	self.ReturnValueReference = nil
	
	return returnValue, returnValueReference
end

function ExecutionContext:Error (message)
	ErrorNoHalt (message .. "\n")
end

function ExecutionContext:GetReturnValue ()
	return self.ReturnValue, self.ReturnValueReference
end

function ExecutionContext:PopScope ()
	self.ScopeLookup:PopScope ()
end

function ExecutionContext:PushScope (scope)
	local ScopeInstance = scope:CreateInstance ()
	ScopeInstance:SetParentScope (scope:GetParentScope ())
	self.ScopeLookup:PushScope (ScopeInstance)
	
	return ScopeInstance
end

--[[
	ExecutionContext:PushBlockScope (Scope scopeDefinition)
		Returns: Scope scopeInstance
		
		Pushes an instance of scopeDefinition onto the scope stack, setting
		its parent to the scope that was at the top of the stack.
]]
function ExecutionContext:PushBlockScope (scope)
	local ScopeInstance = scope:CreateInstance ()
	ScopeInstance:SetParentScope (self.ScopeLookup.TopScope)
	self.ScopeLookup:PushScope (ScopeInstance)
	
	return ScopeInstance
end

function ExecutionContext:Return (value, reference)
	self.ReturnValue = value
	self.ReturnValueReference = reference
	
	self.ReturnFlag = true
	self.InterruptFlag = true
end

function ExecutionContext:TopScope ()
	return self.ScopeLookup.TopScope
end