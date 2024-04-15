" Vim syntax file
" Language:	Mojo
" Last Change:	2023 Feb 1
"
" Optional highlighting can be controlled using these variables.
"
"   let mojo_no_builtin_highlight = 1
"   let mojo_no_doctest_code_highlight = 1
"   let mojo_no_doctest_highlight = 1
"   let mojo_no_exception_highlight = 1
"   let mojo_no_number_highlight = 1
"   let mojo_space_error_highlight = 1
"
" All the options above can be switched on together.
"
"   let mojo_highlight_all = 1
"

" quit when a syntax file was already loaded.
if exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

if exists("mojo_no_doctest_highlight")
  let mojo_no_doctest_code_highlight = 1
endif

if exists("mojo_highlight_all")
  if exists("mojo_no_builtin_highlight")
    unlet mojo_no_builtin_highlight
  endif
  if exists("mojo_no_doctest_code_highlight")
    unlet mojo_no_doctest_code_highlight
  endif
  if exists("mojo_no_doctest_highlight")
    unlet mojo_no_doctest_highlight
  endif
  if exists("mojo_no_exception_highlight")
    unlet mojo_no_exception_highlight
  endif
  if exists("mojo_no_number_highlight")
    unlet mojo_no_number_highlight
  endif
  let mojo_space_error_highlight = 1
endif

" Keep Python keywords in alphabetical order inside groups for easy
" comparison with the table in the 'Python Language Reference'
" https://docs.python.org/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" The list can be checked using:
"
" python3 -c 'import keyword, pprint; pprint.pprint(keyword.kwlist + keyword.softkwlist, compact=True)'
"
syn keyword mojoStatement	False None True
syn keyword mojoStatement	as assert break continue del global
syn keyword mojoStatement	lambda nonlocal pass return with yield
" Mojo addition: fn, struct, trait
syn keyword mojoStatement	class def fn struct trait nextgroup=mojoFunction skipwhite
" Mojo addition: inout, owned, borrowed, raises
syn keyword mojoStatement	inout owned borrowed raises
syn keyword mojoConditional	elif else if
syn keyword mojoRepeat	        for while
syn keyword mojoOperator	        and in is not or
syn keyword mojoException	except finally raise try
syn keyword mojoInclude	        from import alias
syn keyword mojoAsync		async await


" Soft keywords
" These keywords do not mean anything unless used in the right context
" See https://docs.python.org/3/reference/lexical_analysis.html#soft-keywords
" for more on this.
syn match   mojoConditional   "^\s*\zscase\%(\s\+.*:.*$\)\@="
syn match   mojoConditional   "^\s*\zsmatch\%(\s\+.*:\s*\%(#.*\)\=$\)\@="

" Decorators
" A dot must be allowed because of @MyClass.myfunc decorators.
syn match   mojoDecorator	"@" display contained
syn match   mojoDecoratorName	"@\s*\h\%(\w\|\.\)*" display contains=mojoDecorator

" Python 3.5 introduced the use of the same symbol for matrix multiplication:
" https://www.python.org/dev/peps/pep-0465/.  We now have to exclude the
" symbol from highlighting when used in that context.
" Single line multiplication.
syn match   mojoMatrixMultiply
      \ "\%(\w\|[])]\)\s*@"
      \ contains=ALLBUT,mojoDecoratorName,mojoDecorator,mojoFunction,mojoDoctestValue
      \ transparent
" Multiplication continued on the next line after backslash.
syn match   mojoMatrixMultiply
      \ "[^\\]\\\s*\n\%(\s*\.\.\.\s\)\=\s\+@"
      \ contains=ALLBUT,mojoDecoratorName,mojoDecorator,mojoFunction,mojoDoctestValue
      \ transparent
" Multiplication in a parenthesized expression over multiple lines with @ at
" the start of each continued line; very similar to decorators and complex.
syn match   mojoMatrixMultiply
      \ "^\s*\%(\%(>>>\|\.\.\.\)\s\+\)\=\zs\%(\h\|\%(\h\|[[(]\).\{-}\%(\w\|[])]\)\)\s*\n\%(\s*\.\.\.\s\)\=\s\+@\%(.\{-}\n\%(\s*\.\.\.\s\)\=\s\+@\)*"
      \ contains=ALLBUT,mojoDecoratorName,mojoDecorator,mojoFunction,mojoDoctestValue
      \ transparent

syn match   mojoFunction	"\h\w*" display contained

