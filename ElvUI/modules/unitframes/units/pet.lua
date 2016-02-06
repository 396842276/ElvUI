local E, L, V, P, G = unpack(select(2, ...));
local UF = E:GetModule("UnitFrames");

local _G = _G;
local pairs = pairs;
local format = format;

local InCombatLockdown = InCombatLockdown;

local _, ns = ...;
local ElvUF = ns.oUF;
assert(ElvUF, "ElvUI was unable to locate oUF.");

function UF:Construct_PetFrame(frame)
	frame.Health = self:Construct_HealthBar(frame, true, true, "RIGHT");
	frame.Health.frequentUpdates = true;
	frame.Power = self:Construct_PowerBar(frame, true, true, "LEFT");
	frame.Name = self:Construct_NameText(frame);
	frame.Portrait3D = self:Construct_Portrait(frame, "model");
	frame.Portrait2D = self:Construct_Portrait(frame, "texture");
	frame.Buffs = self:Construct_Buffs(frame);
	frame.Debuffs = self:Construct_Debuffs(frame);
	frame.Castbar = self:Construct_Castbar(frame, "LEFT", L["Pet Castbar"]);
	frame.Castbar.SafeZone = nil;
	frame.Castbar.LatencyTexture:Hide();
	frame.Threat = self:Construct_Threat(frame);
	frame.HealCommBar = self:Construct_HealComm(frame);
	frame.AuraWatch = UF:Construct_AuraWatch(frame);
	frame.Range = UF:Construct_Range(frame);
	frame.customTexts = {};
	
	frame:Point("BOTTOM", E.UIParent, "BOTTOM", 0, 118);
	E:CreateMover(frame, frame:GetName() .. "Mover", L["Pet Frame"], nil, nil, nil, "ALL,SOLO");
end

function UF:Update_PetFrame(frame, db)
	frame.db = db;
	
	do
		frame.ORIENTATION = db.orientation;
		frame.UNIT_WIDTH = db.width;
		frame.UNIT_HEIGHT = db.height;
		
		frame.USE_POWERBAR = db.power.enable;
		frame.POWERBAR_DETACHED = db.power.detachFromFrame;
		frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == "inset" and frame.USE_POWERBAR;
		frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == "spaced" and frame.USE_POWERBAR);
		frame.USE_POWERBAR_OFFSET = db.power.offset ~= 0 and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED;
		frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0;
		
		frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height;
		frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (frame.BORDER*2))/2 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((frame.BORDER+frame.SPACING)*2)));
		
		frame.USE_PORTRAIT = db.portrait and db.portrait.enable;
		frame.USE_PORTRAIT_OVERLAY = frame.USE_PORTRAIT and (db.portrait.overlay or frame.ORIENTATION == "MIDDLE");
		frame.PORTRAIT_WIDTH = (frame.USE_PORTRAIT_OVERLAY or not frame.USE_PORTRAIT) and 0 or db.portrait.width;
	end
	
	frame.colors = ElvUF.colors;
	frame.Portrait = db.portrait.style == "2D" and frame.Portrait2D or frame.Portrait3D;
	frame:RegisterForClicks(self.db.targetOnMouseDown and "AnyDown" or "AnyUp");
	frame:Size(frame.UNIT_WIDTH, frame.UNIT_HEIGHT);
	_G[frame:GetName() .. "Mover"]:Size(frame:GetSize());
	
	UF:Configure_HealthBar(frame);
	
	UF:UpdateNameSettings(frame);
	
	UF:Configure_Power(frame);
	
	UF:Configure_Portrait(frame);
	
	UF:Configure_Threat(frame);
	
	UF:EnableDisable_Auras(frame);
	UF:Configure_Auras(frame, "Buffs");
	UF:Configure_Auras(frame, "Debuffs");
	
	UF:Configure_Castbar(frame);
	
	UF:Configure_HealComm(frame);
	
	if(E.db.unitframe.units.player.enable and E.db.unitframe.units.player.combatfade and ElvUF_Player and not InCombatLockdown()) then
		frame:SetParent(ElvUF_Player);
	end
	
	UF:Configure_Range(frame);
	
	UF:Configure_CustomTexts(frame);
	
	if(UF.db.colors.transparentHealth) then
		UF:ToggleTransparentStatusBar(true, frame.Health, frame.Health.bg);
	else
		UF:ToggleTransparentStatusBar(false, frame.Health, frame.Health.bg, (frame.USE_PORTRAIT and frame.USE_PORTRAIT_OVERLAY) ~= true);
	end
	UF:ToggleTransparentStatusBar(UF.db.colors.transparentPower, frame.Power, frame.Power.bg);
	
	UF:UpdateAuraWatch(frame);
	frame:UpdateAllElements();
end

tinsert(UF["unitstoload"], "pet");