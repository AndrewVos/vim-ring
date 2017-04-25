if exists("g:loaded_ring")
  finish
endif
let g:loaded_ring = 1

let s:irregulars = []
call add(s:irregulars, ["person", "people"])
call add(s:irregulars, ["man", "men"])
call add(s:irregulars, ["child", "children"])
call add(s:irregulars, ["sex", "sexes"])
call add(s:irregulars, ["move", "moves"])
call add(s:irregulars, ["zombie", "zombies"])

let s:uncountables = ['equipment', 'information', 'rice', 'money', 'species', 'series', 'fish', 'sheep', 'jeans', 'police']

let s:singulars = []
call add(s:singulars, ['\(database\)s$', '\1'])
call add(s:singulars, ['\(quiz\)zes$', '\1'])
call add(s:singulars, ['\(matr\)ices$', '\1ix'])
call add(s:singulars, ['\(vert\|ind\)ices$', '\1ex'])
call add(s:singulars, ['^\(ox\)en', '\1'])
call add(s:singulars, ['\(alias\|status\)\(es\)?$', '\1'])
call add(s:singulars, ['\(octop\|vir\)\(us\|i\)$', '\1us'])
call add(s:singulars, ['^\(a\)x[ie]s$', '\1xis'])
call add(s:singulars, ['\(cris\|test\)\(is\|es\)$', '\1is'])
call add(s:singulars, ['\(shoe\)s$', '\1'])
call add(s:singulars, ['\(o\)es$', '\1'])
call add(s:singulars, ['\(bus\)\(es\)?$', '\1'])
call add(s:singulars, ['^\(m\|l\)ice$', '\1ouse'])
call add(s:singulars, ['\(x\|ch\|ss\|sh\)es$', '\1'])
call add(s:singulars, ['\(m\)ovies$', '\1ovie'])
call add(s:singulars, ['\(s\)eries$', '\1eries'])
call add(s:singulars, ['\([^aeiouy]\|qu\)ies$', '\1y'])
call add(s:singulars, ['\([lr]\)ves$', '\1f'])
call add(s:singulars, ['\(tive\)s$', '\1'])
call add(s:singulars, ['\(hive\)s$', '\1'])
call add(s:singulars, ['\([^f]\)ves$', '\1fe'])
call add(s:singulars, ['\(^analy\)\(sis\|ses\)$', '\1sis'])
call add(s:singulars, ['\(\(a\)naly\|\(b\)a\|\(d\)iagno\|\(p\)arenthe\|\(p\)rogno\|\(s\)ynop\|\(t\)he\)\(sis\|ses\)$', '\1sis'])
call add(s:singulars, ['\([ti]\)a$', '\1um'])
call add(s:singulars, ['\(n\)ews$', '\1ews'])
call add(s:singulars, ['\(ss\)$', '\1'])
call add(s:singulars, ['s$', ""])

let s:plurals = []
call add(s:plurals, ['\(quiz\)$', '\1zes'])
call add(s:plurals, ['^\(oxen\)$', '\1'])
call add(s:plurals, ['^\(ox\)$', '\1en'])
call add(s:plurals, ['^\(m\|l\)ice$', '\1ice'])
call add(s:plurals, ['^\(m\|l\)ouse$', '\1ice'])
call add(s:plurals, ['\(matr\|vert\|ind\)\(?:ix\|ex\)$', '\1ices'])
call add(s:plurals, ['\(x\|ch\|ss\|sh\)$', '\1es'])
call add(s:plurals, ['\([^aeiouy]\|qu\)y$', '\1ies'])
call add(s:plurals, ['\(hive\)$', '\1s'])
call add(s:plurals, ['\(?:\([^f]\)fe\|\([lr]\)f\)$', '\1\2ves'])
call add(s:plurals, ['sis$', "ses"])
call add(s:plurals, ['\([ti]\)a$', '\1a'])
call add(s:plurals, ['\([ti]\)um$', '\1a'])
call add(s:plurals, ['\(buffal\|tomat\)o$', '\1oes'])
call add(s:plurals, ['\(bu\)s$', '\1ses'])
call add(s:plurals, ['\(alias\|status\)$', '\1es'])
call add(s:plurals, ['\(octop\|vir\)i$', '\1i'])
call add(s:plurals, ['\(octop\|vir\)us$', '\1i'])
call add(s:plurals, ['^\(ax\|test\)is$', '\1es'])
call add(s:plurals, ['s$', "s"])
call add(s:plurals, ['$', "s"])

