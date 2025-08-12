vim9script
scriptencoding utf-8

var tips: dict<dict<list<string>>> = {}

export def CheatSheetEcho(filetype_only = v:false)
  var list: list<string>
  if !filetype_only
    list = GetSortedList(tips['_'], list)
  endif
  if has_key(tips, &filetype)
    list = GetSortedList(tips[&filetype], list)
  endif
  echo join(list, "\n")
enddef
def GetSortedList(hint_dict: dict<list<string>>, list: list<string>): list<string>
  var sortedlist: list<string>
  var sorted_keys = keys(hint_dict)
  sort(sorted_keys)
  for k in sorted_keys
    extend(sortedlist, hint_dict[k])
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
