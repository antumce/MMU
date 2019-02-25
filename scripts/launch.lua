
-- main table
mmu = {}
mmu.name = 'MMU Trainer'

-- run as standalone executable
local standalone = TrainerOrigin ~= nil

--- Errors to be shown after window is visible.
mmu.errors = {}
mmu.addError = function(msg, label)
	if label == nil then
		label = 'ERROR'
	end
	msg = label .. ': ' .. msg
	table.insert(mmu.errors, msg)
end
mmu.addWarning = function(msg)
	mmu.addError(msg, 'WARNING')
end

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


--- START: Menu Bar ---

-- create a menu bar for main window
local menuBar = createMainMenu(MainWindow)
local menuBarItems = menuBar.getItems()

-- 'File' main menu
local menuFile = createMenuItem(menuBar)
menuFile.setCaption('File')

-- 'Open' menu item
local miOpen = createMenuItem(menuFile)
miOpen.setCaption('Open Process')
miOpen.ShortCut = 16463
miOpen.onClick = function()
	local process = dofile('scripts/process.lua')
	local PID = process.attach()
	if PID ~= nil then
		mmu.processLabel.setCaption('Attached process: ' .. tostring(PID))
	end
end

local bmpOpen = createPicture()
bmpOpen.loadFromFile('data/bitmap/menu/process.png')
miOpen.Bitmap = bmpOpen.getBitmap()

-- 'Quit' menu item
local miQuit = createMenuItem(menuFile)
miQuit.setCaption('Quit')
miQuit.onClick = shutdown

local bmpQuit = createPicture()
bmpQuit.loadFromFile('data/bitmap/menu/quit.png')
miQuit.Bitmap = bmpQuit.getBitmap()

menuFile.add(miOpen)
menuFile.add(miQuit)

-- 'Help' main menu
local menuHelp = createMenuItem(menuBar)
menuHelp.setCaption('Help')

-- 'About' menu item
local miAbout = createMenuItem(menuHelp)
miAbout.setCaption('About')
miAbout.onClick = function()
	local about = dofile('scripts/about.lua')
	about.showDialog()
end

menuHelp.add(miAbout)

-- add items to menu bar
menuBar.Items.add(menuFile)
menuBar.Items.add(menuHelp)

MainWindow.setMenu(menuBar)

--- END: Menu Bar ---


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

record = dofile('scripts/record.lua')

tabs = dofile('scripts/tabs.lua')

local pgGeneral = dofile('scripts/pages/general.lua')
local pgEnergy = dofile('scripts/pages/energy.lua')
local pgTools = dofile('scripts/pages/tools.lua')

-- make main window visible
MainWindow.ShowInTaskBar = 'stAlways'
MainWindow.centerScreen()
MainWindow.show()

-- Show any errors/warnings from startup
if #mmu.errors > 0 then
	for idx, msg in pairs(mmu.errors) do
		showMessage(msg)
	end
end