function! s:CalculateResourceName()
  let file = @%
  if file =~ 'app\/models/.*\.rb'
    let singular = substitute(file, 'app\/models\/', '', '')
    let singular = substitute(singular, '\.rb', '', '')
    return singular
  elseif file =~ 'app\/views\/.*\/'
    let plural = substitute(file, 'app\/views\/', '', '')
    let plural = substitute(plural, '\/.*', '', '')
    return s:Singularise(plural)
  elseif file =~ 'app\/controllers\/.*_controller.rb'
    let plural = substitute(file, 'app\/controllers\/', '', '')
    let plural = substitute(plural, '_controller\.rb', '', '')
    return s:Singularise(plural)
  elseif file =~ 'spec\/models\/.*_spec\.rb'
    let singular = substitute(file, 'spec\/models\/', '', '')
    let singular = substitute(singular, '_spec\.rb', '', '')
    return singular
  endif
endfunction

function! s:Uncountable(word)
  return index(s:uncountables, a:word)
endfunction

function! s:Singularise(word)
  if s:Uncountable(a:word) != -1
    return a:word
  endif

  for irregular in s:irregulars
    if a:word == irregular[1]
      return irregular[0]
    endif
  endfor

  for singular in s:singulars
    if a:word =~ singular[0]
      return substitute(a:word, singular[0], singular[1], '')
    endif
  endfor
endfunction

function! s:Pluralise(word)
  if s:Uncountable(a:word) != -1
    return a:word
  endif

  for irregular in s:irregulars
    if a:word == irregular[0]
      return irregular[1]
    endif
  endfor

  for plural in s:plurals
    if a:word =~ plural[0]
      return substitute(a:word, plural[0], plural[1], '')
    endif
  endfor
endfunction

function! s:FindRelatedFiles()
  let singular = s:CalculateResourceName()
  let plural = s:Pluralise(singular)
  let models = glob('app/models/' . singular . '.rb', '', 1)
  let views = glob('app/views/' . plural . '/*', '', 1)
  let controllers = glob('app/controllers/' . plural . '_controller.rb', '', 1)
  let specs = glob('spec/models/' . singular . '_spec.rb', '', 1)

  return models + views + controllers + specs
endfunction

function! g:RingNext()
  let file = @%
  let files = s:FindRelatedFiles()
  let index = index(files, file)
  if index == -1 || index == len(files) -1
    return
  endif
  execute 'edit ' . files[index + 1]
endfunction
nnoremap <silent> ]r :call g:RingNext()<cr>

function! g:RingPrevious()
  let file = @%
  let files = s:FindRelatedFiles()
  let index = index(files, file)
  if index == -1 || index == 0
    return
  endif
  execute 'edit ' . files[index - 1]
endfunction
nnoremap <silent> [r :call g:RingPrevious()<cr>

function! s:TestInflections()
  call s:TestPluralInflection('page', 'pages')
  call s:TestPluralInflection('octopus', 'octopi')
  call s:TestPluralInflection('person', 'people')
  call s:TestPluralInflection('zombie', 'zombies')
  call s:TestPluralInflection('datum', 'data')

  call s:TestSingularInflection('pages', 'page')
  call s:TestSingularInflection('octopi', 'octopus')
  call s:TestSingularInflection('people', 'person')
  call s:TestSingularInflection('zombies', 'zombie')
  call s:TestSingularInflection('data', 'datum')
endfunction

function! s:TestSingularInflection(word, expected)
  if s:Singularise(a:word) != a:expected
    echo 'Expected "' . a:word . '" to singularise to "' . a:expected . '"'
  endif
endfunction

function! s:TestPluralInflection(word, expected)
  if s:Pluralise(a:word) != a:expected
    echo 'Expected "' . a:word . '" to singularise to "' . a:expected . '"'
  endif
endfunction

call s:TestInflections()

function! s:Complete(A,L,P)
  let pattern = a:A
  let files = s:FindRelatedFiles()
  if len(pattern) > 0
    let matched = []
    for file in files
      if file =~ pattern
	call add(matched, file)
      endif
    endfor
    return matched
  end
  return files
endfunction
command! -complete=customlist,s:Complete -nargs=1 Ring :edit <args>

" vim: nowrap sw=2 sts=2 ts=8 noet:
