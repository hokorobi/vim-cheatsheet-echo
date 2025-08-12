vim9script
scriptencoding utf-8

var tips: dict<dict<list<string>>> = {}

export def CheatSheetEcho(filetype_only = v:false)
  var list: list<string>
  var sorted_keys: list<string>
  if !filetype_only
    sorted_keys = keys(tips['_'])
    sort(sorted_keys)
    for k in sorted_keys
      extend(list, tips['_'][k])
    endfor
  endif
  if has_key(tips, &filetype)
    sorted_keys = keys(tips[&filetype])
    sort(sorted_keys)
    for k in sorted_keys
      extend(list, extend(['', $'[{&filetype}]'], tips[&filetype][k]))
    endfor
  endif
  echo join(list, "\n")
enddef

# Avoid adding duplicate 'addlist' from the same 'source'
export def CheatSheetEchoAdd(addlist: list<string>, filetype = '_', source = '_')
  if has_key(tips, filetype)
    if !has_key(tips[filetype], source)
      tips[filetype][source] = addlist
    endif
  else
    tips[filetype] = {}
    tips[filetype][source] = addlist
  endif
enddef

export def CheatSheetEchoItems(): dict<dict<list<string>>>
  return tips
enddef
