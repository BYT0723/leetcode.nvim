local log = require("leetcode.logger")

local Group = require("leetcode-ui.component.group")
local Text = require("leetcode-ui.component.text")
local Case = require("leetcode.ui.console.components.case")

local NuiLine = require("nui.line")

---@class lc.Cases : lc-ui.Group
---@field nav lc-ui.Text
---@field case lc-ui.Group
---@field cases table<integer, lc.Result.Case>
---@field keymaps table<string, function> { mode: string, key: string }
---@field idx integer
---@field parent lc.ui.Console.ResultPopup
local Cases = {}
Cases.__index = Cases
setmetatable(Cases, Group)

function Cases:clear()
    self.parent:clear_keymaps(self.keymaps)
    self.keymaps = {}
    self.cases = {}
    self.nav:clear()
    self.case:clear()
    Group.clear(self)
end

function Cases:update_nav()
    local cases = NuiLine()

    for i, case in ipairs(self.cases) do
        local text = NuiLine()
        local hl = ("%s%s"):format(self.idx == i and "focus_" or "", case.passed and "ok" or "err")
        text:append((" Case (%d) "):format(i), "leetcode_case_" .. hl)

        self.keymaps[tostring(i)] = function() self:change(i) end

        cases:append(text)
        if i ~= #self.cases then cases:append(" ") end
    end

    self.parent:set_keymaps(self.keymaps)
    self.nav.lines = { cases }
end

---@param idx integer
function Cases:change(idx)
    if not self.cases[idx] or idx == self.idx then return end
    self.case.groups = { self.cases[idx] }
    self.idx = idx
    self:update_nav()
    self.parent:draw()
end

---@param item lc.runtime
---@param testcases string[]
---@param parent lc.ui.Console.ResultPopup
---@return lc.Cases
function Cases:init(item, testcases, parent)
    local group = Group:init({}, { spacing = 1 })
    self = setmetatable(group, self)

    self.cases = {}
    self.parent = parent
    self.keymaps = {}

    for i, answer in ipairs(item.code_answer) do
        self.cases[i] = Case:init({
            input = testcases[i],
            output = answer,
            expected = item.expected_code_answer[i],
            std_output = item.std_output_list[i],
        }, item.compare_result:sub(i, i) == "1")
    end

    self.nav = Text({ padding = { top = 1, bot = 0 } })
    self:append(self.nav)

    self.case = Group()
    self:append(self.case)
    self:change(1)

    return self ---@diagnostic disable-line
end

return Cases
