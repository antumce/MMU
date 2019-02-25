
if mmu.small then
	mmu.name = 'Minimalist ' .. mmu.name
end

-- run as standalone executable
local standalone = TrainerOrigin ~= nil

-- create main window but do not show it yet
MainWindow = createForm(false)
MainWindow.BorderStyle = bsSizeable

-- set minimum size
MainWindow.Constraints.MinWidth = 320
MainWindow.Constraints.MinHeight = 350

-- icon displayed in the main interface
local icon = createPicture()
icon.loadFromFile('data/bitmap/icon.png')
MainWindow.Icon = icon.getBitmap()


-- closes trainer
local function shutdown()
	-- free memory allocated for the main interface
	MainWindow.destroy()

	-- trainer is run as a standalone executable
	if standalone then
		-- shuts down the main CE process
		closeCE()
		return caFree
	end
end

-- text displayed in title bar
MainWindow.setCaption(mmu.name)

dofile('scripts/menu.lua')

-- action to take when 'X-ed' out of
MainWindow.onClose = shutdown

mmu.processLabel = createLabel(MainWindow)
mmu.processLabel.anchorSideLeft.control = MainWindow
mmu.processLabel.anchorSideLeft.side = asrCenter

local loadedProcess = getOpenedProcessID()
if loadedProcess > 0 then
	mmu.processLabel.setCaption('Attached process: ' .. tostring(loadedProcess))
else
	mmu.processLabel.setCaption('Attached process:')
end

-- tabbed interface (single panel for minimalist trainer)
tabs = dofile('scripts/tabs.lua')

-- make main window visible
MainWindow.ShowInTaskBar = 'stAlways'
MainWindow.centerScreen()

-- override show method to display error messages
local showOrig = MainWindow.show
MainWindow.show = function()
	showOrig()

	-- Show any errors/warnings from startup
	if #mmu.errors > 0 then
		for idx, msg in pairs(mmu.errors) do
			showMessage(msg)
		end
	end
end
