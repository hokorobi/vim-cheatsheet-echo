vim9script
scriptencoding utf-8

# {filetype: [
#    {tips: [tips1, tips2, ...],
#     source: hoge,
#     category: piyo,
#    },
#    {tips: [tips1, tips2, ...],
#     source: hoge,
#     category: piyo,
#    },
#    ...
#  ]}
# tips: title	description
var tips: dict<list<any>> = {}

#--- Public Functions ---#
export def CheatSheetEcho(filetype_only = v:false)
  var display_lines: list<string>

  if !filetype_only
    display_lines = GetSortedTips('_', display_lines)
  endif

  if has_key(tips, &filetype)
    display_lines = GetSortedTips(&filetype, display_lines)
  endif

  if !empty(display_lines)
    echo join(TabAlign(display_lines), "\n")
  endif
enddef

# Avoid adding duplicate 'addlist' from the same 'source'
export def CheatSheetEchoAdd(addlist: list<string>, filetype: string = '_', source: string = '_', category: string = '_')
  tips[filetype] = get(tips, filetype, [])
  # tips[filetype] に tips[filetype][source] == source, tips[filetype][category] == category があれば上書き
  for filetypeTips in tips[filetype]
    if filetypeTips.source == source && filetypeTips.category == category
      # already added
      return
    endif
  endfor

  var resolved_category = (category == '_') ? source : category
  tips[filetype] += [{tips: addlist, source: source, category: resolved_category}]
enddef

export def CheatSheetEchoItems(): dict<list<any>>
  return tips
enddef

#--- Private Functions ---#
def GetSortedTips(filetype: string, currentLines: list<string>): list<string>
  var sortedLines = currentLines

  # Display [filetype] except for _
  if filetype !=# '_'
    sortedLines += ['', $'[{filetype}]']
  endif

  var categoryFirstLines: list<string> = []
  var categoryDict: dict<list<string>> = {}
  for filetypeTips in tips[filetype]
    # _ is displayed at the beginning.
    if filetypeTips.category == '_' && filetypeTips.source == '_'
      categoryFirstLines += filetypeTips.tips
    elseif filetypeTips.category == '_'
      categoryFirstLines += filetypeTips.tips
    else
      categoryDict[filetypeTips.category] = get(categoryDict, filetypeTips.category, [])
      categoryDict[filetypeTips.category] += filetypeTips.tips
    endif
  endfor
  sortedLines += categoryFirstLines
  for category in keys(categoryDict)->sort()
    if filetype != category
      sortedLines += ['', $'[{category}]']
    endif
    sortedLines += categoryDict[category]
  endfor

  return sortedLines
enddef

def TabAlign(lines: list<string>): list<string>
  var result: list<string> = []
  var max_len = 0
  var group: list<string> = []

  # Investigate max bytes to the left of tab
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
    var right_part = join(parts[1 : ], "\t")
    var padding = max_len - strlen(left_part) + 1
    result += [$'{left_part}{repeat(' ', padding)}{right_part}']
  endfor

  return result
enddef

