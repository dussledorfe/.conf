exe "norm! iuse warnings;\nuse strict;\n\npackage " . substitute(expand('<afile>:r'), '/', '::', 'g') . ";\n\n1\e"
5
