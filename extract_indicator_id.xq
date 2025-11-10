xquery version "3.1";

declare namespace json = "http://www.w3.org/2005/xpath-functions";

declare variable $prefix as xs:string external;

let $data := json-doc("data/indicators.json")

let $indicators := $data//json:array[@key="body"]/json:map/json:array[@key="children"]/json:map

let $matches := $indicators[
  starts-with(lower-case(json:string[@key="name"]), lower-case($prefix))
][json:number[@key="indicator_id"]]

let $max_id := max($matches)

return
  if (exists($max_id)) then
    xs:string($max_id)
  else
    ""