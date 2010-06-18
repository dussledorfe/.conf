" Vim pastebin plugin
" Last Change: 2009-10-11
" Author:      mauke
"
" provides :Paste
" uses g:default_paste_nick (should be set in your .vimrc)

if exists('loaded_pastebin')
	finish
endif
let loaded_pastebin = 1

function s:pastebin(...) range
	let cmd = 'pastebin'
	let site = 'codepad'
	if a:0 > 0 && a:1 =~ '^-'
		let site = strpart(a:1, 1)
		let titles = a:000[1:]
	else
		let titles = a:000
	endif
	let cmd .= ' -s ' . shellescape(site)
	let title = join(titles, ' ')
	let cmd .= ' -t ' . shellescape(title)
	let cmd .= " -T " . &ts
	if exists('g:default_paste_nick') && g:default_paste_nick != ''
		let cmd .= " -n " . g:default_paste_nick
	endif
	let ft = &ft
	if ft == 'cpp'
		ft = 'c++'
	endif
	if ft != ''
		let cmd .= " -l " . ft
	endif
	redraw
	execute a:firstline . "," . a:lastline . "write !" . cmd
endfunction

if !exists(':Paste')
	command -nargs=* -complete=buffer -range=% Paste :<line1>,<line2>call s:pastebin(<f-args>)
endif
