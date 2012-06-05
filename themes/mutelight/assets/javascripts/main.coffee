$.SyntaxHighlighter.init 
  'lineNumbers': false 
  'theme': 'sunburst' 
  'wrapLines': true 

$(document).ready ->
  $('a[data-pjax]').pjax
    'timeout': 2000

expanded = false
$('#header').live 'click', ->
  if (!expanded)
    $('#header,#radial').animate {
      height: '+=215'
    }, 'slow', 'easeOutBounce'
    expanded = true
  else
    window.location = '/'
