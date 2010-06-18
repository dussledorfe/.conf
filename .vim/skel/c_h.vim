let s:header = 'GUARD_' . substitute(toupper(expand('<afile>')) . '_', '[^A-Z0-9_]', '_', 'g')
exe 'norm! i#ifndef ' . s:header . "\n#define " . s:header . "\n\n#endif /* " . s:header . " */\e"
3
