-- discord: bruiek (B4) ; roblox: BROTHER4ETVERTACKA (B4tacka)
--[[
    moving platform framework with dynamic speed zones and audio effects
    used CFrame path interpolation, OOP, and raycast character tracking
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Debris = game:GetService("Debris")

local PlatformSystem = {}
PlatformSystem.__index = PlatformSystem

local VsePlatformi = {}

--[[metatable object builder allocating data structures per platform]]
function PlatformSystem.new(platformPart: BasePart, tochkiMarshruta: Folder)
	local self = setmetatable({}, PlatformSystem) -- class into blank memory table

	self.Platforma = platformPart
	self.TochkiFolder = tochkiMarshruta
	self.SpisokTochek = {}

	self.TekushayaTochkaIndex = 1 -- counter tracking active destination array indices

	local localSkorost = platformPart:GetAttribute("Skorost") -- custom speed attributes config values
	self.SkorostPlatformi = localSkorost or 12
	self.BazovayaSkorost = self.SkorostPlatformi
	self.ZaderzhkaNaTochke = 1.5 -- float value tracking delay timing on path nodes

	self.IsActive = true -- loop control
	self.Passazhiri = {} -- map current character root parts to vector offsets

	self.ZvukDvizheniya = nil -- empty for loop sound
	self.PartikliDima = nil -- for visual object nodes

	self:SobstvennayaInizializaciaTochek() -- invoke internal sorting function during object initialization step
	self:SozdatServernieEffekti() -- instantiate engine audio and visual nodes onto tracking attachment

	return self
end

--[[generate attachment-bound audio and particle]]
function PlatformSystem:SozdatServernieEffekti()
	if not self.Platforma then return end -- failsafe break condition

	local krepkoEffekta = Instance.new("Attachment")
	krepkoEffekta.Name = "PlatformEffectsAttachment"
	krepkoEffekta.Position = Vector3.new(0, -1, 0) -- offset downwards below object pivot point
	krepkoEffekta.Parent = self.Platforma -- pair child onto target physical container root part

	local zv = Instance.new("Sound")
	zv.SoundId = "rbxassetid://137048982817372"
	zv.Volume = 0.3
	zv.Looped = true
	zv.Parent = krepkoEffekta
	self.ZvukDvizheniya = zv -- assign instance onto object class property variable dictionary pointer

	local dim = Instance.new("ParticleEmitter")
	dim.Texture = "rbxassetid://2413808405"
	dim.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 3)}) -- age-based scaling
	dim.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)}) -- opacity curve
	dim.Lifetime = NumberRange.new(0.5, 1)
	dim.Rate = 15
	dim.Enabled = false
	dim.Parent = krepkoEffekta
	self.PartikliDima = dim -- data object tracking link over onto main class property index map
end

--[[extract path parts from folder and sort them numerically via alphanumeric keys]]
function PlatformSystem:SobstvennayaInizializaciaTochek()
	if not self.TochkiFolder then return end -- stop script loop if folder is nil

	local vspomogatelnayaTablica = self.TochkiFolder:GetChildren() -- pull array data of instances inside folder
	table.sort(vspomogatelnayaTablica, function(a, b) -- internal sorting algorithm processing item keys
		return tonumber(a.Name) < tonumber(b.Name) -- string key tokens to raw numeric values for ordering comparison
	end)

	for _, tochka in ipairs(vspomogatelnayaTablica) do
		if tochka:IsA("BasePart") then
			table.insert(self.SpisokTochek, tochka) -- append verified part link onto storage array
		end
	end
end

