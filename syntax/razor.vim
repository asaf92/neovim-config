" ~/.config/nvim/syntax/razor.vim
if exists("b:current_syntax")
    finish
endif

" Include C# and HTML syntax files
syn include @CSharp syntax/cs.vim
syn include @Html syntax/html.vim

" Define syntax for Razor directives (keywords)
syn keyword razorDirective contained @page @using @inject @code
highlight link razorDirective Keyword

" Define syntax for inline Razor expressions
syn match razorExpression "@\w\+" contained
highlight link razorExpression Identifier

" Define syntax for C# code blocks within Razor
syn region razorCode start="@{" end="}" contains=@CSharp
highlight link razorCode PreProc

" Define syntax for Razor templates (HTML with embedded Razor)
syn region razorTemplate start="<" end=">" contains=@Html,razorCode,razorExpression
highlight link razorTemplate Tag

" Handle more complex inline expressions
syn region razorInlineExpr start="@(" end=")" contains=@CSharp
highlight link razorInlineExpr Special

" Set the current syntax to 'razor'
let b:current_syntax = "razor"
