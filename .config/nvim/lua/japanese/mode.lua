-- Define "Japanese input mode", in which the IME is enabled or disabled when entering or leaving insert mode.
local ffi = require("ffi")

ffi.cdef[[
    typedef long CFIndex;
    typedef uint32_t CFStringEncoding;
    typedef unsigned char Boolean;
    typedef const void * CFTypeRef;
    typedef const struct __CFString * CFStringRef;
    typedef const struct __CFArray * CFArrayRef;
    typedef const struct __CFDictionary * CFDictionaryRef;
    typedef struct OpaqueTISInputSource * TISInputSourceRef;

    TISInputSourceRef TISCopyCurrentKeyboardInputSource(void);
    CFArrayRef TISCreateInputSourceList(CFDictionaryRef properties, Boolean includeAllInstalled);
    int TISSelectInputSource(TISInputSourceRef inputSource);
    CFTypeRef TISGetInputSourceProperty(TISInputSourceRef inputSource, CFStringRef propertyKey);
    
    CFStringRef CFStringCreateWithCString(void *alloc, const char *cStr, CFStringEncoding encoding);
    Boolean CFStringGetCString(CFStringRef theString, char *buffer, CFIndex bufferSize, CFStringEncoding encoding);
    void CFRelease(CFTypeRef cf);
    CFIndex CFArrayGetCount(CFArrayRef theArray);
    const void * CFArrayGetValueAtIndex(CFArrayRef theArray, CFIndex idx);
]]

local carbon = ffi.load("/System/Library/Frameworks/Carbon.framework/Carbon")
local corefoundation = ffi.load("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation")
local kCFStringEncodingUTF8 = 0x08000100
local kTISPropertyInputSourceID = corefoundation.CFStringCreateWithCString(nil, "TISPropertyInputSourceID", kCFStringEncodingUTF8)

local M = {}

-- 内部用の高速切り替え関数
local function set_ime_by_id_ffi(target_id)
    local source_list = carbon.TISCreateInputSourceList(nil, false)
    if source_list == nil then return end
    
    local count = tonumber(corefoundation.CFArrayGetCount(source_list))
    for i = 0, count - 1 do
        local source = ffi.cast("TISInputSourceRef", corefoundation.CFArrayGetValueAtIndex(source_list, i))
        local property = carbon.TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
        
        if property ~= nil then
            local buf = ffi.new("char[256]")
            if corefoundation.CFStringGetCString(ffi.cast("CFStringRef", property), buf, 256, kCFStringEncodingUTF8) ~= 0 then
                if ffi.string(buf) == target_id then
                    carbon.TISSelectInputSource(source)
                    break
                end
            end
        end
    end
    corefoundation.CFRelease(source_list)
end

-- Functions to enable/disable IME

M.enable = function()
    set_ime_by_id_ffi("dev.ensan.inputmethod.azooKeyMac.Japanese")
end

M.disable = function()
    set_ime_by_id_ffi("com.apple.keylayout.ABC")
end

M.toggle_IME = function()
  vim.b.IME_autotoggle = not vim.b.IME_autotoggle
  if vim.b.IME_autotoggle then
    print('日本語入力モードON')
    if vim.fn.mode() == 'i' then
      M.enable()
    end
    -- also set keymap for FuzzyMotion, which is useful for Japanese text
    -- temporarily disabled because it resutls in an unknown error
    -- vim.api.nvim_buf_set_keymap(0, 'n', 'S',     '<cmd>FuzzyMotion<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(0, 'n', 't',     '<cmd>FuzzyMotion<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', '<cmd>FuzzyMotion<CR>', { noremap = true, silent = true })
  else
    print('日本語入力モードOFF')
    pcall(vim.api.nvim_buf_del_keymap, 0, 'n', 'S')
    pcall(vim.api.nvim_buf_del_keymap, 0, 'n', 't')
    pcall(vim.api.nvim_buf_del_keymap, 0, 'n', '<C-s>')
    if vim.fn.mode() == 'i' then
      M.disable()
    end
  end
end


vim.api.nvim_create_augroup("IME_autotoggle", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "IME_autotoggle",
  pattern = "*",
  callback = function()
    if vim.b.IME_autotoggle then
      M.enable()
    end
  end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "IME_autotoggle",
  pattern = "*",
  callback = function()
    if vim.b.IME_autotoggle then
      M.disable()
    end
  end,
})
vim.api.nvim_create_autocmd("CmdLineEnter", {
  group = "IME_autotoggle",
  pattern = [[/,\?]],
  callback = function()
    if vim.b.IME_autotoggle then
      vim.keymap.set('c', '<CR>', '<Plug>(kensaku-search-replace)<CR>')
    else
      -- set and delete to return to the default behavior
      vim.keymap.set('c', '<CR>', '<CR>')
      vim.keymap.del('c', '<CR>')
    end
  end,
})

vim.api.nvim_create_augroup("auto_ja", { clear = true })
vim.api.nvim_create_autocmd("BufRead", {
  group = "auto_ja",
  pattern = { "*/my-text/**.txt", "*/my-text/**.md", "*/obsidian/**.md" },
  callback = function()
    M.toggle_IME()
  end,
})

return M
