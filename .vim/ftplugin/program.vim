if exists('b:did_my_program_plugin')
	finish
endif
let b:did_my_program_plugin = 1

setlocal sw=4 ts=4

" global settings
setlocal aw sm

function! <sid>CleverTab()
	if strpart( getline('.'), 0, col('.')-1 ) =~ '\S\@<!$'
		return "\<Tab>"
	"elseif &omnifunc != ''
	"	return "\<C-X>\<C-O>"
	else
		return "\<C-P>"
	endif
endfunction

if !exists('no_plugin_maps') && !exists('no_program_maps')
	if !hasmapto('<plug>ProgramMake')
		nmap <buffer> <f4> <plug>ProgramMake
		imap <buffer> <f4> <esc><f4>
	endif
	nnoremap <buffer> <plug>ProgramMake :make<cr>
	if !hasmapto('<plug>ProgramHelp')
		nmap <buffer> <cr> <plug>ProgramHelp
	endif
	nmap <buffer> <plug>ProgramHelp K
	if !hasmapto('<plug>ProgramTabstop')
		nmap <buffer> <f7> <plug>ProgramTabstop
		imap <buffer> <f7> <c-o><f7>
	endif
	nnoremap <buffer> <plug>ProgramTabstop :if &l:ts == 8 <bar> setl ts=4 <bar> else <bar> setl ts=8 <bar> endif <cr>
	if !hasmapto('<plug>ProgramCompleteLine')
		imap <buffer> <c-l> <plug>ProgramCompleteLine
	endif
	inoremap <buffer> <plug>ProgramCompleteLine <c-x><c-l>
	if !hasmapto('<plug>ProgramSmartComplete')
		imap <buffer> <tab> <plug>ProgramSmartComplete
	endif
	inoremap <buffer> <plug>ProgramSmartComplete <c-r>=<sid>CleverTab()<cr>
	if !hasmapto('<plug>ProgramNextError')
		nmap <buffer> <tab> <plug>ProgramNextError
	endif
	nnoremap <buffer> <plug>ProgramNextError :cn<cr>

	command -count=1 -bar -buffer JumplistNext :normal! <count><tab>
	if !hasmapto('<plug>ProgramJumplistNext')
		nmap <buffer> <esc><tab> <plug>ProgramJumplistNext
	endif
	nnoremap <buffer> <plug>ProgramJumplistNext :JumplistNext<cr>

	if !hasmapto('<plug>ProgramPrevError')
		nmap <buffer> <s-tab> <plug>ProgramPrevError
	endif
	nnoremap <buffer> <plug>ProgramPrevError :cp<cr>
	if !hasmapto('<plug>ProgramToBeginFunction')
		map <buffer> <leader>F <plug>ProgramToBeginFunction
	endif
	noremap <buffer> <plug>ProgramToBeginFunction ?^\S<cr>:noh<cr>
	if !hasmapto('<plug>ProgramToEndFunction')
		map <buffer> <leader>f <plug>ProgramToEndFunction
	endif
	noremap <buffer> <plug>ProgramToEndFunction /^\S<cr>:noh<cr>

"	inoremap <buffer> 1 !
"   inoremap <buffer> 2 @
"	inoremap <buffer> 3 #
"	inoremap <buffer> 4 $
"	inoremap <buffer> 5 %
"	inoremap <buffer> 6 ^
"	inoremap <buffer> 7 &
"	inoremap <buffer> 8 *
"	inoremap <buffer> 9 (
"	inoremap <buffer> 0 )

"	inoremap <buffer> ! 1
"	inoremap <buffer> @ 2
"	inoremap <buffer> # 3
"	inoremap <buffer> $ 4
"	inoremap <buffer> % 5
"	inoremap <buffer> ^ 6
"	inoremap <buffer> & 7
"	inoremap <buffer> * 8
"	inoremap <buffer> ( 9
"	inoremap <buffer> ) 0
endif