--[[utilize spatial raycast calculations to update character tracking status lists]]
function PlatformSystem:SkanirovatPassazhirov()
	if not self.Platforma then return end

	local ochistkaTablici = {} -- temporary hashmap dictionary tracking users confirmed inside current scan frame
	local rParams = RaycastParams.new()
	rParams.FilterType = Enum.RaycastFilterType.Exclude
	rParams.FilterDescendantsInstances = {self.Platforma} -- prevent internal ray collision hits

	local platformCFrame = self.Platforma.CFrame

	for _, player in ipairs(Players:GetPlayers()) do -- fetch current global active account
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root then -- line intersect queries if visual anchor component targets match alive state
			local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -5, 0), rParams) -- drop ray down 5 studs

			if rayResult and rayResult.Instance == self.Platforma then
				ochistkaTablici[root] = true -- log user tracking object onto active local scan frame database

				if not self.Passazhiri[root] then -- if entry is a new passenger connection
					self.Passazhiri[root] = root.CFrame.Position - platformCFrame.Position -- stores static position offset vector
				end
			end
		end
	end

	for stariyRoot, _ in pairs(self.Passazhiri) do -- run through main historical user link tables
		if not ochistkaTablici[stariyRoot] then -- between current scan results and active tracking lists
			self.Passazhiri[stariyRoot] = nil -- object entries to purge users who jumped off platform
		end
	end
end

--[[handle route looping, CFrame interpolation transformations and offset updates]]
function PlatformSystem:ZapustitDvizhenie()
	task.spawn(function()
		while self.IsActive and self.Platforma do -- loops depending on structural runtime status
			local celTochka = self.SpisokTochek[self.TekushayaTochkaIndex] -- grab target waypoint location
			if not celTochka then -- failsafe check
				self.TekushayaTochkaIndex = 1 -- reset
				continue
			end

			local modifikatorSkorosti = celTochka:GetAttribute("SkorostTochki") -- node for custom speed limit overrides
			if modifikatorSkorosti then -- if targeted zone contains unique speed rule adjustments
				self.SkorostPlatformi = modifikatorSkorosti
			else
				self.SkorostPlatformi = self.BazovayaSkorost -- restore default config velocity rates
			end

			local nachaloCFrame = self.Platforma.CFrame -- record current start
			local konezCFrame = celTochka.CFrame -- capture target waypoint

			local rasstoyanie = (nachaloCFrame.Position - konezCFrame.Position).Magnitude -- compute scalar distance magnitude numbers
			local vremyaPuti = rasstoyanie / self.SkorostPlatformi

			local vremyaStarta = os.clock() -- counter timestamp for lerp precision
			local svyazkaHendlera -- thread block tracking link pointer variable data allocations

			if self.ZvukDvizheniya then self.ZvukDvizheniya:Play() end -- loop engine audio playback
			if self.PartikliDima then self.PartikliDima.Enabled = true end -- exhaust emission rendering

			svyazkaHendlera = RunService.Heartbeat:Connect(function()
				local proshloVremeni = os.clock() - vremyaStarta -- subtract launch markers tracking time intervals
				local alphaMetrika = math.clamp(proshloVremeni / vremyaPuti, 0, 1) -- lerp percentage floats between 0 and 1

				local noviyCFrame = nachaloCFrame:Lerp(konezCFrame, alphaMetrika) -- linear interpolation math configurations
				local staraPoziciya = self.Platforma.Position -- track last known space positions coordinate points before update step
				self.Platforma.CFrame = noviyCFrame -- update primary assembly model positioning coordinates directly over server grid
				local deltaSmesheniya = noviyCFrame.Position - staraPoziciya -- dynamic velocity step distance change vectors

				self:SkanirovatPassazhirov() -- refresh user database maps via vertical floor intersection checks
				for rootPart, _ in pairs(self.Passazhiri) do -- run through current confirmed tracking character root part nodes
					if rootPart and rootPart.Parent then -- validate before modification
						rootPart.CFrame = rootPart.CFrame + deltaSmesheniya -- shift character along delta platform translation values
					end
				end

				if alphaMetrika >= 1 then -- if lerp alpha reached 1, check monitoring interpolation timeline progress states
					svyazkaHendlera:Disconnect() -- unbind event handling listeners
				end
			end)

			task.wait(vremyaPuti) -- suspend until lerp timeline completion bounds

			if self.ZvukDvizheniya then self.ZvukDvizheniya:Stop() end -- halts engine loop sound playback tracks
			if self.PartikliDima then self.PartikliDima.Enabled = false end -- halts particle generation

			local signalZvuk = Instance.new("Sound")
			signalZvuk.SoundId = "rbxassetid://117751546358455"
			signalZvuk.Volume = 0.4
			signalZvuk.Parent = self.Platforma -- pin sound down into live workspace hierarchy tree branch
			signalZvuk:Play()
			Debris:AddItem(signalZvuk, 1)

			task.wait(self.ZaderzhkaNaTochke) -- block tracking loop for cooldown period

			if self.TekushayaTochkaIndex >= #self.SpisokTochek then -- if index array upper structural limit matches
				self.TekushayaTochkaIndex = 1 -- loop path sequencing back to start index reference
			else
				self.TekushayaTochkaIndex = self.TekushayaTochkaIndex + 1 -- increment indexes sequentially
			end
		end
	end)
