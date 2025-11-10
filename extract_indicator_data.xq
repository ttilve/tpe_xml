(: extract_indicator_data.xq :)
(: This XQuery extracts indicator data from CEPALSTAT API XML files :)
(: and generates a structured XML document according to indicator_data.xsd :)

declare variable $indicator_id as xs:string external := "";

(: Load the XML documents :)
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

(: Main query :)
<indicator_data>
{
  (: Check if indicator_id is provided :)
  if ($indicator_id = "") then
    <error>Indicator ID must not be empty</error>
  
  (: Check if metadata file exists and has data :)
  else if (empty($metadata) or empty($metadata/root/body/metadata)) then
    <error>Metadata file not found or invalid</error>
  
  (: Check if dimensions file exists and has data :)
  else if (empty($dimensions) or empty($dimensions/root/body/dimensions)) then
    <error>Dimensions file not found or invalid</error>
  
  (: Check if records file exists and has data :)
  else if (empty($records) or empty($records/root/body/data)) then
    <error>Records file not found or invalid</error>
  
  (: Process the data if all files are valid :)
  else
    (
      (: Extract details from metadata :)
      <details>
        <indicator_name>{string($metadata/root/body/metadata/indicator_name)}</indicator_name>
        <theme>{string($metadata/root/body/metadata/theme)}</theme>
        <area>{string($metadata/root/body/metadata/area)}</area>
        <unit>{string($metadata/root/body/metadata/unit)}</unit>
        <data_features>{string($metadata/root/body/metadata/data_features)}</data_features>
        <definition>{string($metadata/root/body/metadata/definition)}</definition>
        <calculation_methodology>{string($metadata/root/body/metadata/calculation_methodology)}</calculation_methodology>
      </details>,
      
      (: Process records :)
      <data>
      {
        for $record in $records/root/body/data/item
        let $value := string($record/value)
        (: Get all dimension elements (those starting with 'dim_') :)
        let $dim_elements := $record/*[starts-with(local-name(), 'dim_')]
        return
          <record>
            <value>{$value}</value>
            {
              (: Process each dimension :)
              for $dim_element in $dim_elements
              let $dim_name := local-name($dim_element)
              (: Extract dimension ID from element name (e.g., 'dim_208' -> '208') :)
              let $dim_id := substring-after($dim_name, 'dim_')
              let $dim_value_id := string($dim_element)
              
              (: Find the dimension info in dimensions.xml :)
              let $dimension_info := $dimensions/root/body/dimensions/item[id = $dim_id]
              let $dimension_name := string($dimension_info/name)
              
              (: Find the member value in dimensions.xml :)
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