if exists("loaded_coffe_syntax_checker")
    finish
endif
let loaded_coffe_syntax_checker = 1

"bail if the user doesnt have coffee-script installed
if !executable("coffee")
    finish
endif

function! SyntaxCheckers_coffee_GetLocList()
    let errorformat =  '%EError: In %f\, Parse error on line %l: %m,%Z%p^,%W%f:%l: warning: %m'

    return SyntasticMake({ 'makeprg': 'coffee -o /dev/null -c %', 'errorformat': errorformat })
endfunction

