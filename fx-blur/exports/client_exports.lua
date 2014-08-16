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

function toggleBlur(state, power)
	if state then
		blurData.fxPower=power or 1
		showBlur()
	else 
		hideBlur()
	end
end