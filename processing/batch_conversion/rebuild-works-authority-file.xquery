declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace saxon="http://saxon.sf.net/";
declare option saxon:output "indent=yes";

processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"'},
processing-instruction xml-model {'href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
processing-instruction xml-model {'href="authority-schematron.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"'},
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Title</title>
            </titleStmt>
            <publicationStmt>
                <p>Publication Information</p>
            </publicationStmt>
            <sourceDesc>
                <p>Information about the source</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <listBibl>
{

    let $collection := collection('../../collections/?select=*.xml;recurse=yes')
    let $linebreak := '&#10;&#10;'
    
    (: This rebuilds the authority file, after the decision was made to prefer 
       then Tibetan script versions of titles :)
       
    let $allworktitles as element()* := $collection//tei:title[@key]
   
    let $dedupedworktitles as element()* := (
        for $workkey in distinct-values($allworktitles/@key)
            let $preferredtitle as xs:string :=
                if ($allworktitles[@key = $workkey]/@xml:lang = 'bo') then
                    ($allworktitles[@key = $workkey][@xml:lang = 'bo'])[1]/string()
                else
                    ($allworktitles[@key = $workkey])[1]/string()
            let $variants as xs:string* := distinct-values($allworktitles[@key = $workkey]/string()[not(. = $preferredtitle)])
            order by $preferredtitle
            return 
            <bibl xml:id="{ $workkey }">
                <title type="uniform">{ $preferredtitle }</title>
                {
                for $variant in $variants
                    return
                    <title type="variant">{ $variant }</title>
                }
                {
                let $instances as xs:string* := distinct-values(
                    for $work in $allworktitles[@key = $workkey]/parent::tei:msItem[@xml:id]
                        return
                        concat(' ../collections/', substring-after(base-uri($work), 'collections/'), '#', replace(encode-for-uri($work/@xml:id), '\-', '%2D'), ' ')
                )
                for $instance in $instances
                    order by $instance
                    return
                    comment{ $instance }
                }
            </bibl>
    )
    
    (: Output the authority file :)
    return $dedupedworktitles

}
            </listBibl>
        </body>
    </text>
</TEI>




        
