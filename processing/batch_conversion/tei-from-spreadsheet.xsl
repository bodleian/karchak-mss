<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="/"
    exclude-result-prefixes="xs local tei"
    version="3.0">

    <!-- Script to generate a TEI file for each row in a spreadsheet of Tibetan manuscript descriptions
        
         Created for Driver collection records. Could be used for other uses in the future, but will probably
         require some modification to account for different columns.
         
         Modified slightly for the second batch of Driver records with a couple of new columns.
         
         Modified again to process Younghusband records
         
         To run, convert the spreadsheet to a tab-separated-value text file, and specify that as a parameter, e.g.:
    
         java -Xmx1G -cp ../saxon/saxon9he.jar net.sf.saxon.Transform -it:Main -xsl:tei-from-spreadsheet.xsl infile=younghusband.tsv nextmsid=992
    -->
    
    <!-- Parameters -->
    <xsl:param name="infile" as="xs:string" required="yes"/>
    <xsl:param name="nextmsid" as="xs:integer" required="yes"/>
    
    <!-- Load the local authority files -->
    <xsl:variable name="authoritysubjects" as="element(tei:item)*" select="document('../../authority/subjects.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id]"/>
    <xsl:variable name="authorityworks" as="element(tei:bibl)*" select="document('../../authority/works.xml')/tei:TEI/tei:text/tei:body/tei:listBibl/tei:bibl[@xml:id]"/>
    <xsl:variable name="authoritypersons" as="element(tei:person)*" select="document('../../authority/persons.xml')/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id]"/>
    
    <xsl:variable name="tab" as="xs:string" select="'&#9;'"/>
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>

    <!-- Call this template to loop thru records to be created -->
    <xsl:template name="Main">
        <xsl:variable name="lines" as="xs:string*" select="tokenize(unparsed-text($infile, 'utf-8'), '\r?\n')"/>
        <xsl:for-each select="$lines">
            <xsl:variable name="pos" as="xs:integer" select="position()"/>
            <xsl:if test="$pos gt 1 and string-length(.) gt 0">
                <!-- After skipping the header on line 1, each line contains metadata about either a manuscript (and its only/first work)
                     or more works on subsequent lines (those start with a tab) -->
                <xsl:choose>
                    <xsl:when test="starts-with(., $tab)">
                        <!-- This is a work within a manuscript, so skip it. It has already been processed along with the parent manuscript. -->
                    </xsl:when>
                    <xsl:when test="starts-with($lines[$pos+1], $tab)">
                        <!-- This is a manuscript with more works on following lines -->
                        <xsl:call-template name="CreateTEI">
                            <xsl:with-param name="line" select="."/>
                            <xsl:with-param name="msid" select="$nextmsid + count($lines[position() lt $pos][not(starts-with(., $tab))])"/>
                            <xsl:with-param name="moreworks" as="xs:string*">
                                <xsl:for-each select="$lines[position() gt $pos]">
                                    <xsl:variable name="counter" as="xs:integer" select="$pos + position()"/>
                                    <xsl:if test="every $line in $lines[position() gt $pos and position() le $counter] satisfies starts-with($line, $tab)">
                                        <xsl:value-of select="."/>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- This is a manuscript containing a single work, all on one line -->
                        <xsl:call-template name="CreateTEI">
                            <xsl:with-param name="line" select="."/>
                            <xsl:with-param name="msid" select="$nextmsid + count($lines[position() lt $pos][not(starts-with(., $tab))])"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- The template for the TEI file -->
    <xsl:template name="CreateTEI">
        <xsl:param name="line" as="xs:string" required="yes"/>
        <xsl:param name="msid" as="xs:integer" required="yes"/>
        <xsl:param name="moreworks" as="xs:string*" required="no"/>

            <xsl:variable name="fields" as="xs:string*" select="for $f in tokenize($line, '\t') return normalize-space($f)"/>
            <xsl:variable name="oldfilename" as="xs:string" select="$fields[1]"/>
            <xsl:variable name="shelfmark" as="xs:string" select="$fields[2]"/>
            <xsl:variable name="newfilename" as="xs:string" select="concat(translate(normalize-space(replace($shelfmark, '[^A-Za-z0-9]', ' ')), ' ', '_'), '.xml')"/>
            <xsl:variable name="extent" as="xs:string" select="$fields[3]"/>
            <xsl:variable name="langscript" as="xs:string" select="$fields[4]"/>
            <xsl:variable name="langcode" as="xs:string" select="if ($langscript eq 'bo-Latn-x-EWTS') then 'bo' else ''"/>
            <xsl:variable name="language" as="xs:string" select="if ($langscript eq 'bo-Latn-x-EWTS') then 'Tibetan' else ''"/>
            <xsl:variable name="leafsize" as="xs:string" select="$fields[5]"/>
            <xsl:variable name="leafwidth" as="xs:string" select="(tokenize($leafsize, '\D+')[1], '')[1]"/>
            <xsl:variable name="leafheight" as="xs:string" select="(tokenize($leafsize, '\D+')[2], '')[1]"/>
            <xsl:variable name="writtensize" as="xs:string" select="$fields[6]"/>
            <xsl:variable name="writtenwidth" as="xs:string" select="(tokenize($writtensize, '\D+')[1], '')[1]"/>
            <xsl:variable name="writtenheight" as="xs:string" select="(tokenize($writtensize, '\D+')[2], '')[1]"/>
            <xsl:variable name="subject1" as="xs:string" select="replace($fields[7], '\.\s*$', '')"/>
            <xsl:variable name="subject2" as="xs:string" select="replace($fields[8], '\.\s*$', '')"/>
            <xsl:variable name="material" as="xs:string" select="$fields[9]"/>
            <xsl:variable name="medium" as="xs:string" select="$fields[10]"/>
            <xsl:variable name="mediumattr" as="xs:string" select="normalize-space(replace($medium, '[^A-Za-z0-0]', ' '))"/>
            <xsl:variable name="mediumtext" as="xs:string" select="concat(translate($mediumattr, ' ', '/'), ' ink')"/>
            <xsl:variable name="script" as="xs:string" select="$fields[11]"/>
            <xsl:variable name="hands" as="xs:string" select="$fields[12]"/>
            <xsl:variable name="decoration" as="xs:string" select="$fields[13]"/>
            <xsl:variable name="condition" as="xs:string" select="$fields[14]"/>
            <xsl:variable name="writtenlines" as="xs:string" select="$fields[15]"/>
            <xsl:variable name="layout" as="xs:string" select="$fields[16]"/>
            <xsl:variable name="foliation" as="xs:string" select="$fields[17]"/>
            <xsl:variable name="additions" as="xs:string" select="$fields[18]"/>
            <xsl:variable name="acquisition" as="xs:string" select="$fields[19]"/>
            <xsl:variable name="summary" as="xs:string" select="$fields[20]"/>
            <xsl:variable name="types" as="xs:string*" select="('roll')"/><!-- The types column isn't used in this batch, but all seem to be all rolls -->
            <xsl:variable name="idprefix" as="xs:string" select="substring-before($newfilename, '.')"/>
            
            <xsl:result-document href="../../younghusband/{$newfilename}" method="xml" encoding="UTF-8" indent="yes">
                
                <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/msdesc/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/msdesc/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <xsl:value-of select="$newline"/>
                <xsl:value-of select="$newline"/>
                <TEI xmlns="http://www.tei-c.org/ns/1.0"
                    xmlns:tei="http://www.tei-c.org/ns/1.0"
                    xml:id="manuscript_{ $msid }">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>
                                    <xsl:value-of select="$shelfmark"/>
                                </title>
                                <respStmt xml:id="CEM">
                                    <resp when="2021">Summary description</resp>
                                    <persName>Charles Manson</persName>
                                </respStmt>
                                <respStmt xml:id="AM">
                                    <resp when="2023">Markup and encoding</resp>
                                    <persName>Andrew Morrison</persName>
                                    <note>Conversion from spreadsheet to TEI</note>
                                </respStmt>
                            </titleStmt>
                            <editionStmt>
                                <edition>TEI P5</edition>
                            </editionStmt>
                            <publicationStmt>
                                <publisher>Bodleian Libraries</publisher>
                                <pubPlace>
                                    <address>
                                        <orgName type="department">Special Collections</orgName>
                                        <orgName type="unit">Bodleian Libraries</orgName>
                                        <orgName type="institution">University of Oxford</orgName>
                                        <street>Broad Street</street>
                                        <settlement>Oxford</settlement>
                                        <postCode>OX1 3BG</postCode>
                                        <country>United Kingdom</country>
                                        <addrLine>
                                            <ref target="http://yeshiuk.blogspot.com/">Tibetan subject librarian at the Bodleian Library</ref>
                                        </addrLine>
                                        <addrLine>
                                            <email>charles.manson@bodleian.ox.ac.uk</email>
                                        </addrLine>
                                    </address>
                                </pubPlace>
                                <distributor>
                                    <email>specialcollections.enquiries@bodleian.ox.ac.uk</email>
                                </distributor>
                                <availability>
                                    <licence target="https://creativecommons.org/publicdomain/zero/1.0/">This summary description is released under a CC0 licence.</licence>
                                </availability>
                                <idno>UkOxU</idno>
                                <availability status="restricted">
                                    <p>Special Collections Reading Room, Bodleian.</p>
                                </availability>
                                <idno type="msID">
                                    <xsl:value-of select="$idprefix"/>
                                </idno>
                                <idno type="collection">JESD</idno>
                                <idno type="catalogue">Tibetan</idno>
                            </publicationStmt>
                            <sourceDesc>
                                <msDesc xml:lang="en" xml:id="{ $idprefix }">
                                    <msIdentifier>
                                        <country>United Kingdom</country>
                                        <settlement>Oxford</settlement>
                                        <institution>Oxford University</institution>
                                        <repository>Weston Library</repository>
                                        <collection>Younghusband Collection</collection>
                                        <idno type="shelfmark">
                                            <xsl:value-of select="$shelfmark"/>
                                        </idno>
                                    </msIdentifier>
                                    <xsl:if test="string-length($summary) gt 0">
                                        <head>
                                            <xsl:value-of select="$summary"/>
                                        </head>
                                    </xsl:if>
                                    <msContents>
                                        <xsl:for-each select="($line, $moreworks)">
                                            <xsl:variable name="workfields" as="xs:string*" select="for $f in tokenize(., '\t') return normalize-space($f)"/>
                                            <xsl:variable name="romanizedauthor" as="xs:string" select="$workfields[22]"/>
                                            <xsl:variable name="tibetanauthor" as="xs:string" select="$workfields[23]"/>          
                                            <xsl:variable name="romanizedtitle" as="xs:string" select="$workfields[24]"/>
                                            <xsl:variable name="tibetantitle" as="xs:string" select="$workfields[25]"/>
                                            <xsl:variable name="romanizedmargintitle" as="xs:string" select="$workfields[26]"/>
                                            <xsl:variable name="tibetanmargintitle" as="xs:string" select="$workfields[27]"/>
                                            <xsl:variable name="incipit" as="xs:string" select="$workfields[28]"/>
                                            <xsl:variable name="explicit" as="xs:string" select="$workfields[29]"/>
                                            <xsl:variable name="colophon" as="xs:string" select="$workfields[30]"/>
                                            <xsl:variable name="notes" as="xs:string" select="$workfields[31]"/>
                                            <xsl:variable name="bibrefs" as="xs:string*" select="tokenize($workfields[32], '\|')"/>
                                            <msItem xml:id="{ $idprefix }-item{ position()}">
                                                <xsl:variable name="matchedworkids" as="xs:string*" select="local:lookupAuthority(($tibetantitle, $romanizedtitle)[not(. eq '')], $authorityworks, 'works')"/>
                                                <xsl:if test="string-length($tibetantitle) gt 0">
                                                    <title key="{ $matchedworkids[1] }" xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($tibetantitle)"/>
                                                    </title>
                                                </xsl:if>
                                                <xsl:if test="string-length($romanizedtitle) gt 0">
                                                    <title key="{ $matchedworkids[1] }" xml:lang="{ $langscript }">
                                                        <xsl:value-of select="normalize-space($romanizedtitle)"/>
                                                    </title>
                                                </xsl:if>
                                                <xsl:if test="string-length($tibetanmargintitle) gt 0">
                                                    <title type="margin" xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($tibetanmargintitle)"/>
                                                    </title>
                                                </xsl:if>
                                                <xsl:if test="string-length($romanizedmargintitle) gt 0">
                                                    <title type="margin" xml:lang="{ $langscript }">
                                                        <xsl:value-of select="normalize-space($romanizedmargintitle)"/>
                                                    </title>
                                                </xsl:if>
                                                <xsl:if test="count(($tibetanauthor, $romanizedauthor)[not(. eq '')]) gt 0">
                                                    <xsl:variable name="matchedpersonids" as="xs:string*" select="local:lookupAuthority(($tibetanauthor, $romanizedauthor)[not(. eq '')], $authoritypersons, 'persons')"/>
                                                    <author key="{ $matchedpersonids[1] }">
                                                        <xsl:if test="string-length($tibetanauthor) gt 0">
                                                            <persName xml:lang="bo">
                                                                <xsl:value-of select="normalize-space($tibetanauthor)"/>
                                                            </persName>
                                                        </xsl:if>
                                                        <xsl:if test="string-length($tibetanauthor) gt 0 and string-length($romanizedauthor) gt 0">
                                                            <xsl:text> (</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if test="string-length($romanizedauthor) gt 0">
                                                            <persName xml:lang="{ $langscript }">
                                                                <xsl:value-of select="normalize-space($romanizedauthor)"/>
                                                            </persName>
                                                        </xsl:if>
                                                        <xsl:if test="string-length($tibetanauthor) gt 0 and string-length($romanizedauthor) gt 0">
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                    </author>
                                                </xsl:if>
                                                <xsl:if test="string-length($notes) gt 0">
                                                    <note>
                                                        <xsl:value-of select="normalize-space($notes)"/>
                                                    </note>
                                                </xsl:if>
                                                <xsl:if test="string-length($incipit) gt 0">
                                                    <incipit xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($incipit)"/>
                                                    </incipit>
                                                </xsl:if>
                                                <xsl:if test="string-length($explicit) gt 0">
                                                    <explicit xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($explicit)"/>
                                                    </explicit>
                                                </xsl:if>
                                                <xsl:if test="string-length($colophon) gt 0">
                                                    <colophon xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($colophon)"/>
                                                    </colophon>
                                                </xsl:if>
                                                <xsl:if test="string-length($langcode) gt 0">
                                                    <textLang mainLang="{ $langcode }">
                                                        <xsl:if test="string-length($language) gt 0">
                                                            <xsl:value-of select="$language"/>
                                                        </xsl:if>
                                                    </textLang>
                                                </xsl:if>
                                                <xsl:if test="string-length($bibrefs) gt 0">
                                                    <listBibl>
                                                        <xsl:analyze-string select="$bibrefs" regex="(\S+): (\S+)">
                                                            <xsl:matching-substring>
                                                                <bibl type="{ lower-case(regex-group(1)) }">
                                                                    <xsl:value-of select="regex-group(1)"/>
                                                                    <xsl:text>: </xsl:text>
                                                                    <xsl:value-of select="regex-group(2)"/>
                                                                </bibl>
                                                            </xsl:matching-substring>
                                                            <xsl:non-matching-substring>
                                                                <xsl:if test="string-length(normalize-space(.)) gt 0">
                                                                    <bibl>
                                                                        <xsl:value-of select="normalize-space(.)"/>
                                                                    </bibl>
                                                                </xsl:if>
                                                            </xsl:non-matching-substring>
                                                        </xsl:analyze-string>
                                                    </listBibl>
                                                </xsl:if>
                                            </msItem>
                                        </xsl:for-each>
                                    </msContents>
                                    <physDesc>
                                        <objectDesc>
                                            <xsl:attribute name="form">
                                                <xsl:choose>
                                                    <xsl:when test="count($types) eq 1 and $types[1] eq 'xyl'">
                                                        <xsl:text>bp_pothi</xsl:text>
                                                    </xsl:when>
                                                    <xsl:when test="count($types) eq 1 and $types[1] eq 'ms'">
                                                        <xsl:text>ms_pothi</xsl:text>
                                                    </xsl:when>
                                                    <xsl:when test="count($types) eq 1 and $types[1] eq 'roll'">
                                                        <xsl:text>roll</xsl:text>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:text>other</xsl:text>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:attribute>
                                            <supportDesc>
                                                <xsl:if test="string-length($material) gt 0">
                                                    <xsl:attribute name="material" select="lower-case($material)"/>
                                                    <support>
                                                        <xsl:choose>
                                                            <xsl:when test="lower-case($material) eq 'chart'">
                                                                <xsl:text>Paper</xsl:text>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$material"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </support>
                                                </xsl:if>
                                                <extent>
                                                    <xsl:value-of select="$extent"/>
                                                    <xsl:text> </xsl:text>
                                                    <xsl:if test="string-length($leafsize) gt 0">
                                                        <dimensions unit="cm" type="leaf">
                                                            <width>
                                                                <xsl:value-of select="$leafwidth"/>
                                                            </width>
                                                            <height>
                                                                <xsl:value-of select="$leafheight"/>
                                                            </height>
                                                        </dimensions>
                                                    </xsl:if>
                                                    <xsl:if test="string-length($writtensize) gt 0">
                                                        <dimensions unit="cm" type="written">
                                                            <width>
                                                                <xsl:value-of select="$writtenwidth"/>
                                                            </width>
                                                            <height>
                                                                <xsl:value-of select="$writtenheight"/>
                                                            </height>
                                                        </dimensions>
                                                    </xsl:if>
                                                </extent>
                                                <xsl:if test="string-length($foliation) gt 0">
                                                    <foliation>
                                                        <xsl:value-of select="$foliation"/>
                                                    </foliation>
                                                </xsl:if>
                                                <xsl:if test="string-length($condition) gt 0">
                                                    <condition>
                                                        <xsl:value-of select="$condition"/>
                                                    </condition>
                                                </xsl:if>
                                            </supportDesc>
                                            <xsl:if test="string-length($writtenlines) gt 0 or string-length($layout) gt 0">
                                                <layoutDesc>
                                                    <layout>
                                                        <xsl:if test="string-length($writtenlines) gt 0">
                                                            <xsl:attribute name="writtenLines" select="$writtenlines"/>
                                                        </xsl:if>
                                                        <xsl:if test="string-length($writtenlines) gt 0">
                                                            <p>
                                                                <xsl:value-of select="$layout"/>
                                                            </p>
                                                        </xsl:if>
                                                    </layout>
                                                </layoutDesc>
                                            </xsl:if>
                                        </objectDesc>
                                        <xsl:if test="$types = ('ms', 'roll') and (string-length($script) gt 0 or string-length($hands) gt 0)">
                                            <handDesc>
                                                <xsl:if test="string-length($script) gt 0">
                                                    <handNote>
                                                        <xsl:if test="string-length($medium) gt 0">
                                                            <xsl:attribute name="medium" select="lower-case($mediumattr)"/>
                                                        </xsl:if>
                                                        <xsl:choose>
                                                            <xsl:when test="$script eq 'dbu can'">
                                                                <xsl:attribute name="script">print</xsl:attribute>
                                                                <xsl:value-of select="$script"/>
                                                            </xsl:when>
                                                            <xsl:when test="$script eq 'dbu med'">
                                                                <xsl:attribute name="script">cursive</xsl:attribute>
                                                                <xsl:value-of select="$script"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$script"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:if test="string-length($medium) gt 0">
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:value-of select="$mediumtext"/>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                    </handNote>
                                                </xsl:if>
                                                <xsl:if test="string-length($hands) gt 0">
                                                    <handNote>
                                                        <xsl:value-of select="$hands"/>
                                                    </handNote>
                                                </xsl:if>
                                            </handDesc>
                                        </xsl:if>
                                        <xsl:if test="string-length($decoration) gt 0">
                                            <decoDesc>
                                                <decoNote>
                                                    <xsl:value-of select="$decoration"/>
                                                </decoNote>
                                            </decoDesc>
                                        </xsl:if>
                                        <xsl:if test="$types = ('xyl','print','typeset')">
                                            <typeDesc>
                                                <xsl:for-each select="$types[. = ('xyl','print','typeset')]">
                                                    <typeNote medium="{ if(string-length($medium) gt 0) then lower-case($mediumattr) else . }">
                                                        <xsl:choose>
                                                            <xsl:when test="$script eq 'dbu can'">
                                                                <xsl:attribute name="script">print</xsl:attribute>
                                                            </xsl:when>
                                                            <xsl:when test="$script eq 'dbu med'">
                                                                <xsl:attribute name="script">cursive</xsl:attribute>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:choose>
                                                            <xsl:when test=". = 'xyl'">
                                                                <xsl:text>Woodcut print</xsl:text>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(., 2))"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:if test="string-length($script) gt 0">
                                                            <xsl:text> (</xsl:text>
                                                            <xsl:value-of select="$script"/>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                    </typeNote>
                                                </xsl:for-each>
                                            </typeDesc>
                                        </xsl:if>
                                        <xsl:if test="string-length($additions) gt 0">
                                            <additions>
                                                <xsl:value-of select="$additions"/>
                                            </additions>
                                        </xsl:if>
                                    </physDesc>
                                    <history>
                                        <!--
                                        <origin>
                                            <xsl:comment> Add origin, if applicable, otherwise delete the origin element. See https://git.io/msdescdoc#origin </xsl:comment>
                                        </origin>
                                        <provenance>
                                            <xsl:comment> Add provenance, if applicable, otherwise delete the provenance element. See https://git.io/msdescdoc#provenance </xsl:comment>
                                        </provenance>
                                        -->
                                        <xsl:if test="string-length($acquisition) gt 0">
                                            <acquisition>
                                                <xsl:value-of select="$acquisition"/>
                                            </acquisition>
                                        </xsl:if>
                                    </history>
                                    <additional>
                                        <adminInfo>
                                            <availability status="restricted">
                                                <p>Bodleian: Special Collections Reading Room.</p>
                                            </availability>
                                        </adminInfo>
                                    </additional>
                                </msDesc>
                            </sourceDesc>
                        </fileDesc>
                        <profileDesc>
                            <textClass>
                                <xsl:if test="count(($subject1, $subject2)[not(. eq '')]) gt 0">
                                    <keywords scheme="#LCSH">
                                        <list>
                                            <xsl:for-each select="distinct-values(($subject1, $subject2)[not(. eq '')])">
                                                <xsl:variable name="matchedsubjectids" as="xs:string*" select="local:lookupAuthority(., $authoritysubjects, 'subjects')"/>
                                                <xsl:choose>
                                                    <xsl:when test="count($matchedsubjectids) gt 0">
                                                        <item>
                                                            <term key="{ $matchedsubjectids[1] }">
                                                                <xsl:value-of select="."/>
                                                            </term>
                                                        </item>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <item>
                                                            <term>
                                                                <xsl:value-of select="."/>
                                                            </term>
                                                        </item>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </list>
                                    </keywords>
                                </xsl:if>
                            </textClass>
                        </profileDesc>
                        <revisionDesc>
                            <change when="{ substring(string(current-date()), 0, 11) }">Record created.</change>
                        </revisionDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <p>
                                <xsl:comment>Body paragraph provided for validation and future transcription</xsl:comment>
                            </p>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        
        
    </xsl:template>
    
    
    <xsl:function name="local:lookupAuthority" as="xs:string*">
        <xsl:param name="values" as="xs:string*"/>
        <xsl:param name="authority" as="element()*"/>
        <xsl:param name="authorityname" as="xs:string"/>
        <xsl:variable name="returnvalues" as="xs:string*">
            <xsl:for-each select="distinct-values($values[not(. eq '')])">
                <xsl:variable name="value" as="xs:string" select="."/>
                <xsl:variable name="matchedauthority" as="element()*" select="$authority[(tei:title|tei:persName|tei:term)/normalize-space(lower-case(translate(string(.), '.-', ''))) = lower-case(translate($value, '.-', ''))]"/>
                <xsl:if test="count($matchedauthority) gt 0">
                    <xsl:sequence select="$matchedauthority/@xml:id/data()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($returnvalues) gt 0">
                <xsl:sequence select="$returnvalues"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Cannot find entry in <xsl:value-of select="$authorityname"/> for: <xsl:value-of select="string-join($values, ' | ')"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

</xsl:stylesheet>