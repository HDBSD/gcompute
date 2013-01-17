if GCompute.IDE then return end
GCompute.IDE = {}

-- IDE
include ("ide/ide.lua")
include ("ide/ideframe.lua")

-- Documents
include ("ide/document.lua")
include ("ide/documenttypes.lua")
include ("ide/documentmanager.lua")

-- Views
include ("ide/view.lua")
include ("ide/viewtypes.lua")

-- IDE
include ("ide/editor.lua")
include ("ide/editor_frame.lua")
include ("ide/plugins.lua")
include ("ide/savableproxy.lua")
include ("ide/tabcontextmenu.lua")
include ("ide/toolbar.lua")
include ("ide/undoredostackproxy.lua")

-- Keyboard Shortcuts and Plugins
GCompute.IDE.KeyboardMap = Gooey.KeyboardMap ()
GCompute.IncludeDirectory ("gcompute/ui/ide/keyboardmap")
GCompute.IncludeDirectory ("gcompute/ui/ide/plugins")

-- Notification Bars
include ("ide/notificationbars/notificationbar.lua")
include ("ide/notificationbars/filechangenotificationbar.lua")
include ("ide/notificationbars/savefailurenotificationbar.lua")

-- Undo / Redo
include ("ide/undoredo/undoredostack.lua")
include ("ide/undoredo/undoredoitem.lua")