" Mojo addition: backticked strings
syn match   mojoMlirInline "`[^`]*`"

syn match   mojoComment	"#.*$" contains=mojoTodo,@Spell
syn keyword mojoTodo		FIXME NOTE NOTES TODO XXX contained

" Triple-quoted strings can contain doctests.
syn region  mojoString matchgroup=mojoQuotes
      \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=mojoEscape,@Spell
syn region  mojoString matchgroup=mojoTripleQuotes
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=mojoEscape,mojoSpaceError,mojoDoctest,@Spell
syn region  mojoRawString matchgroup=mojoQuotes
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  mojoRawString matchgroup=mojoTripleQuotes
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=mojoSpaceError,mojoDoctest,@Spell

syn match   mojoEscape	+\\[abfnrtv'"\\]+ contained
syn match   mojoEscape	"\\\o\{1,3}" contained
syn match   mojoEscape	"\\x\x\{2}" contained
syn match   mojoEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   mojoEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   mojoEscape	"\\$"

" It is very important to understand all details before changing the
" regular expressions below or their order.
" The word boundaries are *not* the floating-point number boundaries
" because of a possible leading or trailing decimal point.
" The expressions below ensure that all valid number literals are
" highlighted, and invalid number literals are not.  For example,
"
" - a decimal point in '4.' at the end of a line is highlighted,
" - a second dot in 1.0.0 is not highlighted,
" - 08 is not highlighted,
" - 08e0 or 08j are highlighted,
"
" and so on, as specified in the 'Python Language Reference'.
" https://docs.python.org/reference/lexical_analysis.html#numeric-literals
if !exists("mojo_no_number_highlight")
  " numbers (including longs and complex)
  syn match   mojoNumber	"\<0[oO]\=\o\+[Ll]\=\>"
  syn match   mojoNumber	"\<0[xX]\x\+[Ll]\=\>"
  syn match   mojoNumber	"\<0[bB][01]\+[Ll]\=\>"
  syn match   mojoNumber	"\<\%([1-9]\d*\|0\)[Ll]\=\>"
  syn match   mojoNumber	"\<\d\+[jJ]\>"
  syn match   mojoNumber	"\<\d\+[eE][+-]\=\d\+[jJ]\=\>"
  syn match   mojoNumber
	\ "\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@="
  syn match   mojoNumber
	\ "\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif

" Group the built-ins in the order in the 'Python Library Reference' for
" easier comparison.
" https://docs.python.org/library/constants.html
" http://docs.python.org/library/functions.html
" Python built-in functions are in alphabetical order.
"
" The list can be checked using:
"
" python3 -c 'import builtins, pprint; pprint.pprint(dir(builtins), compact=True)'
"
" The constants added by the `site` module are not listed below because they
" should not be used in programs, only in interactive interpreter.
" Similarly for some other attributes and functions `__`-enclosed from the
" output of the above command.
"
if !exists("mojo_no_builtin_highlight")
  " built-in constants
  " 'False', 'True', and 'None' are also reserved words in Python 3
  syn keyword mojoBuiltin	False True None
  syn keyword mojoBuiltin	NotImplemented Ellipsis __debug__
  " constants added by the `site` module
  syn keyword mojoBuiltin	quit exit copyright credits license
  " built-in functions
  syn keyword mojoBuiltin	abs all any ascii bin bool breakpoint bytearray
  syn keyword mojoBuiltin	bytes callable chr classmethod compile complex
  syn keyword mojoBuiltin	delattr dict dir divmod enumerate eval exec
  syn keyword mojoBuiltin	filter float format frozenset getattr globals
  syn keyword mojoBuiltin	hasattr hash help hex id input int isinstance
  syn keyword mojoBuiltin	issubclass iter len list locals map max
  syn keyword mojoBuiltin	memoryview min next object oct open ord pow
  syn keyword mojoBuiltin	print property range repr reversed round set
  syn keyword mojoBuiltin	setattr slice sorted staticmethod str sum super
  syn keyword mojoBuiltin	tuple type vars zip __import__

  " Mojo addition:
  syn keyword mojoMlirKeyword	__mlir_type __mlir_op __mlir_attr

  " avoid highlighting attributes as builtins
  syn match   mojoAttribute	/\.\h\w*/hs=s+1
	\ contains=ALLBUT,mojoBuiltin,mojoFunction,mojoAsync
	\ transparent
endif

" Mojo addition:
syn keyword mojoKeywords	        var let

" From the 'Python Library Reference' class hierarchy at the bottom.
" http://docs.python.org/library/exceptions.html
if !exists("mojo_no_exception_highlight")
  " builtin base exceptions (used mostly as base classes for other exceptions)
  syn keyword mojoExceptions	BaseException Exception
  syn keyword mojoExceptions	ArithmeticError BufferError LookupError
  " builtin exceptions (actually raised)
  syn keyword mojoExceptions	AssertionError AttributeError EOFError
  syn keyword mojoExceptions	FloatingPointError GeneratorExit ImportError
  syn keyword mojoExceptions	IndentationError IndexError KeyError
  syn keyword mojoExceptions	KeyboardInterrupt MemoryError
  syn keyword mojoExceptions	ModuleNotFoundError NameError
  syn keyword mojoExceptions	NotImplementedError OSError OverflowError
  syn keyword mojoExceptions	RecursionError ReferenceError RuntimeError
  syn keyword mojoExceptions	StopAsyncIteration StopIteration SyntaxError
  syn keyword mojoExceptions	SystemError SystemExit TabError TypeError
  syn keyword mojoExceptions	UnboundLocalError UnicodeDecodeError
  syn keyword mojoExceptions	UnicodeEncodeError UnicodeError
  syn keyword mojoExceptions	UnicodeTranslateError ValueError
  syn keyword mojoExceptions	ZeroDivisionError
  " builtin exception aliases for OSError
  syn keyword mojoExceptions	EnvironmentError IOError WindowsError
  " builtin OS exceptions in Python 3
  syn keyword mojoExceptions	BlockingIOError BrokenPipeError
  syn keyword mojoExceptions	ChildProcessError ConnectionAbortedError
  syn keyword mojoExceptions	ConnectionError ConnectionRefusedError
  syn keyword mojoExceptions	ConnectionResetError FileExistsError
  syn keyword mojoExceptions	FileNotFoundError InterruptedError
  syn keyword mojoExceptions	IsADirectoryError NotADirectoryError
  syn keyword mojoExceptions	PermissionError ProcessLookupError TimeoutError
  " builtin warnings
  syn keyword mojoExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword mojoExceptions	ImportWarning PendingDeprecationWarning
  syn keyword mojoExceptions	ResourceWarning RuntimeWarning
  syn keyword mojoExceptions	SyntaxWarning UnicodeWarning
  syn keyword mojoExceptions	UserWarning Warning
endif

if exists("mojo_space_error_highlight")
  " trailing whitespace
  syn match   mojoSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   mojoSpaceError	display " \+\t"
  syn match   mojoSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("mojo_no_doctest_highlight")
  if !exists("mojo_no_doctest_code_highlight")
    syn region mojoDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,mojoDoctest,mojoFunction,@Spell
    syn region mojoDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region mojoDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
" Mojo addition: struct, fn, trait
syn sync match mojoSync grouphere NONE "^\%(def\|class\|fn\|struct\|trait\)\s\+\h\w*\s*[(:]"

" The default highlight links.  Can be overridden later.
hi def link mojoStatement		Statement
hi def link mojoConditional		Conditional
hi def link mojoRepeat		Repeat
hi def link mojoOperator		Operator
hi def link mojoException		Exception
" Mojo addition: highlight for 'var' and 'let'
hi def link mojoKeywords		Structure
hi def link mojoInclude		Include
hi def link mojoAsync			Statement
hi def link mojoDecorator		Define
hi def link mojoDecoratorName		Function
hi def link mojoFunction		Function
hi def link mojoComment		Comment
hi def link mojoTodo			Todo
hi def link mojoString		String
hi def link mojoRawString		String
hi def link mojoQuotes		String
hi def link mojoTripleQuotes		mojoQuotes
hi def link mojoEscape		Special
" Mojo addition: mlir interface
hi def link mojoMlirKeyword	Special
hi def link mojoMlirInline	String
if !exists("mojo_no_number_highlight")
  hi def link mojoNumber		Number
endif
if !exists("mojo_no_builtin_highlight")
  hi def link mojoBuiltin		Function
endif
if !exists("mojo_no_exception_highlight")
  hi def link mojoExceptions		Structure
endif
if exists("mojo_space_error_highlight")
  hi def link mojoSpaceError		Error
endif
if !exists("mojo_no_doctest_highlight")
  hi def link mojoDoctest		Special
  hi def link mojoDoctestValue	Define
endif

let b:current_syntax = "mojo"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