end

--[[clear instance memories and invalidate class tracking references]]
function PlatformSystem:Destroy()
	self.IsActive = false -- disable runtime loop permanently
	if self.ZvukDvizheniya then self.ZvukDvizheniya:Destroy() end -- flush active sound memory
	if self.PartikliDima then self.PartikliDima:Destroy() end -- wipe particle emission
	table.clear(self.SpisokTochek) -- empty data list from tracking waypoint arrays
	table.clear(self.Passazhiri) -- flush remaining active character link tracking
	setmetatable(self, nil) -- nullify metatable to release memory back to system
end

--[[auto-generate maps geometry assets if direct scene links are absent]]
local function InizializirovatKarty()
	local platformiFolder = Workspace:FindFirstChild("MovingPlatforms")
	local marshrutiFolder = Workspace:FindFirstChild("PlatformWaypoints")

	if not platformiFolder or not marshrutiFolder then -- fallback logic if scene elements missing
		local demoFolderPlatform = Instance.new("Folder")
		demoFolderPlatform.Name = "MovingPlatforms"
		demoFolderPlatform.Parent = Workspace

		local demoFolderWaypoints = Instance.new("Folder")
		demoFolderWaypoints.Name = "PlatformWaypoints"
		demoFolderWaypoints.Parent = Workspace

		local demoPart = Instance.new("Part")
		demoPart.Name = "DemoPlatform"
		demoPart.Size = Vector3.new(12, 1.5, 12)
		demoPart.CFrame = CFrame.new(0, 5, 0)
		demoPart.Anchored = true
		demoPart.Material = Enum.Material.SmoothPlastic
		demoPart.Parent = demoFolderPlatform

		local p1 = Instance.new("Part") -- starting tracking marker node geometry units
		p1.Name = "1" -- assign string identifier numeric tokens representing path ordering arrays
		p1.Size = Vector3.new(2,2,2)
		p1.CFrame = CFrame.new(0, 5, 0)
		p1.Anchored = true
		p1.Transparency = 0.8
		p1.Parent = demoFolderWaypoints -- pair node reference under waypoint tracking root folder

		local p2 = Instance.new("Part") -- ending navigation boundary path parts nodes
		p2.Name = "2" -- apply sequence tracking indexing keys accurately onto spatial marker names
		p2.Size = Vector3.new(2,2,2)
		p2.CFrame = CFrame.new(40, 5, 30)
		p2.Anchored = true
		p2.Transparency = 0.8
		p2.SetAttribute(p2, "SkorostTochki", 25) -- speed zone attribute config parameters into waypoint instances
		p2.Parent = demoFolderWaypoints -- save structural part listing nodes under waypoint folder hierarchies

		platformiFolder = demoFolderPlatform -- override active folder tracking registers with fallback demo directory references
		marshrutiFolder = demoFolderWaypoints -- re-map path targets storage pointers over onto newly built mock layout collections
	end

	for _, part in ipairs(platformiFolder:GetChildren()) do
		if part:IsA("BasePart") then
			local pKlass = PlatformSystem.new(part, marshrutiFolder) -- spawn dedicated individual OOP framework handlers models instances
			table.insert(VsePlatformi, pKlass) -- cache newly created object tracking references addresses inside global runtime sequence arrays
			pKlass:ZapustitDvizhenie() -- launch async physics update routines loop lines tracking engine platform sequences
		end
	end
end

task.spawn(InizializirovatKarty) -- hook entry point setup routines to frame initialize steps asynchronously
