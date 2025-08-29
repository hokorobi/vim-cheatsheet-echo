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
    sortedlist += ['', $'[{filetype}]']
  endif
  for k in keys(tips[filetype])->sort()
    sortedlist += tips[filetype][k]
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
    elseif max_len != 0
      result += TabAlignGroup(group, max_len)
      group = []
      max_len = 0
    endif
    group += [line]
  endfor
  if !empty(group)
    result += TabAlignGroup(group, max_len)
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
    var right_part = parts[-1]
    var padding = max_len - strlen(left_part) + 1
    result += [$'{left_part}{repeat(' ', padding)}{right_part}']
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
