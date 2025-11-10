
xquery version "3.1";

declare option output:method "xml";
declare option output:indent "yes";

declare variable $indicator_id as xs:string external;

let $dimensions := doc("data/dimensions.xml")//item
let $records := doc("data/records.xml")//item

return
  <indicator_data>
    <data>
    {
      for $rec in $records
      let $value := $rec/value/text()
      return
        <record>
          <value>{$value}</value>
          {
            for $dim in $dimensions
            let $dim_id := $dim/id/text()
            let $dim_name := $dim/name/text()
            let $key := concat("dim_", $dim_id)
            let $member_id := $rec/*[name() = $key]/text()
            let $member_name := $dimensions[id = $dim_id]/members/item[id = $member_id]/name/text()
            where $member_id and $member_name
            return
              <dimension>
                <name>{$dim_name}</name>
                <value>{$member_name}</value>
              </dimension>
          }
        </record>
    }
    </data>
  </indicator_data>