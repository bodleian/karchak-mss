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
            <listPerson>
{

    let $collection := collection('../../collections/?select=*.xml;recurse=yes')
    let $linebreak := '&#10;&#10;'
    
    (: This rebuilds the authority file, after the decision was made to prefer 
       then Tibetan script versions of names :)
       
    let $allpeople as element()* := $collection//(tei:author|tei:persName)[@key]
   
    let $dedupedpeople as element()* := (
        for $personkey in distinct-values($allpeople/@key)
            let $preferredname as xs:string :=
                if ($allpeople[@key = $personkey]/descendant-or-self::*[self::tei:author or self::tei:persName]/@xml:lang = 'bo') then
                    ($allpeople[@key = $personkey]/descendant-or-self::*[self::tei:author or self::tei:persName][@xml:lang = 'bo'])[1]/string()
                else
                    ($allpeople[@key = $personkey]/descendant-or-self::*[self::tei:author or self::tei:persName])[1]/string()
            let $variants as xs:string* := distinct-values($allpeople[@key = $personkey]/descendant-or-self::*[self::tei:author[not(child::tei:persName)] or self::tei:persName]/string()[not(. = $preferredname)])
            order by $preferredname
            return 
            <person xml:id="{ $personkey }">
                <persName type="display">{ $preferredname }</persName>
                {
                for $variant in $variants
                    return
                    <persName type="variant">{ $variant }</persName>
                }
                {
                let $instances as xs:string* := distinct-values(
                    for $roottei in $allpeople[@key = $personkey]/ancestor::tei:TEI[@xml:id]
                        return
                        concat(' ../collections/', substring-after(base-uri($roottei), 'collections/'), ' ')
                )
                for $instance in $instances
                    order by $instance
                    return
                    comment{ $instance }
                }
            </person>
    )
    
    (: Output the authority file :)
    return $dedupedpeople

}
            </listPerson>
        </body>
    </text>
</TEI>




        
