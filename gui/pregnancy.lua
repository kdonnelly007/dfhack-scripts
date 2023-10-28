local gui = require('gui')
local widgets = require('gui.widgets')

PregnancyGui = defclass(PregnancyGui, widgets.Window)
PregnancyGui.ATTRS {
    frame_title='Pregnancy manager',
    frame={w=50, h=45},
    resizable=true, -- if resizing makes sense for your dialog
    resize_min={w=50, h=20}, -- try to allow users to shrink your windows
}

function PregnancyGui:init()
    self.mother = false
    self.father = false
    self.father_historical = false
    self.msg = {}
    self:addviews{
        widgets.ResizingPanel{
            frame={t=0},
            frame_style=gui.FRAME_INTERIOR,
            autoarrange_subviews=true,
            subviews={
                widgets.WrappedLabel{
                    text_to_wrap=self:callback('getMotherLabel')
                },
                widgets.HotkeyLabel{
                    frame={l=0},
                    label="Select Mother",
                    key='CUSTOM_SHIFT_M',
                    on_activate=self:callback('selectmother'),
                },
            },
        },
        widgets.ResizingPanel{
            frame={t=6},
            frame_style=gui.FRAME_INTERIOR,
            autoarrange_subviews=true,
            subviews={
                widgets.WrappedLabel{
                    text_to_wrap=self:callback('getFatherLabel')
                },
                widgets.HotkeyLabel{
                    frame={l=0},
                    label="Select Father",
                    key='CUSTOM_SHIFT_F',
                    on_activate=self:callback('selectfather'),
                },
                widgets.HotkeyLabel{
                    frame={l=5},
                    label="Set Mother's spouse as the Father",
                    key='CUSTOM_F',
                    on_activate=self:callback('spouseFather'),
                    disabled=function() return not self.mother or self.mother.relationship_ids.Spouse == -1 end
                },
            },
        },
        widgets.ResizingPanel{
            frame={t=12},
            frame_style=gui.FRAME_INTERIOR,
            autoarrange_subviews=1,
            subviews={
                widgets.HotkeyLabel{
                    frame={l=0},
                    key='CUSTOM_SHIFT_P',
                    label="Create pregnancy",
                    on_activate=self:callback('CreatePregnancy'),
                    enabled=function() return self.mother or self.father and self.father_historical end
                },
                widgets.TooltipLabel{
                    text_to_wrap=self.msg,
                    show_tooltip=true
                },

                widgets.ToggleHotkeyLabel{
                    view_id='Force',
                    label='Force',
                    options={{label='On', value=true, pen=COLOR_GREEN},
                    {label='Off', value=false, pen=COLOR_RED}},
                    initial_option=false
                },
            },
        },
        widgets.ResizingPanel{
            frame={t=22},
            frame_style=gui.FRAME_INTERIOR,
            autoarrange_subviews=true,
            subviews={
                widgets.HotkeyLabel{
                    frame={l=1, b=0},
                    key='LEAVESCREEN',
                    label="Return to game",
                    on_activate=function()
                        repeat until not self:onInput{LEAVESCREEN=true}
                        view:dismiss()
                    end,
                },
            },
        },
    }
end

function PregnancyGui:selectmother()
    local unit = dfhack.gui.getSelectedUnit()
    if unit then 
        if unit.sex==0 and dfhack.units.isAdult(unit) then 
            self.mother = unit
            self:updateLayout()
        end
    end
end

function PregnancyGui:selectfather()
    local unit = dfhack.gui.getSelectedUnit()
    if unit and dfhack.units.isAdult(unit) then 
        self.father = unit
        self.father_historical = false
        self:updateLayout()
    end
end

function PregnancyGui:spouseFather()
    local father = self:findSpouse(self.mother)[3]
    if father then
        if df.unit.find(father.unit_id) then
            self.father = df.unit.find(father.unit_id)
            self.father_historical = false
        else 
            self.father_historical = father
            self.father = false
        end
    self:updateLayout()
    end
end

function PregnancyGui:getMotherLabel()
    if self.mother then 
        local motherName = dfhack.TranslateName(self.mother.name)
        if self.mother.relationship_ids.Spouse > -1 then 
            local spouseInfo = self:findSpouse(self.mother)
            return ('Selected mother: %s.%sShe is married to %s (%s).'):format(
                self:findName(self.mother),
                NEWLINE,
                spouseInfo[1],
                spouseInfo[2]
            )
        else 
            return ('Selected mother: %s.%sShe is unmarried.'):format(
                self:findName(self.mother),
                NEWLINE
            )
        end
    else return ('No mother selected - Must be a adult female')
    end
end

function PregnancyGui:getFatherLabel()
    if self.father or self.father_historical then 
        if self.father_historical or self.father.relationship_ids.Spouse > -1 then 
            local father = self.father or self.father_historical
            local spouseInfo = self:findSpouse(father)
            return ('Selected father: %s.%s%s is married to %s (%s).'):format(
                self:findName(father),
                NEWLINE,
                df.pronoun_type[father.sex]:gsub("^%l", string.upper),
                spouseInfo[1],
                spouseInfo[2]
            )
        else 
            return ('Selected father: %s.%s%s is unmarried.'):format(
                self:findName(self.father),
                NEWLINE,
                df.pronoun_type[self.father.sex]:gsub("^%l", string.upper)
            )
        end
    else return ('No father selected')
    end
