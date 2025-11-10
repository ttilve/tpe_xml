xquery version "3.1";

declare variable $prefix as xs:string external;

let $json := json-doc("data/indicators.json")

(: Navegamos el JSON como mapa :)
let $body := $json?body?children

(: Función recursiva para buscar en todos los niveles :)
declare function local:search($nodes as map(*)*, $depth as xs:integer) as xs:integer* {
  for $node in $nodes
  let $name := lower-case($node?name)
  let $id := $node?indicator_id
  let $children := $node?children
  return (
    if (starts-with($name, lower-case($prefix)) and exists($id)) then
      $id
    else (),
    if (exists($children)) then
      local:search($children, $depth + 1)
    else ()
  )
};

let $all_ids := local:search($body, 0)
let $max_id := if (exists($all_ids)) then max($all_ids) else ()

return
  if (exists($max_id)) then
    xs:string($max_id)
  else
    ""