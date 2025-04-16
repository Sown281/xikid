local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local placeId = game.PlaceId
local expectedPlaceId = 18668065416

-- Biến cho Noclip
local isNoclip = false
-- Noclip loop: nếu bật, sẽ tắt va chạm cho toàn bộ phần Body của character
RunService.Stepped:Connect(function()
    if isNoclip then
        local character = game.Players.LocalPlayer and game.Players.LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

------------------------------------------------------------------
-- Hàm Animation cho button (ấn chuyển màu xanh rồi revert về đỏ)
------------------------------------------------------------------
local function playButtonClickAnimation(button, onComplete)
    local originalColor = button.BackgroundColor3
    local clickColor = Color3.fromRGB(50, 255, 50)
    local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    local tweenGreen = TweenService:Create(button, tweenInfo, {BackgroundColor3 = clickColor})
    local tweenBack = TweenService:Create(button, tweenInfo, {BackgroundColor3 = originalColor})
    tweenGreen:Play()
    tweenGreen.Completed:Connect(function()
        tweenBack:Play()
        tweenBack.Completed:Connect(function()
            if onComplete then onComplete() end
        end)
    end)
end

------------------------------------------------------------------
-- Hàm tạo Popup Hướng dẫn (Guide)
------------------------------------------------------------------
local function createGuidePopup()
    -- Kiểm tra xem đã có guide popup nào chưa
    if game.CoreGui:FindFirstChild("GuidePopup") then
        game.CoreGui:FindFirstChild("GuidePopup"):Destroy()
    end

    local guideGui = Instance.new("ScreenGui")
    guideGui.Name = "GuidePopup"
    guideGui.Parent = game.CoreGui

    -- Shadow cho popup
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, 360, 0, 230)
    shadow.Position = UDim2.new(0.5, -175, 0.5, -105)
    shadow.BackgroundColor3 = Color3.new(0,0,0)
    shadow.BorderSizePixel = 0
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = 1
    shadow.Parent = guideGui
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow

    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.new(0, 350, 0, 220)
    popupFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    popupFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    popupFrame.BorderSizePixel = 0
    popupFrame.ZIndex = 2
    popupFrame.Parent = guideGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
    }
    gradient.Rotation = 90
    gradient.Parent = popupFrame

    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 12)
    popupCorner.Parent = popupFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Hướng Dẫn Sử Dụng"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.ZIndex = 3
    title.Parent = popupFrame

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 120)
    info.Position = UDim2.new(0, 10, 0, 50)
    info.BackgroundTransparency = 1
    info.Text = "• Noclip Toggle: Bật/Tắt khả năng đi xuyên các vật cản.\n• TP Castle: Di chuyển nhanh đến castle.\n• Find Tesla: Tìm và di chuyển đến Tesla.\n\nKhi bật noclip, nhân vật sẽ có thể đi xuyên tường và các vật thể."
    info.TextColor3 = Color3.fromRGB(220, 220, 220)
    info.Font = Enum.Font.Gotham
    info.TextSize = 16
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 3
    info.Parent = popupFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 35)
    closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "Close"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.ZIndex = 3
    closeBtn.Parent = popupFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    local closeStroke = Instance.new("UIStroke")
    closeStroke.Thickness = 1
    closeStroke.Color = Color3.fromRGB(200, 100, 100)
    closeStroke.Transparency = 0.3
    closeStroke.Parent = closeBtn

    -- Hiệu ứng hover cho nút Close
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 30, 30)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(closeBtn, function()
            guideGui:Destroy()
        end)
    end)

    -- Animation hiển thị popup
    popupFrame.Size = UDim2.new(0, 0, 0, 0)
    popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(0, 0, 0, 0)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(popupFrame, tweenInfo, {Size = UDim2.new(0, 350, 0, 220), Position = UDim2.new(0.5, -175, 0.5, -110)}):Play()
    TweenService:Create(shadow, tweenInfo, {Size = UDim2.new(0, 360, 0, 230), Position = UDim2.new(0.5, -175, 0.5, -105)}):Play()
end

