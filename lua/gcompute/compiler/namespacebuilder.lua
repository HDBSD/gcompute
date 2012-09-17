local self = {}
GCompute.NamespaceBuilder = GCompute.MakeConstructor (self, GCompute.ASTVisitor)

--[[
	NamespaceBuilder
	
	1. Assigns a NamespaceDefinition to all Statements that should have one
		and adds member variables to them
	2. Assigns NamespaceDefinitions to FunctionDeclarations and AnonymousFunctions
		and adds function parameters to them
]]

function self:ctor (compilationUnit)
	self.CompilationUnit = compilationUnit
	self.AST = self.CompilationUnit:GetAbstractSyntaxTree ()
end

function self:VisitRoot (blockStatement)
	blockStatement:SetNamespace (blockStatement:GetNamespace () or GCompute.NamespaceDefinition ())
	blockStatement:GetNamespace ():SetConstructorAST (blockStatement)
	blockStatement:GetNamespace ():SetNamespaceType (GCompute.NamespaceType.Global)
end

function self:VisitBlock (blockStatement)
	blockStatement:SetNamespace (blockStatement:GetNamespace () or GCompute.NamespaceDefinition ())
	
	local namespace = blockStatement:GetNamespace ()
	namespace:SetContainingNamespace (blockStatement:GetParentNamespace ())
	namespace:SetConstructorAST (blockStatement)
	if namespace:GetNamespaceType () == GCompute.NamespaceType.Unknown then
		namespace:SetNamespaceType (GCompute.NamespaceType.Local)
	end
end

function self:VisitStatement (statement)
	if statement:HasNamespace () then
		statement:SetNamespace (statement:GetNamespace () or GCompute.NamespaceDefinition ())
		statement:GetNamespace ():SetContainingNamespace (statement:GetParentNamespace ())
	end
	
	if statement:Is ("FunctionDeclaration") or
	   statement:Is ("AnonymousFunction") then
		self:VisitFunction (statement)
	end
	
	if statement:Is ("RangeForLoop") then
		statement:GetNamespace ():SetNamespaceType (GCompute.NamespaceType.Local)
	end
	
	if statement:Is ("VariableDeclaration") then
		if not statement:GetType () then
			statement:SetType (GCompute.InferredType ())
		end
		
		local variableDefinition = statement:GetParentNamespace ():AddMemberVariable (statement:GetName (), statement:GetType ())
		statement:SetVariableDefinition (variableDefinition)
	end
end

function self:VisitFunction (func)
	local functionDefinition = nil
	
	if func:Is ("FunctionDeclaration") then
		functionDefinition = func:GetParentNamespace ():AddFunction (func:GetName (), func:GetParameterList ())
	else
		functionDefinition = GCompute.FunctionDefinition ("<anonymous-function>", func:GetParameterList ())
	end
	
	functionDefinition:SetReturnType (GCompute.DeferredNameResolution (func:GetReturnTypeExpression ()))
	functionDefinition:SetFunctionDeclaration (func)
	func:SetFunctionDefinition (functionDefinition)
	
	-- Set up function namespace with function parameters as members
	local namespace = func:GetNamespace () or GCompute.NamespaceDefinition ()
	func:SetNamespace (namespace)
	namespace:SetNamespaceType (GCompute.NamespaceType.FunctionRoot)
	namespace:SetContainingNamespace (func:GetParentNamespace ())
	
	local parameterList = func:GetParameterList ()
	for parameterType, parameterName in parameterList:GetEnumerator () do
		namespace:AddMemberVariable (parameterName)
	end
end