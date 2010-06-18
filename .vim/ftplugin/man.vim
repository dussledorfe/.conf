" Vim filetype plugin file
" Language:		man
" Maintainer:	Lukas Mai
" Last Change:	03.07.2002

" To make the ":Man" command (and the "Man" function) available before editing
" a manual page, source this script from your startup vimrc file.

" some local settings -- but only if 'filetype' is "man"
if &ft == 'man'

	" Only do this when not done yet for this buffer
	if exists('b:did_ftplugin')
		finish
	endif
	let b:did_ftplugin = 1

	" allow dot and dash in manual page name
	setlocal isk+=.,-

	" Add mappings, unless the user didn't want this
	if !exists('no_plugin_maps') && !exists('no_man_maps')
		nnoremap <buffer> <c-]> :call <sid>GetPagePre(v:count)<cr>
		nnoremap <buffer> <c-t> :call <sid>PopPage()<cr>
	endif

endif

if exists(':Man') != 2
	com -nargs=1 -count=0 -bar Man call s:GetPage(<count>, <q-args>)
	nnoremap <leader>K :call <sid>GetPagePre(0)<cr>
endif

" Define functions only once
if !exists('s:man_depth')

	let s:man_depth = 0

	if system('uname -sr') =~ 'SunOS\s\+5'
		let s:man_sect_arg = '-s'
	else
		let s:man_sect_arg = ''
	endif

	" returns false if the requested page couldn't be found
	func Man(sect, page)
		return s:GetPage(a:sect, a:page)
	endfunc

	func s:GetPagePre(n)
		if a:n == 0
			let my_isk = &isk
			setl isk+=(,)
			let str = expand('<cword>')
			let &isk = my_isk

			let page = matchstr(str, '\k\+')
			let sect = matchstr(str, '(\d\h*)')[1]
			if sect == ''
				let sect = 0
			endif
		else
			let page = expand('<cword>')
			let sect = a:n
		endif
		return s:GetPage(sect, page)
	endfunc

	func s:GetPage(sect, page)
		let s:man_buf{s:man_depth} = bufnr('%')
		let s:man_line{s:man_depth} = line('.')
		let s:man_col{s:man_depth} = virtcol('.')
		let have_man = 1
		
		" look for an existing "man" window
		let thiswin = winnr()
		while &ft != 'man'
			wincmd w
			if winnr() == thiswin
				let have_man = 0
				break
			endif
		endwhile

		exe 'new '.escape($HOME.'/'.a:page.'.'.a:sect.'~', " \t\n\\")
		let my_srr = &srr
		setl ma srr=>
		norm ggdG
		let pager = $PAGER
		let $PAGER = "/usr/bin/perl -pe 's/.\\cH|\\e\\[[^a-zA-Z\\@`]*[a-zA-Z\\@`]//g'"
		silent exe '0r !/usr/bin/man '.(a:sect ? s:man_sect_arg.' '.a:sect.' '.a:page : a:page)
		let $PAGER = pager
		let &srr = my_srr
		if v:shell_error || (getline(1) =~ '\<No entry\>' && getline(1) =~ '\<manual\>')
			q!
			exec s:man_buf{s:man_depth}.'b'
			exec s:man_line{s:man_depth}
			exec 'norm '.s:man_col{s:man_depth}.'|'
			unlet s:man_buf{s:man_depth} s:man_line{s:man_depth} s:man_col{s:man_depth}
			redraw
			echohl ErrorMsg
			echo 'No manual entry for '.a:page.(a:sect ? ' in section '.a:sect : '')
			echohl None
			return 0
		endif

		" close the old "man" window
		if have_man
			if &sb
				wincmd W
				let thiswin = winnr()
				q
				if winnr() != thiswin
					wincmd w
				endif
			else
				wincmd w
				let thiswin = winnr()
				q
				if winnr() == thiswin
					wincmd W
				endif
			endif
			let s:man_depth = s:man_depth + 1
		else
			unlet s:man_buf{s:man_depth} s:man_line{s:man_depth} s:man_col{s:man_depth}
		endif

		1
		setl ft=man nomod noma bh=hide nobl

		return 1
	endfunc

	func s:PopPage()
		if s:man_depth > 0
			let s:man_depth = s:man_depth - 1
			exec s:man_buf{s:man_depth}.'b'
			exec s:man_line{s:man_depth}
			exec 'norm '.s:man_col{s:man_depth}.'|'
			unlet s:man_buf{s:man_depth} s:man_line{s:man_depth} s:man_col{s:man_depth}
		else
			echohl ErrorMsg
			echo "at bottom of tag stack"
			echohl None
		endif
	endfunc

endif


" vim: ts=4
