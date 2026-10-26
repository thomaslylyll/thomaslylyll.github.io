-- Keep line breaks as written in the notes (each source line renders on its own line),
-- except next to display math, which already sits on its own line.
local function is_display_math(el)
  return el ~= nil and el.t == "Math" and el.mathtype == "DisplayMath"
end

function Inlines(inlines)
  for i = 1, #inlines do
    if inlines[i].t == "SoftBreak"
        and not is_display_math(inlines[i - 1])
        and not is_display_math(inlines[i + 1]) then
      inlines[i] = pandoc.LineBreak()
    end
  end
  return inlines
end
