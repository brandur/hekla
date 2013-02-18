initSyntax = ->
  $.SyntaxHighlighter.init 
    'lineNumbers': false 
    'wrapLines': true 

$(document).ready ->
  $('a[data-pjax]').pjax
    'timeout': 2000
  initSyntax()

$(document).on 'pjax:end', ->
  initSyntax()
