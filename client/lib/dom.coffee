SVGNS = 'http://www.w3.org/2000/svg'

svgTags =
  svg: true
  line: true
  circle: true
  g: true

export create = (tag, attrs, props, events, children) ->
  if tag of svgTags
    elt = document.createElementNS SVGNS, tag
  else
    elt = document.createElement tag
  attr elt, attrs if attrs?
  prop elt, props if props?
  listen elt, events if events?
  elt.appendChild child for child in children if children?
  elt

export attr = (elt, attrs) ->
  for key, value of attrs when value?
    elt.setAttribute key, value

export prop = (elt, props) ->
  for key, value of props when value?
    if typeof value == 'object'
      prop elt[key], value
    else
      elt[key] = value

export listen = (elt, events) ->
  if elt.length?
    listen sub, events for sub in elt
  else
    for key, value of events when value?
      elt.addEventListener key, value

export select = (allQuery, subQuery) ->
  for elt in document.querySelectorAll "#{allQuery}.selected"
    elt.classList.remove 'selected'
  if subQuery?
    document.querySelector "#{allQuery}#{subQuery}"
    .classList.add 'selected'