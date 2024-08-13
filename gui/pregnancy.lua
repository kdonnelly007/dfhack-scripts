local gui = require('gui')
local widgets = require('gui.widgets')

local function zoom_to(unit)
    if not unit then return end
    dfhack.gui.revealInDwarfmodeMap(xyz2pos(dfhack.units.getPosition(unit)), true, true)
end

local function is_viable_partner(unit, required_pronoun)
    return unit and unit.sex == required_pronoun and dfhack.units.isAdult(unit)
end

----------------------
-- Pregnancy
--

Pregnancy = defclass(Pregnancy, widgets.Window)
Pregnancy.ATTRS {
    frame_title='Pregnancy manager',
    frame={w=50, h=28, r=2, t=18},
    resizable=true,
}

function Pregnancy:init()
    self.cache = {}
    self.mother_id, self.father_id = -1, -1
    self.dirty = 0

    self:addviews{
        widgets.Label{
            frame={t=0, l=0},
            text='Mother:',
        },
        widgets.Label{
            frame={t=0, l=8},
            text='None (please select an adult female)',
            text_pen=COLOR_YELLOW,
            visible=function() return not self:get_mother() end,
        },
        widgets.Label{
            frame={t=0, l=8},
            text={{text=self:callback('get_name', 'mother')}},
            text_pen=COLOR_LIGHTMAGENTA,
            auto_width=true,
            on_click=function() zoom_to(self:get_mother()) end,
            visible=self:callback('get_mother'),
        },
        widgets.Label{
            frame={t=1, l=0},
            text={{text=self:callback('get_pregnancy_desc')}},
        },
        widgets.Label{
            frame={t=3, l=0},
            text='Spouse:',
        },
        widgets.Label{
            frame={t=3, l=8},
            text='None',
            visible=function() return not self:get_spouse_unit('mother') and not self:get_spouse_hf('mother') end,
        },
        widgets.Label{
            frame={t=3, l=8},
            text={{text=self:callback('get_spouse_name', 'mother')}},
            text_pen=COLOR_BLUE,
            auto_width=true,
            on_click=function() zoom_to(self:get_spouse_unit('mother')) end,
            visible=self:callback('get_spouse_unit', 'mother'),
        },
        widgets.Label{
            frame={t=3, l=8},
            text={
                {text=self:callback('get_spouse_hf_name', 'mother')},
                ' (off-site)',
            },
            text_pen=COLOR_BLUE,
            auto_width=true,
            visible=function() return not self:get_spouse_unit('mother') and self:get_spouse_hf('mother') end,
        },
        widgets.HotkeyLabel{
            frame={t=4, l=2},
            label="Set mother's spouse as the father",
            key='CUSTOM_F',
            auto_width=true,
            on_activate=function() self:set_father(self:get_spouse_unit('mother')) end,
            enabled=function()
                local spouse = self:get_spouse_unit('mother')
                return spouse and spouse.id ~= self.father_id and is_viable_partner(spouse, df.pronoun_type.he)
            end,
        },
        widgets.HotkeyLabel{
            frame={t=6, l=0},
            label="Set mother to selected unit",
            key='CUSTOM_SHIFT_M',
            auto_width=true,
            on_activate=self:callback('set_mother'),
            enabled=function()
                local unit = dfhack.gui.getSelectedUnit(true)
                return unit and unit.id ~= self.mother_id and is_viable_partner(unit, df.pronoun_type.she)
            end,
        },
        widgets.Divider{
            frame={t=8, h=1},
            frame_style=gui.FRAME_THIN,
            frame_style_l=false,
            frame_style_r=false,
        },
        widgets.Label{
            frame={t=10, l=0},
            text='Father:',
        },
        widgets.Label{
            frame={t=10, l=8},
            text={
                'None ',
                {text='(optionally select an adult male)', pen=COLOR_GRAY},
            },
            visible=function() return not self:get_father() end,
        },
        widgets.Label{
            frame={t=10, l=8},
            text={{text=self:callback('get_name', 'father')}},
            text_pen=function()
                local spouse = self:get_spouse_unit('mother')
                if spouse and self.father_id == spouse.id then
                    return COLOR_BLUE
                end
                return COLOR_CYAN
            end,
            auto_width=true,
            on_click=function() zoom_to(self:get_father()) end,
            visible=self:callback('get_father'),
        },
        widgets.Label{
            frame={t=12, l=0},
            text='Spouse:',
        },
        widgets.Label{
            frame={t=12, l=8},
            text='None',
            visible=function() return not self:get_spouse_unit('father') and not self:get_spouse_hf('father') end,
        },
        widgets.Label{
            frame={t=12, l=8},
            text={{text=self:callback('get_spouse_name', 'father')}},
            text_pen=function()
                local spouse = self:get_spouse_unit('father')
                if spouse and self.mother_id == spouse.id then
                    return COLOR_LIGHTMAGENTA
                end
                return COLOR_CYAN
            end,
            auto_width=true,
            on_click=function() zoom_to(self:get_spouse_unit('father')) end,
            visible=self:callback('get_spouse_unit', 'father'),
        },
        widgets.Label{
            frame={t=12, l=8},
            text={
                {text=self:callback('get_spouse_hf_name', 'father')},
                ' (off-site)',
            },
            text_pen=COLOR_CYAN,
            auto_width=true,
            visible=function() return not self:get_spouse_unit('father') and self:get_spouse_hf('father') end,
        },
        widgets.HotkeyLabel{
            frame={t=13, l=2},
            label="Set father's spouse as the mother",
            key='CUSTOM_M',
            auto_width=true,
            on_activate=function() self:set_mother(self:get_spouse_unit('father')) end,
            enabled=function()
                local spouse = self:get_spouse_unit('father')
                return spouse and spouse.id ~= self.mother_id and is_viable_partner(spouse, df.pronoun_type.she)
            end,
        },
        widgets.HotkeyLabel{
            frame={t=15, l=0},
            label="Set father to selected unit",
            key='CUSTOM_SHIFT_F',
            auto_width=true,
            on_activate=self:callback('set_father'),
            enabled=function()
                local unit = dfhack.gui.getSelectedUnit(true)
                return unit and unit.id ~= self.father_id and is_viable_partner(unit, df.pronoun_type.he)
            end,
        },
        widgets.Divider{
            frame={t=17, h=1},
            frame_style=gui.FRAME_THIN,
            frame_style_l=false,
            frame_style_r=false,
        },
        widgets.CycleHotkeyLabel{
            view_id='term',
            frame={t=19, l=0, w=40},
            label='Pregnancy term (in months):',
            key_back='CUSTOM_SHIFT_Z',
            key='CUSTOM_Z',
            options={
                {label='Default', value='default', pen=COLOR_BROWN},
                {label='0', value=0, pen=COLOR_BROWN},
                {label='1', value=1, pen=COLOR_BROWN},
                {label='2', value=2, pen=COLOR_BROWN},
                {label='3', value=3, pen=COLOR_BROWN},
                {label='4', value=4, pen=COLOR_BROWN},
                {label='5', value=5, pen=COLOR_BROWN},
                {label='6', value=6, pen=COLOR_BROWN},
                {label='7', value=7, pen=COLOR_BROWN},
                {label='8', value=8, pen=COLOR_BROWN},
                {label='9', value=9, pen=COLOR_BROWN},
                {label='10', value=10, pen=COLOR_BROWN},
            },
            initial_option='default',
        },
        widgets.Panel{
            frame={t=21, w=23, h=3},
            frame_style=gui.FRAME_INTERIOR,
            subviews={
                widgets.HotkeyLabel{
                    key='CUSTOM_SHIFT_P',
                    label="Generate pregnancy",
                    on_activate=self:callback('commit'),
                    enabled=function() return self:get_mother() end,
                },
            }
        },
    }

    local unit = dfhack.gui.getSelectedUnit(true)
    self:set_mother(unit)
    self:set_father(unit)
