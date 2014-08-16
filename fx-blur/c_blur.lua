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

-- Variables
local screenW, screenH=guiGetScreenSize()

local blurData={}
local blurPool={}
blurPool.list={} 
blurData.showed=false
blurData.actived=false
blurData.state=nil

blurData.fxShaderBlurV=nil
blurData.fxShaderBlurH=nil
blurData.fxScreen=nil
blurData.fxBloom=1
blurData.fxPower=1.88
blurData.startTick=0

-- Functions
function blurPool.start()
	for i,v in pairs(blurPool.list) do
		v.using=false
	end
end

function blurPool.getUnused(sx, sy)
	for i,v in pairs(blurPool.list) do
		if not v.using and v.x==sx and v.y==sy then 
			v.using=true
			return i
		end
	end
	local render=dxCreateRenderTarget(sx, sy)
	if render then
		blurPool.list[render]={using=true, x=sx, y=sy}
	end
	return render
end

function blurPool.applyDownSample(src, val)
	val=val or 2
	local x,y=dxGetMaterialSize(src)
	x=x/val
	y=y/val
	local newPool=blurPool.getUnused(x,y)
	dxSetRenderTarget(newPool)
	dxDrawImage(0, 0, x, y, src)
	return newPool
end

function blurPool.applyV(src, val)
	local x,y=dxGetMaterialSize(src)
	local newPool=blurPool.getUnused(x,y)
	dxSetRenderTarget(newPool, true)
	dxSetShaderValue(blurData.fxShaderBlurV, "tex0", src)
	dxSetShaderValue(blurData.fxShaderBlurV, "tex0size", x, y)
	dxSetShaderValue(blurData.fxShaderBlurV, "bloom", val)
	dxDrawImage(0, 0, x, y, blurData.fxShaderBlurV)
	return newPool
end

function blurPool.applyH(src, val)
	local x,y=dxGetMaterialSize(src)
	local newPool=blurPool.getUnused(x,y)
	dxSetRenderTarget(newPool, true)
	dxSetShaderValue(blurData.fxShaderBlurH, "tex0", src)
	dxSetShaderValue(blurData.fxShaderBlurH, "tex0size", x, y)
	dxSetShaderValue(blurData.fxShaderBlurH, "bloom", val)
	dxDrawImage(0, 0, x, y, blurData.fxShaderBlurH)
	return newPool
end

local function onFXBlur()
	if blurData.showed and blurData.actived then
		local progress=(getTickCount()-blurData.startTick)/500
		if blurData.state=="in" then
			alpha=interpolateBetween(0, 0, 0, 255, 0, 0, progress, "InQuad")
		elseif blurData.state=="out" then
			alpha=interpolateBetween(255, 0, 0, 0, 0, 0, progress, "OutQuad")
		end
		
		blurPool.start()
		dxUpdateScreenSource(blurData.fxScreen)
		local cur=blurData.fxScreen
		cur=blurPool.applyDownSample(cur)
		cur=blurPool.applyV(cur, blurData.fxBloom)
		cur=blurPool.applyH(cur, blurData.fxBloom)
		dxSetRenderTarget()
		dxDrawImage(0, 0, screenW+1, screenH+5, cur, 0, 0, 0, tocolor(255, 255, 255, alpha/blurData.fxPower))
	end
end

function showBlur()
	if not blurData.actived then
		addEventHandler("onClientRender", root, onFXBlur)
		blurData.fxShaderBlurV=dxCreateShader("shader/blurV.fx")
		blurData.fxShaderBlurH=dxCreateShader("shader/blurH.fx")
		blurData.fxScreen=dxCreateScreenSource(screenW/2, screenH/2)
		
		blurData.actived=true
		blurData.showed=true
		blurData.startTick=getTickCount()
		blurData.state="in"
	else
		hideBlur()
	end
end

function hideBlur()
	blurData.state="out"
	blurData.startTick=getTickCount()
	setTimer(function()
		blurData.actived=false
		if isElement(blurData.fxShaderBlurV) then destroyElement(blurData.fxShaderBlurV) end
		if isElement(blurData.fxShaderBlurH) then destroyElement(blurData.fxShaderBlurH) end
		if isElement(blurData.fxScreen) then destroyElement(blurData.fxScreen) end
		removeEventHandler("onClientRender", root, onFXBlur)
		blurData.showed=false
	end, 500, 1)
end