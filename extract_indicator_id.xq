xquery version "3.1";

(: === FUNCIÓN RECURSIVA === :)
declare function local:search($nodes as item()*) as xs:integer* {
  for $node in ($nodes?*)
  where $node instance of map(*)
  let $name := lower-case($node?name)
  let $id_raw := $node?indicator_id
  let $id := if (exists($id_raw) and $id_raw castable as xs:integer) 
             then xs:integer($id_raw) 
             else ()
  let $children := $node?children
  return (
    if (starts-with($name, lower-case($prefix)) and exists($id)) then
      $id
    else (),
    if (exists($children)) then
      local:search($children)
    else ()
  )
};

(: === LÓGICA PRINCIPAL === :)
declare variable $prefix as xs:string external;

let $json := json-doc("data/indicators.json")
let $root := $json?body?children
let $ids := local:search($root)
let $max_id := if (exists($ids)) then max($ids) else ()

return
  if (exists($max_id)) then
    xs:string($max_id)
  else
    ""