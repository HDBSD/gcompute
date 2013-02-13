GCompute.IDE.ActionMap:Register ("Run Code",
	function (self)
		local codeEditor = self:GetActiveCodeEditor ()
		local sourceDocumentId = codeEditor:GetDocument ():GetId ()
		local sourceDocumentUri = codeEditor:GetDocument ():GetUri ()
		local editorHelper = codeEditor and codeEditor:GetEditorHelper ()
		if not editorHelper then return end
		
		local outputPaneCleared = false
		self:GetViewManager ():GetViewById ("Output"):Clear ()
		outputPaneCleared = true
		
		local pipe = GCompute.Pipe ()
		pipe:AddEventListener ("Data",
			function (_, data, color)
				if not outputPaneCleared then
					self:GetViewManager ():GetViewById ("Output"):Clear ()
					outputPaneCleared = true
				end
				
				self:GetViewManager ():GetViewById ("Output"):Append (data, color, sourceDocumentId, sourceDocumentUri)
			end
		)
		
		local errorPipe = GCompute.Pipe ()
		errorPipe:AddEventListener ("Data",
			function (_, data, color)
				if not outputPaneCleared then
					self:GetViewManager ():GetViewById ("Output"):Clear ()
					outputPaneCleared = true
				end
				
				self:GetViewManager ():GetViewById ("Output"):Append (data, color or GLib.Colors.IndianRed, sourceDocumentId, sourceDocumentUri)
			end
		)
		
		editorHelper:Run (codeEditor, pipe, errorPipe, pipe, errorPipe)
	end
)