vim9script
scriptencoding utf-8

# データ構造の定義
# tips_data = {
#   filetype: [
#     {tips: ['title\tdesc', 'title\tdesc', ...],
#      source: 'str',
#      category: 'str',
#     },
#     ...
#   ]
# }
var tips_data: dict<list<dict<any>>> = {}

#--- Public Functions ---#
export def CheatSheetEcho(filetype_only = false)
  var display_lines: list<string>

  if !filetype_only
    display_lines = GetSortedTips('_', display_lines)
  endif

  if has_key(tips_data, &filetype)
    display_lines = GetSortedTips(&filetype, display_lines)
  endif

  if !empty(display_lines)
    echo join(TabAlign(display_lines), "\n")
  endif
enddef

# Avoid adding duplicate 'addlist' from the same 'source'
export def CheatSheetEchoAdd(addlist: list<string>, filetype: string = '_', source: string = '_', category: string = '_')
  tips_data[filetype] = get(tips_data, filetype, [])
  # tips_data[filetype] に tips_data[filetype][source] == source, tips_data[filetype][category] == category があればスキップ
  # var resolved_category = (category == '_') ? source : category
  var resolved_category = category
  for filetypeTips in tips_data[filetype]
    if filetypeTips.source == source && filetypeTips.category == resolved_category
      # already added
      return
    endif
  endfor

  tips_data[filetype] += [{tips: addlist, source: source, category: resolved_category}]
enddef

export def CheatSheetEchoItems(): dict<list<dict<any>>>
  return tips_data
enddef

export def GetCheatSheetEchoList(filetype_only = false): list<string>
  var display_lines: list<string>

  if !filetype_only
    display_lines = GetSortedTips('_', display_lines)
  endif

  if has_key(tips_data, &filetype)
    display_lines = GetSortedTips(&filetype, display_lines)
  endif

  return display_lines
enddef

#--- Private Functions ---#
def GetSortedTips(filetype: string, currentLines: list<string>): list<string>
  var sortedLines = currentLines

  # Display [filetype] except for _
  if filetype !=# '_'
    sortedLines += ['', $'[{filetype}]']
  endif

  var priorityLines: list<string> = []
  var categoryDict: dict<list<string>> = {}
  for filetypeTips in tips_data[filetype]
    # _ is displayed at the beginning.
    if filetypeTips.category == '_' && filetypeTips.source == '_'
      priorityLines += filetypeTips.tips
    elseif filetypeTips.category == '_'
      priorityLines += filetypeTips.tips
    else
      categoryDict[filetypeTips.category] = get(categoryDict, filetypeTips.category, [])
      categoryDict[filetypeTips.category] += filetypeTips.tips
    endif
  endfor
  sortedLines += priorityLines
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
      max_len = max([max_len, strdisplaywidth(parts[0])])
    elseif max_len != 0
      result->extend(AlignGroup(group, max_len))
      group = []
      max_len = 0
    endif
    group->add(line)
  endfor
  if !empty(group)
    result->extend(AlignGroup(group, max_len))
  endif

  return result
enddef
# グループ内のテキストを整形する
def AlignGroup(group: list<string>, max_len: number): list<string>
  return group->mapnew((_, line) => {
    if line !~ "\t"
      return line
    endif

    var parts = split(line, "\t")
    var padding = max_len - strdisplaywidth(parts[0]) + 2
    return $'{parts[0]}{repeat(" ", padding)}{join(parts[1 : ], "\t")}'
  })
enddef

