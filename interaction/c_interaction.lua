--[[
	Ourlife: RPG

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU (General Public License) as puslisched by
	the free software fundation; either version 3 of the license, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.

	(c) 2014 OurLife. All rights reserved.
]]

--[[
	Wersja opublikowana nie jest wersja finalna skryptu, zawiera kilka niedorobek
	Nowa wersja nieopublikowana nie korzysta z zasobu blur, zostal on zniesiony i zastapiony 
	backgroundem zakrywajacym obraz gry.
	
	@todo:
	1. skonczyc integracje z serwerem - decydowanie jakie "interakcje ma wybrac"
	2. dorobic reszte elementow gui
	3. dokonczyc zatwierdzanie interakcji
	4. prawdopodobnie nalezy poprawic skalowanic niektorych elementow

	Brak supportu dla rozdzielczosci 640x480 i 800x600(?) (atestowane)
]]

-- Variables

local interaction={}
interaction.keyToggle="z" -- klawisz uruchamiajacy
interaction.show=false
interaction.actived=false
interaction.state=nil
interaction.startPressedTick=0 -- czas od uruchomienia
interaction.lastPressedTick=0 -- ostatni czas uruchomienia, zabezpieczenie przed masowymi wcisnieciami (dodano na potrzeby blura)

interaction.previousCart=1
interaction.selectedCart=1

local gui={}
gui.font=dxCreateFont("font/mp_regular.ttf", 10*screenRatio, false)
gui.circles={}
gui.circlesCreated={[1]=nil, [2]=nil, [3]=nil, [4]=nil, [5]=nil}
gui.circles.icon={}
gui.circles.iconData={}
gui.circles.data={}

-- @todo - dokonczyc reszte elementow / przerobic na dximage
-- gui.info=guiCreateStaticImage((100/800)*screenW, (245/600)*screenH, (170/800)*screenW, (88/600)*screenH, "img/interakcja/boxes/b_info.png", false)
-- gui.boxOperation=guiCreateStaticImage((320/800)*screenW, (490/600)*screenH, (175/600)*screenW, (26/600)*screenH, "img/interakcja/boxes/b_interActual.png", false)

gui.circles.iconData[1]={name="i_keys", x=0.192, y=0.213, sx=0.6, sy=0.55}
gui.circles.iconData[2]={name="i_cart", x=0.180, y=0.28, sx=0.655, sy=0.445}
gui.circles.iconData[3]={name="i_transaction", x=0.217, y=0.18, sx=0.55, sy=0.645}
gui.circles.iconData[5]={name="i_drugs", x=0.195, y=0.16, sx=0.655, sy=0.625}
gui.circles.iconData[4]={name="i_mask", x=0.270, y=0.18, sx=0.455, sy=0.66}

gui.circles.data[1]={x=-45, y=286}
gui.circles.data[2]={x=126, y=214}
gui.circles.data[3]={x=212, y=30}
gui.circles.data[4]={x=145, y=-143}
gui.circles.data[5]={x=-55, y=-235}

-- Functions
local function destroyGUIInteractionCart()
	for i=1, #gui.circlesCreated do
		if isElement(gui.circlesCreated[i]) then
			destroyElement(gui.circlesCreated[i])
			gui.circlesCreated[i]=nil
		end
	end
	for i=1, #gui.circles.icon do
		if isElement(gui.circles.icon[i]) then
			destroyElement(gui.circles.icon[i])
			gui.circles.icon[i]=nil
		end
	end
end

local function buildInteractionCart(cart)
	destroyGUIInteractionCart()
	for i=1, cart do
		if i>=6 then break end
		gui.circles[i]=guiCreateStaticImage((screenW+gui.circles.data[i].x)/2, (screenH-gui.circles.data[i].y)/2, 33*screenRatio, 30*screenRatio, "img/boxes/b_circle.png", false)
		gui.circles.icon[i]=guiCreateStaticImage(gui.circles.iconData[i].x, gui.circles.iconData[i].y, gui.circles.iconData[i].sx, gui.circles.iconData[i].sy, "img/icons/" ..  gui.circles.iconData[i].name .. ".png", true, gui.circles[i])
		guiSetAlpha(gui.circles[i], 0)	
		if i~=1 then
			guiSetAlpha(gui.circles.icon[i], 0.4)
		else
			guiSetAlpha(gui.circles.icon[1], 0.4)
		end
		gui.circlesCreated[i]=gui.circles[i]
	end
	guiSetAlpha(gui.circles.icon[1], 1)
end

local function showInteraction()
	blurManager:toggleBlur(true)
	
	buildInteractionCart(6)
	addEventHandler("onClientRender", root, drawElements)
	interaction.state="in"
	interaction.actived=true
	interaction.show=true
	interaction.startPressedTick=getTickCount()
	--addEventHandler("onClientMouseWheel", root, onClientMouseWheel)
	bindKey("mouse_wheel_up", "down", scrollMouse)
	bindKey("mouse_wheel_down", "down", scrollMouse)
end

