---@diagnostic disable: undefined-field, no-unknown
local eq = assert.are.same
describe("mods", function()
    it("should load the module", function()
        local mods = require("mods")
        print(mods)
        eq(1, 1)
    end)
end)