------------------------------------------------------------------
-- Hàm tạo Main UI với 4 Button
------------------------------------------------------------------
local function createMainUI()
    -- Xóa UI cũ nếu tồn tại
    if game.CoreGui:FindFirstChild("MainUI") then
        game.CoreGui:FindFirstChild("MainUI"):Destroy()
    end

    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "MainUI"
    mainGui.Parent = game.CoreGui

    -- Shadow cho MainFrame
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, 330, 0, 290)
    shadow.Position = UDim2.new(0.5, -155, 0.5, -135)
    shadow.BackgroundColor3 = Color3.new(0,0,0)
    shadow.BorderSizePixel = 0
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = 1
    shadow.Parent = mainGui
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 2
    MainFrame.Parent = mainGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
    }
    gradient.Rotation = 90
    gradient.Parent = MainFrame

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = MainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 3
    titleBar.Parent = MainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = titleBar

    -- Fix cho phần góc dưới của titleBar
    local fixCorner1 = Instance.new("Frame")
    fixCorner1.Size = UDim2.new(0, 15, 0, 20)
    fixCorner1.Position = UDim2.new(0, 0, 0, 20)
    fixCorner1.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fixCorner1.BorderSizePixel = 0
    fixCorner1.ZIndex = 3
    fixCorner1.Parent = titleBar

    local fixCorner2 = Instance.new("Frame")
    fixCorner2.Size = UDim2.new(0, 15, 0, 20)
    fixCorner2.Position = UDim2.new(1, -15, 0, 20)
    fixCorner2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    fixCorner2.BorderSizePixel = 0
    fixCorner2.ZIndex = 3
    fixCorner2.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "skidded shit"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Parent = titleBar

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.ZIndex = 4
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    -- Minimize button (add this after creating closeBtn)
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -75, 0.5, -15)  -- Position to the left of the close button
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 18
    minimizeBtn.ZIndex = 4
    minimizeBtn.Parent = titleBar

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeBtn

    -- Add hover effect for minimize button
    minimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 255)}):Play()
    end)
    minimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 255)}):Play()
    end)

    -- Store original sizes for use when minimizing/maximizing
    local originalMainFrameSize = UDim2.new(0, 320, 0, 280)
    local originalMainFramePos = UDim2.new(0.5, -160, 0.5, -140)
    local originalShadowSize = UDim2.new(0, 330, 0, 290)
    local originalShadowPos = UDim2.new(0.5, -155, 0.5, -135)
    
    -- Minimized size and position
    local minimizedSize = UDim2.new(0, 180, 0, 40)
    
    -- Click event for minimize button
    minimizeBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(minimizeBtn, function()
            isMinimized = not isMinimized
            
            if isMinimized then
                -- Save current positions for maximize later
                originalMainFramePos = MainFrame.Position
                originalShadowPos = shadow.Position
                
                -- Calculate minimized position (keeping X the same, adjusting Y)
                local minimizedMainPos = UDim2.new(
                    originalMainFramePos.X.Scale, 
                    originalMainFramePos.X.Offset, 
                    originalMainFramePos.Y.Scale, 
                    originalMainFramePos.Y.Offset + 120
                )
                
                local minimizedShadowPos = UDim2.new(
                    originalShadowPos.X.Scale, 
                    originalShadowPos.X.Offset, 
                    originalShadowPos.Y.Scale, 
                    originalShadowPos.Y.Offset + 120
                )
                
                -- Minimize animation
                local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                
                -- Hide all buttons except title bar
                for _, child in pairs(MainFrame:GetChildren()) do
                    if child ~= titleBar and child:IsA("GuiObject") and child.Visible then
                        child.Visible = false
                    end
                end
                
                -- Update minimize button text
                minimizeBtn.Text = "+"
                
                -- Animate to minimized state
                TweenService:Create(MainFrame, tweenInfo, {
                    Size = minimizedSize,
                    Position = minimizedMainPos
                }):Play()
                
                TweenService:Create(shadow, tweenInfo, {
                    Size = UDim2.new(0, minimizedSize.X.Offset + 10, 0, minimizedSize.Y.Offset + 10),
                    Position = minimizedShadowPos
                }):Play()
            else
                -- Maximize animation
                local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                
                -- Update minimize button text
                minimizeBtn.Text = "-"
                
                -- Animate to original size
                TweenService:Create(MainFrame, tweenInfo, {
                    Size = originalMainFrameSize,
                    Position = originalMainFramePos
                }):Play()
                
                TweenService:Create(shadow, tweenInfo, {
                    Size = originalShadowSize,
                    Position = originalShadowPos
                }):Play()
                
                -- Show all UI elements after a slight delay
                wait(0.2)
                for _, child in pairs(MainFrame:GetChildren()) do
                    if child:IsA("GuiObject") and not child.Visible and child ~= titleBar then
                        child.Visible = true
                    end
                end
            end
        end)
    end)
    -- Danh sách Button:
    -- 1. Hướng dẫn
    local guideBtn = Instance.new("TextButton")
    guideBtn.Size = UDim2.new(0, 280, 0, 40)
    guideBtn.Position = UDim2.new(0, 20, 0, 55)
    guideBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    guideBtn.BorderSizePixel = 0
    guideBtn.Text = "Hướng Dẫn"
    guideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    guideBtn.Font = Enum.Font.GothamBold
    guideBtn.TextSize = 16
    guideBtn.ZIndex = 3
    guideBtn.Parent = MainFrame

    local guideCorner = Instance.new("UICorner")
    guideCorner.CornerRadius = UDim.new(0, 10)
    guideCorner.Parent = guideBtn

    local guideStroke = Instance.new("UIStroke")
    guideStroke.Thickness = 1.5
    guideStroke.Color = Color3.fromRGB(200, 100, 100)
    guideStroke.Transparency = 0.5
    guideStroke.Parent = guideBtn

    -- Icon cho guide button
    local guideIcon = Instance.new("ImageLabel")
    guideIcon.Size = UDim2.new(0, 24, 0, 24)
    guideIcon.Position = UDim2.new(0, 15, 0.5, -12)
    guideIcon.BackgroundTransparency = 1
    guideIcon.Image = "rbxassetid://3926305904" -- Roblox default icon pack
    guideIcon.ImageRectOffset = Vector2.new(4, 804)
    guideIcon.ImageRectSize = Vector2.new(36, 36)
    guideIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    guideIcon.ZIndex = 4
    guideIcon.Parent = guideBtn

    -- Text correction for icon
    guideBtn.Text = "              Hướng Dẫn"

    -- 2. Noclip Toggle
    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Size = UDim2.new(0, 280, 0, 40)
    noclipBtn.Position = UDim2.new(0, 20, 0, 110)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    noclipBtn.BorderSizePixel = 0
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipBtn.Font = Enum.Font.GothamBold
    noclipBtn.TextSize = 16
    noclipBtn.ZIndex = 3
    noclipBtn.Parent = MainFrame

    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 10)
    noclipCorner.Parent = noclipBtn

    local noclipStroke = Instance.new("UIStroke")
    noclipStroke.Thickness = 1.5
    noclipStroke.Color = Color3.fromRGB(200, 100, 100)
    noclipStroke.Transparency = 0.5
    noclipStroke.Parent = noclipBtn

    -- Icon cho noclip button
    local noclipIcon = Instance.new("ImageLabel")
    noclipIcon.Size = UDim2.new(0, 24, 0, 24)
    noclipIcon.Position = UDim2.new(0, 15, 0.5, -12)
    noclipIcon.BackgroundTransparency = 1
    noclipIcon.Image = "rbxassetid://3926307971" -- Roblox default icon pack
    noclipIcon.ImageRectOffset = Vector2.new(404, 164)
    noclipIcon.ImageRectSize = Vector2.new(36, 36)
    noclipIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    noclipIcon.ZIndex = 4
    noclipIcon.Parent = noclipBtn

    -- Text correction for icon
    noclipBtn.Text = "              Noclip: OFF"

    -- 3. TP Castle
    local castleBtn = Instance.new("TextButton")
    castleBtn.Size = UDim2.new(0, 280, 0, 40)
    castleBtn.Position = UDim2.new(0, 20, 0, 165)
    castleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    castleBtn.BorderSizePixel = 0
    castleBtn.Text = "TP Castle"
    castleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    castleBtn.Font = Enum.Font.GothamBold
    castleBtn.TextSize = 16
    castleBtn.ZIndex = 3
    castleBtn.Parent = MainFrame

    local castleCorner = Instance.new("UICorner")
    castleCorner.CornerRadius = UDim.new(0, 10)
    castleCorner.Parent = castleBtn

    local castleStroke = Instance.new("UIStroke")
    castleStroke.Thickness = 1.5
    castleStroke.Color = Color3.fromRGB(200, 100, 100)
    castleStroke.Transparency = 0.5
    castleStroke.Parent = castleBtn

    -- Icon cho castle button
    local castleIcon = Instance.new("ImageLabel")
    castleIcon.Size = UDim2.new(0, 24, 0, 24)
    castleIcon.Position = UDim2.new(0, 15, 0.5, -12)
    castleIcon.BackgroundTransparency = 1
    castleIcon.Image = "rbxassetid://3926305904" -- Roblox default icon pack
    castleIcon.ImageRectOffset = Vector2.new(2, 602)
    castleIcon.ImageRectSize = Vector2.new(36, 36)
    castleIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    castleIcon.ZIndex = 4
    castleIcon.Parent = castleBtn

    -- Text correction for icon
    castleBtn.Text = "              TP Castle"

    -- 4. Find Tesla
    local teslaBtn = Instance.new("TextButton")
    teslaBtn.Size = UDim2.new(0, 280, 0, 40)
    teslaBtn.Position = UDim2.new(0, 20, 0, 220)
    teslaBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    teslaBtn.BorderSizePixel = 0
    teslaBtn.Text = "Find Tesla"
    teslaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teslaBtn.Font = Enum.Font.GothamBold
    teslaBtn.TextSize = 16
    teslaBtn.ZIndex = 3
    teslaBtn.Parent = MainFrame

    local teslaCorner = Instance.new("UICorner")
    teslaCorner.CornerRadius = UDim.new(0, 10)
    teslaCorner.Parent = teslaBtn

    local teslaStroke = Instance.new("UIStroke")
    teslaStroke.Thickness = 1.5
    teslaStroke.Color = Color3.fromRGB(200, 100, 100)
    teslaStroke.Transparency = 0.5
    teslaStroke.Parent = teslaBtn

    -- Icon cho tesla button
    local teslaIcon = Instance.new("ImageLabel")
    teslaIcon.Size = UDim2.new(0, 24, 0, 24)
    teslaIcon.Position = UDim2.new(0, 15, 0.5, -12)
    teslaIcon.BackgroundTransparency = 1
    teslaIcon.Image = "rbxassetid://3926305904" -- Roblox default icon pack
    teslaIcon.ImageRectOffset = Vector2.new(764, 244)
    teslaIcon.ImageRectSize = Vector2.new(36, 36)
    teslaIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    teslaIcon.ZIndex = 4
    teslaIcon.Parent = teslaBtn

    -- Text correction for icon
    teslaBtn.Text = "              Find Tesla"

    -- Hiệu ứng Hover cho tất cả các nút
    local function setupHoverEffect(button)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 40, 40)}):Play()
        end)
        button.MouseLeave:Connect(function()
            if button == noclipBtn and isNoclip then
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
            end
        end)
    end
    
    setupHoverEffect(guideBtn)
    setupHoverEffect(noclipBtn)
    setupHoverEffect(castleBtn)
    setupHoverEffect(teslaBtn)
    setupHoverEffect(closeBtn)

    -- Animation hiển thị Main UI
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(0, 0, 0, 0)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 320, 0, 280), Position = UDim2.new(0.5, -160, 0.5, -140)}):Play()
    TweenService:Create(shadow, tweenInfo, {Size = UDim2.new(0, 330, 0, 290), Position = UDim2.new(0.5, -155, 0.5, -135)}):Play()

    -- Xử lý sự kiện cho các nút:
    guideBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(guideBtn, function()
            createGuidePopup()
        end)
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        isNoclip = not isNoclip
        noclipBtn.Text = "              Noclip: " .. (isNoclip and "ON" or "OFF")

        local targetColor = isNoclip and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(255, 50, 50)
        TweenService:Create(noclipBtn, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundColor3 = targetColor
        }):Play()

        -- Hiệu ứng khi bật/tắt noclip
        local strokeColor = isNoclip and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(200, 100, 100)
        TweenService:Create(noclipStroke, TweenInfo.new(0.2), {Color = strokeColor}):Play()

        print("Noclip is now", isNoclip and "enabled" or "disabled")
    end)

    castleBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(castleBtn, function()
            print("TP Castle clicked - Teleporting to castle...")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/castletpfast.github.io/refs/heads/main/FASTCASTLE.lua"))()
        end)
    end)

    teslaBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(teslaBtn, function()
            print("Find Tesla clicked - Searching for Tesla...")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ringtaa/tptotesla.github.io/refs/heads/main/Tptotesla.lua"))()
        end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(closeBtn, function()
            -- Animation khi đóng UI
            local tweenInfoClose = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            TweenService:Create(MainFrame, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
            TweenService:Create(shadow, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
            
            -- Xóa UI sau khi animation hoàn tất
            wait(0.3)
            mainGui:Destroy()
        end)
    end)

    -- Draggable MainFrame
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            -- Đồng thời di chuyển cả shadow
            local shadowStartPos = shadow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            
            shadow.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X + 5,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y + 5
            )
        end
    end)
