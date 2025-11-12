xquery version "3.1";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";


declare variable $prefix as xs:string external;

let $json := json-doc("data/indicators.json")
let $root := $json?body?children


let $all-nodes :=
  let $queue := $root?*
  return (
    $queue,
    $queue?children?*,
    $queue?children?*?children?*,
    $queue?children?*?children?*?children?*,
    $queue?children?*?children?*?children?*?children?*,
    $queue?children?*?children?*?children?*?children?*?children?*
  )


let $ids := 
  for $node in $all-nodes
  where $node instance of map(*)
  let $name := lower-case($node?name)
  let $id_raw := $node?indicator_id
  let $id := if (exists($id_raw) and $id_raw castable as xs:integer) 
             then xs:integer($id_raw)
             else ()
  where starts-with($name, lower-case($prefix)) and exists($id)
  return $id

let $max_id := if (exists($ids)) then max($ids) else ()

return
  if (exists($max_id)) then
    string($max_id)
  else
    ""