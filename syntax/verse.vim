" Vim syntax file
" Language: Verse (Unreal Engine / UEFN)
" Filenames: *.verse

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case match

" Keywords ---------------------------------------------------------------------
syn keyword verseConditional    if then else case
syn keyword verseRepeat         for loop
syn keyword verseStatement      return break continue yield
syn keyword verseConcurrency    block defer spawn sync race rush branch upon
syn keyword verseKeyword        set var ref where of at do
syn keyword verseOperatorWord   and or not
syn keyword verseInclude        using
syn keyword verseStructure      module class struct interface enum
syn keyword verseStructure      subtype castable_subtype
syn keyword verseType           int float rational logic string char char8 char32 void any
syn keyword verseType           comparable type tuple option weak_map persistable
syn keyword verseType           agent player message locale
syn keyword verseBoolean        true false
syn keyword verseConstant       external
syn keyword verseSelf           Self Super

" Effect / visibility specifiers, e.g. Foo<public><decides>():void
syn match   verseSpecifier      "<\%(public\|private\|protected\|internal\|scoped\|epic_internal\|localizes\|native\|native_callable\|override\|final\|final_super\|abstract\|concrete\|unique\|persistable\|castable\|constructor\|open\|closed\|inline\|module_scoped_var_weak_map_key\)>"
syn match   verseSpecifier      "<\%(decides\|transacts\|suspends\|computes\|converges\|reads\|writes\|allocates\|varies\|predicts\|no_rollback\)>"

" Attributes, e.g. @editable
syn match   verseAttribute      "@\h\w*"

" Function calls / definitions: identifier immediately followed by ( or <spec>(
syn match   verseFunction       "\<\h\w*\ze\%(<\h\w*>\)*("

" Numbers ----------------------------------------------------------------------
syn match   verseNumber         "\<0x\x\+\%(u8\|u16\|u32\|u64\)\=\>"
syn match   verseNumber         "\<0o\o\+\>"
syn match   verseNumber         "\<0b[01]\+\>"
syn match   verseNumber         "\<\d\+\%(u8\|u16\|u32\|u64\|i32\|i64\)\=\>"
syn match   verseFloat          "\<\d\+\.\d\+\%([eE][+-]\=\d\+\)\=\%(f64\)\=\>"
syn match   verseFloat          "\<\d\+[eE][+-]\=\d\+\%(f64\)\=\>"

" Strings and chars ------------------------------------------------------------
syn match   verseEscape         contained "\\[rnt\\"'{}<>#&~]"
syn region  verseInterpolation  contained matchgroup=verseInterpDelim start="{" end="}" contains=TOP
syn region  verseString         start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=verseEscape,verseInterpolation
syn match   verseChar           "'\%(\\.\|[^\\']\)'"

" Operators --------------------------------------------------------------------
syn match   verseOperator       ":=\|=>\|->\|+=\|-=\|\*=\|/=\|<>\|<=\|>=\|\.\.\|[?:=+\-*/^]"

" Comments ---------------------------------------------------------------------
syn keyword verseTodo           contained TODO FIXME XXX NOTE HACK
syn match   verseLineComment    "#\%(>\)\@!.*$" contains=verseTodo,@Spell
" <# ... #> block comments, which may nest.
syn region  verseBlockComment   start="<#\%(>\)\@!" end="#>" contains=verseBlockComment,verseTodo,@Spell
" <#> indented comment: the rest of the line plus every following line indented deeper.
syn region  verseIndentComment  start="^\z(\s*\)<#>" end="^\%(\z1\s\|\s*$\)\@!" contains=verseTodo,@Spell

" Highlight links --------------------------------------------------------------
hi def link verseConditional    Conditional
hi def link verseRepeat         Repeat
hi def link verseStatement      Statement
hi def link verseConcurrency    Keyword
hi def link verseKeyword        Keyword
hi def link verseOperatorWord   Operator
hi def link verseInclude        Include
hi def link verseStructure      Structure
hi def link verseType           Type
hi def link verseBoolean        Boolean
hi def link verseConstant       Constant
hi def link verseSelf           Special
hi def link verseSpecifier      StorageClass
hi def link verseAttribute      PreProc
hi def link verseFunction       Function
hi def link verseNumber         Number
hi def link verseFloat          Float
hi def link verseEscape         SpecialChar
hi def link verseInterpDelim    Delimiter
hi def link verseString         String
hi def link verseChar           Character
hi def link verseOperator       Operator
hi def link verseTodo           Todo
hi def link verseLineComment    Comment
hi def link verseBlockComment   Comment
hi def link verseIndentComment  Comment

let b:current_syntax = "verse"

let &cpo = s:cpo_save
unlet s:cpo_save
