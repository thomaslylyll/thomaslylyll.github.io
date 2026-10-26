-- One shared counter for all numbered results (theorems, definitions, propositions,
-- lemmas, corollaries, examples, ...) within a chapter, instead of one counter per kind.
-- Runs after Quarto has numbered everything, and rewrites "Definition 4.1" -> "Definition 4.3".
-- Also updates the number shown in @-references to results on the same page.

local function renumber(doc)
  local counter = 0
  local new_number = {} -- id -> new "chapter.n" string

  doc = doc:walk({
    Div = function(div)
      if not div.classes:includes("theorem") then return nil end
      local para = div.content[1]
      if not para or para.t ~= "Para" then return nil end
      local title = para.content[1]
      if not title or title.t ~= "Span" or not title.classes:includes("theorem-title") then return nil end

      counter = counter + 1
      return div:walk({
        Str = function(s)
          local chapter = s.text:match("^(%d+)%.%d+$")
          if chapter and not new_number[div.identifier] then
            new_number[div.identifier] = chapter .. "." .. counter
            return pandoc.Str(new_number[div.identifier])
          end
        end,
      })
    end,
  })

  return doc:walk({
    Link = function(link)
      if not link.classes:includes("quarto-xref") then return nil end
      local id = link.target:match("^#(.+)$")
      if not id or not new_number[id] then return nil end
      return link:walk({
        Str = function(s)
          if s.text:match("^%d+%.%d+$") then return pandoc.Str(new_number[id]) end
        end,
      })
    end,
  })
end

return { { Pandoc = renumber } }