end

function PregnancyGui:findName(unit)
    local name = dfhack.TranslateName(unit.name)
    if name ~= "" then
        return name
    else return ('Unnamed %s. (Unit id:%s)'):format(
        string.upper(df.global.world.raws.creatures.all[unit.race].name[0]),
        unit.id
    )
    end
end

function PregnancyGui:findSpouse(unit)
    local historical_spouse, spouse_loc, spouse, spouseid
    local culled = false

    --setting variables for if mother or father are local, followed by finding the father's spouse if he is not local
    if self.father == unit or self.mother == unit then
        spouseid = unit.relationship_ids.Spouse
        spouse = df.unit.find(spouseid)
    elseif self.father_historical == unit then
        for index, relation in pairs(unit.histfig_links) do
            if relation._type == df.histfig_hf_link_spousest then
                historical_spouse=df.historical_figure.find(relation.target_hf)
                if not historical_spouse then culled = true --there was an id, but there wasn't a histfig with that id (due culling)
                elseif df.global.plotinfo.site_id==historical_spouse.info.whereabouts.site then
                    spouse_loc = 'local'
                else spouse_loc = 'offsite'
                end
            end
        end
        return {dfhack.TranslateName(historical_spouse.name),spouse_loc,historical_spouse}
    end

    --if the spouse is local this should identify them:
    if spouse then
        historical_spouse = df.historical_figure.find(spouse.hist_figure_id) or false
        spouse_loc = 'local'
    end

    --if spouse is not local (offsite):
    if spouseid > -1 and not spouse then --spouse exists but isnt on the map, so search historical units:
        local historical_unit = df.historical_figure.find(unit.hist_figure_id)
        for index, relation in pairs(historical_unit.histfig_links) do
            if relation._type == df.histfig_hf_link_spousest then
                historical_spouse=df.historical_figure.find(relation.target_hf)
                if not historical_spouse then culled = true --there was an id, but there wasn't a histfig with that id (due culling)
                elseif df.global.plotinfo.site_id==historical_spouse.info.whereabouts.site then--i dont think this should ever be true
                    spouse_loc = 'local'
                else spouse_loc = 'offsite'
                end
            end
        end
    end
    if culled then 
        return {'Unknown','culled'}
    else 
        return {dfhack.TranslateName(historical_spouse.name),spouse_loc,historical_spouse}
    end
end

function PregnancyGui:CreatePregnancy()
	local genes,father_id,father_caste,father_name
    local bypass = true
    local force = self.subviews.Force:getOptionValue()

    local count = #self.msg
    for i=0, count do self.msg[i]=nil end --empty self.msg

    if self.father then
        genes=self.father.appearance.genes:new()
        father_id=self.father.hist_figure_id
        father_caste=self.father.caste
        father_name=self:findName(self.father)
    else
        genes=self.mother.appearance.genes:new()--i dont think historical figures have genes
        father_id=self.father_historical.id
        father_caste=self.father_historical.caste
        father_name=self:findName(self.father_historical)
    end

    if self.mother.pregnancy_timer > 0 then
        local og_father = df.historical_figure.find(self.mother.pregnancy_spouse)
        bypass = false
        if force and og_father then 
            table.insert(self.msg, ('SUCCESS:%sMother:%s%sFather:%s%sPrevious pregnancy with %s replaced'):format(
            NEWLINE,    
            self:findName(self.mother),
            NEWLINE, 
            father_name,
            NEWLINE,
            dfhack.TranslateName(og_father.name)
            ))
        elseif force then 
            table.insert(self.msg, ('SUCCESS:%sMother:%s%sFather:%s%sPrevious pregnancy aborted'):format(
            NEWLINE,    
            self:findName(self.mother),
            NEWLINE, 
            father_name,
            NEWLINE
            ))
        elseif og_father then
            table.insert(self.msg, ('FAILED:%s%s already pregnant with %s%s'):format(
                NEWLINE,
                self:findName(self.mother),
                dfhack.TranslateName(og_father.name),
                force
            ))
        else 
            table.insert(self.msg, ('FAILED:%s%s is already pregnant, no father is recorded'):format(
                NEWLINE,
                self:findName(self.mother)
        ))
        end
    end
    -- self.success = false
    if bypass or force then
        --TODO add GUI to select the number of months for pregnancy timer
        self.mother.pregnancy_timer=math.random(1, 13000)
        self.mother.pregnancy_caste=father_caste
        self.mother.pregnancy_spouse=father_id
        self.mother.pregnancy_genes=genes
        -- self.success = true
        if not force then
            table.insert(self.msg, ('SUCCESS:%sMother:%s%sFather:%s'):format(
                NEWLINE,
                self:findName(self.mother),
                NEWLINE,
                father_name
            ))
        end
    end
    self:updateLayout()
end

PregnancyScreen = defclass(PregnancyScreen, gui.ZScreen)
PregnancyScreen.ATTRS {
    focus_path='pregnancy',
}

function PregnancyScreen:init()
    self:addviews{PregnancyGui{}}
end

function PregnancyScreen:onDismiss()
    view = nil
end

view = view and view:raise() or PregnancyScreen{}:show()