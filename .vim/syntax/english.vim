" Vim syntax file
" Language: English
" Author: Lucas de Vries <lucas@glacicle.org>
"

" Check whether syntax has been loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
let b:current_syntax = "english"

" English words can have dashes in them
setlocal isk+=-

syn case ignore
syn keyword englishConjunction and or not but while although though because unless since
syn keyword englishConditional if when whenever who whoever what whatever unless
syn keyword englishArticle a an the
syn keyword englishDemonstrative that those this these

syn keyword englishPersonal I me myself we you yourself he him himself
syn keyword englishPersonal she her herself it itself they them themselves
syn keyword englishPersonal we us ourselves yourselves

syn keyword englishPossessive my mine yours his hers its ours theirs thine

syn keyword englishPreposition of to in for on with as by at from
syn match englishAdverb "[^\k]\k\+ly[^\k]"

syn keyword englishValue true false no yes
syn keyword englishAssignment is am are were was be been

syn match englishContraction "'s"
syn match englishContraction "n't"
syn match englishContraction "'ve"
syn match englishContraction "'d"

syn region englishAside start=/(/ end=/)/
syn match englishConjunction "\([.,;:]\|^\) \?for"
syn match englishDelimiter "[,;:.]"

hi link englishPersonal Statement
hi link englishPossessive Statement
hi link englishArticle Type
hi link englishDemonstrative String
hi link englishDelimiter Delimiter
hi link englishConditional Conditional
hi link englishConjunction Operator
hi link englishContraction Folded
hi link englishAside Comment
hi link englishValue Boolean
hi link englishPreposition Keyword
hi link englishAssignment Define
hi link englishAdverb Function