local function hideInteraction()
	if not interaction.actived then return end
	interaction.state="out"
	interaction.startPressedTick=getTickCount()
	setTimer(function()
		--removeEventHandler("onClientMouseWheel", root, onClientMouseWheel)
		unbindKey("mouse_wheel_up", "down", scrollMouse)
		unbindKey("mouse_wheel_down", "down", scrollMouse)
		removeEventHandler("onClientRender", root, drawElements)
		interaction.actived=false
		interaction.show=false
	end, 500, 1)
	blurManager:toggleBlur(false)
end

function toggleInteraction(state)
	if not interaction.actived then
		interaction.actived=true
		showInteraction()
	else
		hideInteraction()
	end
end

function scrollMouse(k, ks)
	if k=="mouse_wheel_up" then
		onScrollMouse(true)
	elseif k=="mouse_wheel_down" then
		onScrollMouse(false)
	end
end

function interactionGUI(opacity)
	if (getTickCount()-interaction.startPressedTick)<300 then return end

	for _,v in pairs(gui.circlesCreated) do
		guiSetAlpha(v, opacity*1/255)
	end
end

function onScrollMouse(wheel) 
	if not interaction.actived then return end
	if wheel then
		-- up
		interaction.previousCart=interaction.selectedCart
		interaction.selectedCart=interaction.selectedCart+1
		if interaction.selectedCart>=#gui.circlesCreated+1 then
			interaction.selectedCart=1
			guiSetAlpha(gui.circles.icon[interaction.selectedCart], 1)
			guiSetAlpha(gui.circles.icon[interaction.previousCart], 0.4)
		else
			guiSetAlpha(gui.circles.icon[interaction.selectedCart], 1)
			guiSetAlpha(gui.circles.icon[interaction.previousCart], 0.4)
		end
	else
		-- down
		interaction.previousCart=interaction.selectedCart
		interaction.selectedCart=interaction.selectedCart-1
		if interaction.selectedCart<=0 then
			interaction.selectedCart=#gui.circlesCreated
			guiSetAlpha(gui.circles.icon[interaction.selectedCart], 1)
			guiSetAlpha(gui.circles.icon[interaction.previousCart], 0.4)
		else
			guiSetAlpha(gui.circles.icon[interaction.selectedCart], 1)
			guiSetAlpha(gui.circles.icon[interaction.previousCart], 0.4)
		end
	end
end

-- Event handler
function drawElements()
	if interaction.show and interaction.actived then
		local logoW, logoH=102*screenRatio, 88*screenRatio
		local infoW, infoH=129*screenRatio, 88*screenRatio

		local progress=(getTickCount()-interaction.startPressedTick)/500

		if interaction.state=="in" then
			tmpInfoHeight=interpolateBetween(screenH+screenH, 0, 0, (screenH-infoH+25*screenRatio)/2, 0, 0, progress, "InOutBack")
			tmpLogoWidth=interpolateBetween(0, 0, 0, 102*screenRatio, 0, 0, progress, "InOutQuad")
			alpha=interpolateBetween(0, 0, 0, 255, 0, 0, progress, "InQuad")
			rotationLogo=math.sin(getTickCount()/1000)*8
		elseif interaction.state=="out" then
			tmpInfoHeight=interpolateBetween(screenH*335*screenRatio, 0, 0, screenH+(88*screenRatio)*screenH+10, 0, 0, progress, "OutQuad")
			tmpLogoWidth=interpolateBetween(102*screenRatio, 0, 0, 0, 0, 0, progress, "OutInQuad")
			alpha=interpolateBetween(255, 0, 0, 0, 0, 0, progress, "OutQuad")
			rotationLogo=math.sin(getTickCount()/100)*80
		end
		
		interactionGUI(alpha)
		dxDrawImage((screenW-infoW*3.4)/2, tmpInfoHeight, 118*screenRatio, 58*screenRatio, "img/boxes/b_info.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawImage((screenW-logoW)/2, (screenH-logoH+36)/2, tmpLogoWidth, 88*screenRatio, "img/boxes/b_main.png", rotationLogo, 0, 0, tocolor(alpha, alpha, alpha, alpha))
		
		dxDrawImage((screenW-135*screenRatio), screenH-18*screenRatio, 132*screenRatio, 12*screenRatio, "img/boxes/t_ending.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
		dxDrawImage((screenW-107*screenRatio)/2, (screenH+26*19)/2, 107*screenRatio, 13*screenRatio, "img/boxes/t_info.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	end
end

-- Binding keys
addEventHandler("onClientResourceStart", resourceRoot, function()
	local function bindInteration(k, ks)
		if not k or not ks then return end

		if isConsoleActive() then return end
		if isChatBoxInputActive() then return end
		
		if (getTickCount()-interaction.lastPressedTick)<1000 then return end
		interaction.lastPressedTick=getTickCount()
		
		if ks=="up" then
			toggleInteraction(false)
		elseif ks=="down" then
			toggleInteraction(true)
		end
	end
	bindKey(interaction.keyToggle, "both", bindInteration)
end)
