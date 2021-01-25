declare namespace saxon = "http://saxon.sf.net/";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option saxon:output "indent=no";

declare variable $collection := collection('../../younghusband?select=*.xml;recurse=yes');
declare variable $tab := '&#9;';
declare variable $newline := '&#10;';

(: Written for the Younghusband collection TEI files provided by the BL, so makes assumptions that probably aren't true for other sources :)

<dummy>
{
    for $ms in $collection//tei:TEI
        let $filename as xs:string := tokenize(base-uri($ms), '/')[last()]
        let $shelfmark as xs:string := normalize-space(($ms//tei:msDesc/tei:msIdentifier/tei:idno)[1]/string())
        let $head as xs:string := normalize-space(($ms//tei:msDesc/tei:head)[1]/string())
        let $extent as xs:string := normalize-space(string(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:extent/text())[1]))
        let $leafsize as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:extent/tei:dimensions[@type='leaf'])[1]/concat(tei:width/string(),' x ',tei:height/string(), ' ', @units))
        let $writtensize as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:extent/tei:dimensions[@type='written'])[1]/concat(tei:width/string(),' x ',tei:height/string(), ' ', @units))
        let $material as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc)[1]/@material/string())
        let $medium as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote)[1]/@medium/string())
        let $script as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote)[1]/@script/string())
        let $handnote as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote)[1]/string())
        let $deconote as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:decoDesc/tei:decoNote)[1]/string())
        let $condition as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:condition)[1]/string())
        let $writtenlines as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout[1]/@writtenLines/string()))
        let $layout as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout)[1]/string())
        let $foliation as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:foliation)[1]/string())
        let $additions as xs:string := normalize-space(($ms//tei:msDesc/tei:physDesc/tei:additions)[1]/string())
        let $history as xs:string := normalize-space(($ms//tei:msDesc/tei:history)[1]/string())
        for $work at $worknum in $ms//tei:msItem
            let $authors as xs:string* := (for $a in $work/tei:author return normalize-space($a/string()))[string-length() gt 0]
            let $romanizedauthornames as xs:string* := (for $a in $work/tei:author return normalize-space($a/(tei:persName|tei:name)[not(@xml:lang='bo')]/string()))[string-length() gt 0]
            let $tibetanauthornames as xs:string* := (for $a in $work/tei:author return normalize-space($a/(tei:persName|tei:name)[@xml:lang='bo']/string()))[string-length() gt 0]
            let $romanizedtitles as xs:string* := (for $t in $work/tei:title[not(@type='margin') and not(@xml:lang='bo')] return normalize-space($t/string()))[string-length() gt 0]
            let $tibetantitles as xs:string* := (for $t in $work/tei:title[not(@type='margin') and @xml:lang='bo'] return normalize-space($t/string()))[string-length() gt 0]
            let $romanizedmargintitles as xs:string* := (for $t in $work/tei:title[@type='margin' and not(@xml:lang='bo')] return normalize-space($t/string()))[string-length() gt 0]
            let $tibetanmargintitles as xs:string* := (for $t in $work/tei:title[@type='margin' and @xml:lang='bo'] return normalize-space($t/string()))[string-length() gt 0]
            let $incipit as xs:string := normalize-space($work/tei:incipit/string())
            let $explicit as xs:string := normalize-space($work/tei:explicit/string())
            let $colophon as xs:string := normalize-space($work/tei:colophon/string())
            let $note as xs:string := normalize-space($work/tei:note/string())
            let $bibl as xs:string* := for $r in $work/tei:listBibl/tei:bibl/tei:ref return concat(substring-after($r/@target, '#'), ': ', normalize-space($r/string()))
            return
            string-join(
                (
                    $filename,
                    if ($worknum eq 1) then $shelfmark else '',
                    if ($worknum eq 1) then $extent else '',
                    if ($worknum eq 1) then $leafsize else '',
                    if ($worknum eq 1) then $writtensize else '',
                    if ($worknum eq 1) then $material else '',
                    if ($worknum eq 1) then $medium else '',
                    if ($worknum eq 1) then $script else '',
                    if ($worknum eq 1) then $handnote else '',
                    if ($worknum eq 1) then $deconote else '',
                    if ($worknum eq 1) then $condition else '',
                    if ($worknum eq 1) then $writtenlines else '',
                    if ($worknum eq 1) then $layout else '',
                    if ($worknum eq 1) then $foliation else '',
                    if ($worknum eq 1) then $additions else '',
                    if ($worknum eq 1) then $history else '',
                    if ($worknum eq 1) then $head else '',
                    $worknum,
                    string-join($romanizedauthornames, '|'),
                    string-join($tibetanauthornames, '|'),
                    string-join($romanizedtitles, '|'),
                    string-join($tibetantitles, '|'),
                    string-join($romanizedmargintitles, '|'),
                    string-join($tibetanmargintitles, '|'),
                    $incipit,
                    $explicit,
                    $colophon,
                    $note,
                    string-join($bibl, '|'),
                    $newline
                )
                , $tab
            )
}
</dummy>
