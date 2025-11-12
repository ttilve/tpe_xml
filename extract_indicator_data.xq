

declare variable $indicator_id as xs:string external := "";


declare variable $metadata := 
  if (doc-available('data/metadata.xml')) 
  then doc('data/metadata.xml')
  else ();

declare variable $dimensions := 
  if (doc-available('data/dimensions.xml')) 
  then doc('data/dimensions.xml')
  else ();

declare variable $records := 
  if (doc-available('data/records.xml')) 
  then doc('data/records.xml')
  else ();


<indicator_data>
{
  
  if ($indicator_id = "") then
    <error>Indicator ID must not be empty</error>
  
  
  else if (empty($metadata) or empty($metadata/root/body/metadata)) then
    <error>Metadata file not found or invalid</error>
  
  
  else if (empty($dimensions) or empty($dimensions/root/body/dimensions)) then
    <error>Dimensions file not found or invalid</error>
  
  
  else if (empty($records) or empty($records/root/body/data)) then
    <error>Records file not found or invalid</error>
  
  
  else
    (
      
      <details>
        <indicator_name>{string($metadata/root/body/metadata/indicator_name)}</indicator_name>
        <theme>{string($metadata/root/body/metadata/theme)}</theme>
        <area>{string($metadata/root/body/metadata/area)}</area>
        <unit>{string($metadata/root/body/metadata/unit)}</unit>
        <data_features>{string($metadata/root/body/metadata/data_features)}</data_features>
        <definition>{string($metadata/root/body/metadata/definition)}</definition>
        <calculation_methodology>{string($metadata/root/body/metadata/calculation_methodology)}</calculation_methodology>
      </details>,
      
      
      <data>
      {
        for $record in $records/root/body/data/item
        let $value := string($record/value)
        
        let $dim_elements := $record/*[starts-with(local-name(), 'dim_')]
        return
          <record>
            <value>{$value}</value>
            {
              
              for $dim_element in $dim_elements
              let $dim_name := local-name($dim_element)
              
              let $dim_id := substring-after($dim_name, 'dim_')
              let $dim_value_id := string($dim_element)
              

              let $dimension_info := $dimensions/root/body/dimensions/item[id = $dim_id]
              let $dimension_name := string($dimension_info/name)
              
              
              let $member_info := $dimension_info/members/item[id = $dim_value_id]
              let $member_value := string($member_info/name)
              
              where $dimension_name != "" and $member_value != ""
              return
                <dimension>
                  <name>{$dimension_name}</name>
                  <value>{$member_value}</value>
                </dimension>
            }
          </record>
      }
      </data>
    )
}
</indicator_data>