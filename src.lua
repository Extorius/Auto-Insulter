-- Universal Auto Insulter 0.2
Settings = {
	["api key"] = "",
	["randomness"] = 0.6,
	["max tokens"] = 47,
}

local Request = syn and syn.request or request
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()
local PlayerCamera = workspace.CurrentCamera
local OnPlayer = nil
local AutoBully = true

local function Insult(Prompt)
	return Request({
		Url = "https://api.openai.com/v1/completions", 
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
			["Authorization"] =  "Bearer "..Settings["api key"]
		},
		Body = HttpService:JSONEncode({
			model = "text-davinci-003",
			prompt = Prompt,
			temperature = Settings["randomness"],
  			max_tokens = Settings["max tokens"], --150
  			top_p = 1,
  			frequency_penalty = 0.0,
  			presence_penalty = 0.6,
		});
	});
end

local GameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local GameName = GameInfo.Name
local GameDesc = GameInfo.Description

local function SayInsult(Name)
	local DefaultPrompt = "You are an AI created to make specific insults based on the type of game people are currently in. You must take the game name and description to figure out what kind of people play the game, and insult them based off of that. The game name: '" .. GameName .. "', the game's description: '" .. GameDesc .. "'. Here's the name of the person you're insulting: '" .. Name .. "'. Provide a short, rude, and funny insult that doesn't contain any whitespace besides spaces."
	local MessageRequest = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest");
	local Insult = Insult(DefaultPrompt)
	Insult = HttpService:JSONDecode(Insult["Body"]).choices[1].text
	Insult = Insult:gsub("\n","",100)
	Insult = Insult:gsub('"',"",100)
	MessageRequest:FireServer(Insult:gsub("\n",""), "All")
end
UserInput.InputBegan:Connect(function(input)
	if UserInput:IsKeyDown(Enum.KeyCode.LeftAlt) then
		AutoBully = not AutoBully
	elseif UserInput:IsKeyDown(Enum.KeyCode.Z) and OnPlayer then
		SayInsult(OnPlayer)
		OnPlayer = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if AutoBully then
		local Lowest = math.huge
		OnPlayer = nil
		for i,v in ipairs(Players:GetPlayers()) do
			if v.Character and v ~= LocalPlayer then
				local Character,HRP=v.Character,v.Character:FindFirstChild("HumanoidRootPart")
				if Character and HRP then
					vector, inviewport = PlayerCamera:WorldToViewportPoint(HRP.Position)
					if inviewport then
						Vector_1 = Vector2.new(vector.X,vector.Y)
						Vector_2 = Vector2.new(PlayerMouse.X,PlayerMouse.Y)
						Magnitude = (Vector_1 - Vector_2).Magnitude
						if Magnitude < Lowest and Magnitude < 50 then
							Lowest = Magnitude
							OnPlayer = v.DisplayName
							local Highlight = Instance.new("Highlight",v.Character)
							local Billboard = Instance.new("BillboardGui",HRP)
							local TextLabel = Instance.new("TextLabel",Billboard)
							Billboard.Name = "Billboard"
							Billboard.Size = UDim2.new(0,200,0,100)
							Billboard.AlwaysOnTop = true
							TextLabel.Size = UDim2.new(0,200,0,100)
							TextLabel.BackgroundTransparency = 1
							TextLabel.Font = "GothamBold"
							TextLabel.Text = "Press 'Z' to insult this player"
							TextLabel.TextSize = 16
							TextLabel.TextColor3 = Color3.fromRGB(250,70,70)
						else
							if Character:FindFirstChild("Highlight") then
								Character:FindFirstChild("Highlight"):Destroy()
							elseif HRP:FindFirstChild("Billboard") then
								HRP:FindFirstChild("Billboard"):Destroy()
							end
						end
					end
				end
			end
		end
	else
		for i,v in ipairs(Players:GetPlayers()) do
			if v.Character and v ~= LocalPlayer then
				local Character,HRP=v.Character,v.Character:FindFirstChild("HumanoidRootPart")
				if Character and HRP then
					if Character:FindFirstChild("Highlight") then
						Character:FindFirstChild("Highlight"):Destroy()
					elseif HRP:FindFirstChild("Billboard") then
						HRP:FindFirstChild("Billboard"):Destroy()
					end
				end
			end
		end
	end
end)

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
   Name = "Auto Insulter",
   LoadingTitle = "Auto Insulver v1",
   LoadingSubtitle = "by Extorius Scripts",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "Extorius Scripts", -- Create a custom folder for your hub/game
      FileName = "Auto Insulter"
   },
   Discord = {
      Enabled = false,
      Invite = "ABCD", -- The Discord invite code, do not include discord.gg/
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Sirius Hub",
      Subtitle = "Key System",
      Note = "Join the discord (discord.gg/sirius)",
      FileName = "SiriusKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = "Hello"
   }
})

local Tab = Window:CreateTab("Configuration", 4483362458)
local Section = Tab:CreateSection("")
local Input = Tab:CreateInput({
   Name = "OpenAI API Key",
   PlaceholderText = "Enter your key here",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
   	Settings["api key"] = Text
   end,
})
local Slider = Tab:CreateSlider({
   Name = "Insult Randomness",
   Range = {0.1,0.9},
   Increment = 0.1,
   Suffix = "Int",
   CurrentValue = 0.5,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   Settings["randomness"] = Value
   end,
})
local Slider = Tab:CreateSlider({
   Name = "Max Tokens",
   Range = {1,45},
   Increment = 5,
   Suffix = "Tokens",
   CurrentValue = 47,
   Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
   Settings["max tokens"] = Value
   end,
})
