vim.g.snacks_animate = false

-- SSH 越しのときは yank を OSC 52 で接続元のクリップボードに送る。
-- Neovim 0.10+ の自動検出は「pbcopy/xclip 等が無い」かつ「tmux を挟まない」
-- ときしか効かないので (:h clipboard-osc52)、SSH セッションでは明示する。
-- ローカル起動では何もしない (既定の pbcopy/wl-copy 等のまま)。
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- OSC 52 での読み出しは多くの端末が拒否し、組み込みの paste は応答を最大 10 秒
  -- 待ってしまう。端末には問い合わせず、最後に送った内容を返すだけにする。
  local last = { ["+"] = { {}, "v" }, ["*"] = { {}, "v" } }
  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      last[reg] = { lines, regtype }
      send(lines, regtype)
    end
  end
  local function paste(reg)
    return function()
      return last[reg]
    end
  end
  vim.g.clipboard = {
    name = "OSC 52 (ssh)",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
  -- LazyVim は SSH 中は clipboard を空にする (素の yy がプロバイダを通らず、
  -- OSC 52 が一度も出ない)。ここでは明示プロバイダがあるので同期を戻す。
  vim.opt.clipboard = "unnamedplus"
end
