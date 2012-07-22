initSyntax = ->
  $.SyntaxHighlighter.init 
    'baseUrl': '//balupton.github.com/jquery-syntaxhighlighter',
    'lineNumbers': false 
    'prettifyBaseUrl': '//balupton.github.com/jquery-syntaxhighlighter/prettify',
    'theme': 'sunburst' 
    'wrapLines': true 

$(document).ready ->
  $('a[data-pjax]').pjax
    'timeout': 2000
  initSyntax()

$(document).on 'pjax:end', ->
  initSyntax()
