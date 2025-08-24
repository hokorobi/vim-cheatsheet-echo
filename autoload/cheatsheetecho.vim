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
    display_lines = TabAlign(display_lines)
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
def TabAlign(a: list<string>): list<string>
  var max_len = 0
  var temp_list: list<string> = []
  var result: list<string> = []

  # <tab>の左側の最大バイト数を調査
  for s in a
    if s =~ '\t'
      var parts = split(s, '\t')
      var left_part = parts[0]
      var len = strlen(left_part)
      if len > max_len
        max_len = len
      endif
    else
      if max_len != 0
        extend(result, TabAlignAlign(temp_list, max_len))
        temp_list = []
        max_len = 0
      endif
    endif
    temp_list = add(temp_list, s)
  endfor
  if !empty(temp_list)
    extend(result, temp_list)
  endif

  return result
enddef
def TabAlignAlign(a: list<string>, max_len: number): list<string>
  var result: list<string> = []

  for s in a
    if s !~ '\t'
      result = add(result, s)
      continue
    endif

    var parts = split(s, '\t')
    var left_part = parts[0]
    var left_len = strlen(left_part)
    var padding_needed = max_len - left_len + 1
    var padding = repeat(' ', padding_needed)
    result = add(result, left_part .. padding .. parts[-1])
  endfor

  return result
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
