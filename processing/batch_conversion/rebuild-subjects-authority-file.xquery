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
            <list>
{

    let $collection := collection('../../collections/?select=*.xml;recurse=yes')
    let $linebreak := '&#10;&#10;'
    
    (: This rebuilds the authority file in alphabetical order :)
       
    let $allterms as element()* := $collection//(tei:term|tei:placeName)[@key]
   
    let $dedupedterms as element()* := (
        for $termkey in distinct-values($allterms/@key)
            let $preferredterm as xs:string := ($allterms[@key = $termkey])[1]/string()
            let $variants as xs:string* := distinct-values($allterms[@key = $termkey]/string()[not(. = $preferredterm)])
            order by $preferredterm
            return 
            <item xml:id="{ $termkey }">
                <term type="display">{ $preferredterm }</term>
                {
                for $variant in $variants
                    return
                    <term type="variant">{ $variant }</term>
                }
                <note type="links">
                    <list type="links">
                        <item>
                            <ref target="https://id.loc.gov/authorities/{ if (starts-with($termkey, 'subject_sh')) then 'subjects' else if (starts-with($termkey, 'subject_gf')) then 'genreForms' else 'names' }/{ substring-after($termkey, 'subject_') }.html">
                                <title>LC</title>
                            </ref>
                        </item>
                    </list>
                </note>
                {
                let $instances as xs:string* := distinct-values(
                    for $term in $allterms[@key = $termkey]
                        return
                        concat(' ../collections/', substring-after(base-uri($term), 'collections/'), ' ')
                )
                for $instance in $instances
                    order by $instance
                    return
                    comment{ $instance }
                }
            </item>
    )
    
    (: Output the authority file :)
    return $dedupedterms

}
            </list>
        </body>
    </text>
</TEI>




        