end

function Pregnancy:get_mother()
    self.cache.mother = self.cache.mother or df.unit.find(self.mother_id)
    return self.cache.mother
end

function Pregnancy:get_father()
    self.cache.father = self.cache.father or df.unit.find(self.father_id)
    return self.cache.father
end

function Pregnancy:render(dc)
    if self.dirty > 0 then
        -- needs multiple iterations of updateLayout because of multiple
        -- layers of indirection in the text generation
        self:updateLayout()
        self.dirty = self.dirty - 1
    end
    Pregnancy.super.render(self, dc)
    self.cache = {}
end

function Pregnancy:get_name(who)
    local unit = self['get_'..who](self)
    return unit and dfhack.units.getReadableName(unit) or ''
end

local TICKS_PER_DAY = 1200
local TICKS_PER_MONTH = 28 * TICKS_PER_DAY

function Pregnancy:get_pregnancy_desc()
    local mother = self:get_mother()
    if not mother or not mother.pregnancy_genes then return 'Not currently pregnant' end
    local term_str = 'today'
    if mother.pregnancy_timer > TICKS_PER_MONTH then
        local num_months = (mother.pregnancy_timer + TICKS_PER_MONTH//2) // TICKS_PER_MONTH
        term_str = ('in %d month%s'):format(num_months, num_months == 1 and '' or 's')
    elseif mother.pregnancy_timer > TICKS_PER_DAY then
        local num_days = (mother.pregnancy_timer + TICKS_PER_DAY//2) // TICKS_PER_DAY
        term_str = ('in %d day%s'):format(num_days, num_days == 1 and '' or 's')
    end
    return ('Currently pregnant: coming to term %s'):format(term_str)
end

function Pregnancy:get_spouse_unit(who)
    local unit = self['get_'..who](self)
    if not unit then return end
    return df.unit.find(unit.relationship_ids.Spouse)
end

function Pregnancy:get_spouse_hf(who)
    local unit = self['get_'..who](self)
    if not unit or unit.relationship_ids.Spouse == -1 then
        return
    end
    local spouse = df.unit.find(unit.relationship_ids.Spouse)
    if spouse then
        return df.historical_figure.find(spouse.hist_figure_id)
    end

    for _, relation in ipairs(unit.histfig_links) do
        if relation._type == df.histfig_hf_link_spousest then
            -- may be nil due to hf culling, but then we just treat it as not having a spouse
            return df.historical_figure.find(relation.target_hf)
        end
    end
end

function Pregnancy:get_spouse_name(who)
    local spouse = self:get_spouse_unit(who)
    return spouse and dfhack.units.getReadableName(spouse) or ''
end

function Pregnancy:get_spouse_hf_name(who)
    local spouse_hf = self:get_spouse_hf(who)
    return spouse_hf and dfhack.units.getReadableName(spouse_hf) or ''
end

function Pregnancy:set_mother(unit)
    unit = unit or dfhack.gui.getSelectedUnit(true)
    if not is_viable_partner(unit, df.pronoun_type.she) then return end
    self.mother_id = unit.id
    if self.father_id ~= -1 then
        local father = self:get_father()
        if not father or father.race ~= unit.race then
            self.father_id = -1
        end
    end
    if self.father_id == -1 then
        self:set_father(self:get_spouse_unit('mother'))
    end
    self.dirty = 2
end

function Pregnancy:set_father(unit)
    unit = unit or dfhack.gui.getSelectedUnit(true)
    if not is_viable_partner(unit, df.pronoun_type.he) then return end
    self.father_id = unit.id
    if self.mother_id ~= -1 then
        local mother = self:get_mother()
        if not mother or mother.race ~= unit.race then
            self.mother_id = -1
        end
    end
    if self.mother_id == -1 then
        self:set_mother(self:get_spouse_unit('father'))
    end
    self.dirty = 2
end

local function get_term_ticks(months)
    local ticks = months * TICKS_PER_MONTH
    -- subtract off a random amount between 0 and half a month
    ticks = math.max(1, ticks - math.random(0, TICKS_PER_MONTH//2))
    return ticks
end

function Pregnancy:commit()
    local mother = self:get_mother()
    local father = self:get_father() or mother

    local term_months = self.subviews.term:getOptionValue()
    if term_months == 'default' then
        local caste_flags = mother.enemy.caste_flags
        if caste_flags.CAN_SPEAK or caste_flags.CAN_LEARN then
            term_months = 9
        else
            term_months = 6
        end
    end

    if mother.pregnancy_genes then
        mother.pregnancy_genes:assign(father.appearance.genes)
    else
        mother.pregnancy_genes = father.appearance.genes:new()
    end

    mother.pregnancy_timer = get_term_ticks(term_months)
    mother.pregnancy_caste = father.caste
    mother.pregnancy_spouse = father.hist_figure_id ~= mother.hist_figure_id and father.hist_figure_id or -1

    self.dirty = 2
end

----------------------
-- PregnancyScreen
--

PregnancyScreen = defclass(PregnancyScreen, gui.ZScreen)
PregnancyScreen.ATTRS {
    focus_path='pregnancy',
}

function PregnancyScreen:init()
    self:addviews{Pregnancy{}}
end

function PregnancyScreen:onDismiss()
    view = nil
end

view = view and view:raise() or PregnancyScreen{}:show()
