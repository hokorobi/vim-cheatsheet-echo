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
def TabAlign(lines: list<string>): list<string>
  var max_len = 0
  var group: list<string> = []
  var result: list<string> = []

  # <tab>の左側の最大バイト数を調査
  for line in lines
    if line =~ '\t'
      var parts = split(line, '\t')
      var len = strlen(parts[0])
      max_len = max([max_len, len])
    else
      if max_len != 0
        extend(result, TabAlignGroup(group, max_len))
        group = []
        max_len = 0
      endif
    endif
    group = add(group, line)
  endfor
  if !empty(group)
    extend(result, group)
  endif

  return result
enddef
def TabAlignGroup(group: list<string>, max_len: number): list<string>
  var result: list<string> = []

  for line in group
    if line !~ '\t'
      result = add(result, line)
      continue
    endif

    var parts = split(line, '\t')
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
