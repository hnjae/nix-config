{
  plugins.cmp = {
    autoEnableSources = true;
    enable = true;
    settings = {
      sources = [
        { name = "path"; }
        { name = "buffer"; }
        # { name = "tmux"; }
      ];
      mapping = {
        __raw = ''
          cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_next_item()
              else
                cmp.complete()
              end
            end, { "i" }),
            ["<C-p>"] = cmp.mapping(function()
              if cmp.visible() then
                cmp.select_prev_item()
              else
                cmp.complete()
              end
            end, { "i" }),
          })
        '';
      };
      formatting = {
        format = ''
          function(entry, item)
            item.menu = string.format("[%s]", entry.source.name)
            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }

            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
              end
            end

            return item
          end
        '';
      };
      cmdline = {
        "/" = {
          mapping = {
            __raw = "cmp.mapping.preset.cmdline()";
          };
          sources = [
            { name = "buffer"; }
          ];
        };
        ":" = {
          mapping = {
            __raw = "cmp.mapping.preset.cmdline()";
          };
          sources = [
            { name = "path"; }
            {
              name = "cmdline";
              option = {
                ignore_cmds = [
                  "Man"
                  "!"
                ];
              };
            }
          ];
        };
      };
    };
  };
}
