local vmf = get_mod("VMF")

--[[
English (en)
French (fr)
German (de)
Spanish (es)
Russian (ru)
Portuguese-Brazil (br-pt)
Italian (it)
Polish (pl)
]]

local _LANGUAGE_ID = Application.user_setting("language_id")
local _LOCALIZATION_DATABASE = {}

-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################

local function safe_string_format(mod, str, ...)

  -- the game still crash with unknown error if there is non-standard character after '%'
  local success, message = pcall(string.format, str, ...)

  if success then
    return message
  else
    mod:error("(localize) \"%s\": %s", tostring(str), tostring(message))
  end
end

-- ####################################################################################################################
-- ##### VMFMod #######################################################################################################
-- ####################################################################################################################

VMFMod.localization = function (self, path)

  local success, value = pcall(dofile, path)

  if not success then
    self:error("(localization): %s", value.error)
    return
  end

  if type(value) ~= "table" then
    self:error("(localization): localization file should return table")
    return
  end

  if _LOCALIZATION_DATABASE[self:get_name()] then
    self:warning("(localization): overwritting already loaded localization file")
  end

  _LOCALIZATION_DATABASE[self:get_name()] = value
end


VMFMod.localize = function (self, text_id, ...)

  local mod_localization_table = _LOCALIZATION_DATABASE[self:get_name()]
  if mod_localization_table then

    local text_translations = mod_localization_table[text_id]
    if text_translations then

      local message

      if text_translations[_LANGUAGE_ID] then

        message = safe_string_format(self, text_translations[_LANGUAGE_ID], ...)
        if message then
          return message
        end
      end

      if text_translations["en"] then

        message = safe_string_format(self, text_translations["en"], ...)
        if message then
          return message
        end
      end
    end

    return "<" .. tostring(text_id) .. ">"
  else
    self:error("(localize): localization file was not loaded for this mod")
  end
end

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

vmf:localization("localization/vmf")