end

------------------------------------------------------------------
-- Warning UI nếu PlaceId sai
------------------------------------------------------------------
if placeId ~= expectedPlaceId then
    local warningGui = Instance.new("ScreenGui")
    warningGui.Name = "PlaceIdWarning"
    warningGui.Parent = game.CoreGui

    -- Shadow cho popup warning
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, 360, 0, 230)
    shadow.Position = UDim2.new(0.5, -170, 0.5, -105)
    shadow.BackgroundColor3 = Color3.new(0,0,0)
    shadow.BorderSizePixel = 0
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = 1
    shadow.Parent = warningGui
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow

    local warningFrame = Instance.new("Frame")
    warningFrame.Size = UDim2.new(0, 350, 0, 220)
    warningFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    warningFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    warningFrame.BorderSizePixel = 0
    warningFrame.ZIndex = 2
    warningFrame.Parent = warningGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))
    }
    gradient.Rotation = 90
    gradient.Parent = warningFrame

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 15)
    wCorner.Parent = warningFrame

    -- Animation hiển thị warning
    warningFrame.Size = UDim2.new(0, 0, 0, 0)
    warningFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(0, 0, 0, 0)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenService:Create(warningFrame, tweenInfo, {Size = UDim2.new(0, 350, 0, 220), Position = UDim2.new(0.5, -175, 0.5, -110)}):Play()
    TweenService:Create(shadow, tweenInfo, {Size = UDim2.new(0, 360, 0, 230), Position = UDim2.new(0.5, -170, 0.5, -105)}):Play()

    -- Icon cảnh báo
    local warningIcon = Instance.new("ImageLabel")
    warningIcon.Size = UDim2.new(0, 40, 0, 40)
    warningIcon.Position = UDim2.new(0.5, -20, 0, 20)
    warningIcon.BackgroundTransparency = 1
    warningIcon.Image = "rbxassetid://3926305904" -- Roblox default icon pack
    warningIcon.ImageRectOffset = Vector2.new(364, 324)
    warningIcon.ImageRectSize = Vector2.new(36, 36)
    warningIcon.ImageColor3 = Color3.fromRGB(255, 100, 100)
    warningIcon.ZIndex = 3
    warningIcon.Parent = warningFrame

    local wTitle = Instance.new("TextLabel")
    wTitle.Size = UDim2.new(1, 0, 0, 30)
    wTitle.Position = UDim2.new(0, 0, 0, 60)
    wTitle.BackgroundTransparency = 1
    wTitle.Text = "CẢNH BÁO!!!"
    wTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
    wTitle.Font = Enum.Font.GothamBold
    wTitle.TextSize = 24
    wTitle.ZIndex = 3
    wTitle.Parent = warningFrame

    local wMessage = Instance.new("TextLabel")
    wMessage.Size = UDim2.new(1, -40, 0, 60)
    wMessage.Position = UDim2.new(0, 20, 0, 90)
    wMessage.BackgroundTransparency = 1
    wMessage.Text = "PLACEID KHÔNG ĐÚNG!\nHiện tại: " .. placeId .. "\nYêu cầu: " .. expectedPlaceId .. "\nScript có thể không hoạt động chính xác!"
    wMessage.TextColor3 = Color3.fromRGB(220, 220, 220)
    wMessage.Font = Enum.Font.Gotham
    wMessage.TextSize = 16
    wMessage.TextWrapped = true
    wMessage.ZIndex = 3
    wMessage.Parent = warningFrame

    local execBtn = Instance.new("TextButton")
    execBtn.Size = UDim2.new(0, 130, 0, 40)
    execBtn.Position = UDim2.new(0, 30, 1, -60)
    execBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    execBtn.BorderSizePixel = 0
    execBtn.Text = "Vẫn Chạy"
    execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    execBtn.Font = Enum.Font.GothamBold
    execBtn.TextSize = 16
    execBtn.ZIndex = 3
    execBtn.Parent = warningFrame

    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 10)
    execCorner.Parent = execBtn

    local execStroke = Instance.new("UIStroke")
    execStroke.Thickness = 1.5
    execStroke.Color = Color3.fromRGB(100, 200, 100)
    execStroke.Transparency = 0.3
    execStroke.Parent = execBtn

    local noExecBtn = Instance.new("TextButton")
    noExecBtn.Size = UDim2.new(0, 130, 0, 40)
    noExecBtn.Position = UDim2.new(1, -160, 1, -60)
    noExecBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    noExecBtn.BorderSizePixel = 0
    noExecBtn.Text = "Hủy"
    noExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noExecBtn.Font = Enum.Font.GothamBold
    noExecBtn.TextSize = 16
    noExecBtn.ZIndex = 3
    noExecBtn.Parent = warningFrame

    local noExecCorner = Instance.new("UICorner")
    noExecCorner.CornerRadius = UDim.new(0, 10)
    noExecCorner.Parent = noExecBtn

    local noExecStroke = Instance.new("UIStroke")
    noExecStroke.Thickness = 1.5
    noExecStroke.Color = Color3.fromRGB(200, 100, 100)
    noExecStroke.Transparency = 0.3
    noExecStroke.Parent = noExecBtn

    -- Hiệu ứng hover cho các nút
    execBtn.MouseEnter:Connect(function()
        TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
    end)
    
    execBtn.MouseLeave:Connect(function()
        TweenService:Create(execBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 0)}):Play()
    end)
    
    noExecBtn.MouseEnter:Connect(function()
        TweenService:Create(noExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
    end)
    
    noExecBtn.MouseLeave:Connect(function()
        TweenService:Create(noExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(150, 0, 0)}):Play()
    end)

    local function closeWarningAndLoadMainUI()
        -- Animation đóng warning UI
        local tweenInfoClose = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        TweenService:Create(warningFrame, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(shadow, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        
        wait(0.3)
        warningGui:Destroy()
        createMainUI()
    end

    local function closeWarning()
        -- Animation đóng warning UI
        local tweenInfoClose = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        TweenService:Create(warningFrame, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        TweenService:Create(shadow, tweenInfoClose, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        
        wait(0.3)
        warningGui:Destroy()
    end

    execBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(execBtn, function()
            closeWarningAndLoadMainUI()
        end)
    end)
    
    noExecBtn.MouseButton1Click:Connect(function()
        playButtonClickAnimation(noExecBtn, function()
            closeWarning()
        end)
    end)

    print("Place ID không khớp với ID dự kiến (" .. expectedPlaceId .. "). Place ID hiện tại: " .. placeId)
else
    print("Place ID khớp với ID dự kiến: " .. placeId)
    createMainUI()
end