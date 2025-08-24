vim9script
scriptencoding utf-8

# {filetype:
#   {source: [tips1, tips2, ...]}
# }
var tips: dict<dict<list<string>>> = {}

export def CheatSheetEcho(filetype_only = v:false)
  var display_lines: list<string>

  if !filetype_only
    display_lines = GetSortedTips('_', display_lines)
  endif

  if has_key(tips, &filetype)
    display_lines = GetSortedTips(&filetype, display_lines)
  endif

  if !empty(display_lines)
    echo join(display_lines, "\n")
  endif
enddef
def GetSortedTips(filetype: string, list: list<string>): list<string>
  var sortedlist = list
  if filetype !=# '_'
    extend(sortedlist, ['', $'[{filetype}]'])
  endif
  for k in keys(tips[filetype])->sort()
    extend(sortedlist, tips[filetype][k])
  endfor
  return sortedlist
enddef

# Avoid adding duplicate 'addlist' from the same 'source'
export def CheatSheetEchoAdd(addlist: list<string>, filetype = '_', source = '_')
  tips[filetype] = get(tips, filetype, {})
  if !has_key(tips[filetype], source)
    tips[filetype][source] = addlist
  endif
enddef

export def CheatSheetEchoItems(): dict<dict<list<string>>>
  return tips
enddef
