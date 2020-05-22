<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="/"
    exclude-result-prefixes="xs local tei"
    version="3.0">

    <!-- Created for Driver collection records. Could be used for other uses in the future, but will probably
         require some modification to account for different columns.
         
         To run, convert the spreadsheet to a tab-separated-value text file, and specify that as a parameter, e.g.:
    
         java -Xmx1G -cp ../saxon/saxon9he.jar net.sf.saxon.Transform -it:Main -xsl:tei-from-spreadsheet.xsl infile=driver_collection.tsv nextmsid=133
          
         Optionally, you can also specify the Solr server for a Digital Bodleian instance to attempt to lookup 
         shelfmarks against UUIDs, and create surrogates links for any it finds.
    -->
    
    <!-- Parameters -->
    <xsl:param name="infile" as="xs:string" required="yes"/>
    <xsl:param name="nextmsid" as="xs:integer" required="yes"/>
    
    <!-- Load the local places authority file -->
    <xsl:variable name="authoritysubjects" as="element(tei:item)*" select="document('../../authority/subjects.xml')/tei:TEI/tei:text/tei:body/tei:list/tei:item[@xml:id]"/>

    <!-- Call this template to loop thru records to be created -->
    <xsl:template name="Main">
        <xsl:for-each select="tokenize(unparsed-text($infile, 'utf-8'), '\r?\n')">
            <xsl:if test="position() gt 1 and string-length(.) gt 0">
                <!-- After skipping the header on line 1, each line represents a new TEI record to be created -->
                <xsl:call-template name="CreateTEI">
                    <xsl:with-param name="fields" as="xs:string*" select="for $f in tokenize(., '\t') return normalize-space($f)"/>
                    <xsl:with-param name="msid" select="$nextmsid + position() - 2"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- The template for the TEI file -->
    <xsl:template name="CreateTEI">
        <xsl:param name="fields" as="xs:string*" required="yes"/>
        <xsl:param name="msid" as="xs:integer" required="yes"/>
        
        <xsl:variable name="shelfmarknum" as="xs:string" select="$fields[1]"/>
        <xsl:variable name="shelfmark" as="xs:string" select="concat('MS. Driver. c. ', $shelfmarknum)"/>
        <xsl:variable name="notitle" as="xs:boolean" select="starts-with($fields[2], 'nt')"/>
        <xsl:variable name="romanizedtitle" as="xs:string" select="if (not($notitle)) then $fields[2] else ''"/>
        <xsl:variable name="romanizedincipit" as="xs:string" select="if ($notitle) then substring-after($fields[2], ' ') else ''"/>
        <xsl:variable name="tibetantitle" as="xs:string" select="if (not($notitle)) then $fields[3] else ''"/>
        <xsl:variable name="tibetanincipit" as="xs:string" select="if ($notitle) then $fields[3] else ''"/>
        <xsl:variable name="extent" as="xs:string" select="$fields[4]"/>
        <xsl:variable name="types" as="xs:string*" select="tokenize($fields[5], '[^A-Za-z]+')"/>
        <xsl:variable name="langscript" as="xs:string" select="$fields[6]"/>
        <xsl:variable name="langcode" as="xs:string" select="if ($langscript eq 'bo-Latn-x-EWTS') then 'bo' else ''"/>
        <xsl:variable name="language" as="xs:string" select="if ($langscript eq 'bo-Latn-x-EWTS') then 'Tibetan' else ''"/>
        <xsl:variable name="dimensions" as="xs:string" select="$fields[7]"/>
        <xsl:variable name="width" as="xs:string" select="(tokenize($dimensions, '\D+')[1], '')[1]"/>
        <xsl:variable name="height" as="xs:string" select="(tokenize($dimensions, '\D+')[2], '')[1]"/>
        <xsl:variable name="subject1" as="xs:string" select="replace($fields[8], '\.\s*$', '')"/>
        <xsl:variable name="subject2" as="xs:string" select="replace($fields[9], '\.\s*$', '')"/>
        
        <xsl:variable name="filename" as="xs:string" select="replace(replace($shelfmark, '\*' ,'_star'), '[^A-Za-z0-9_]+', '_')"/>
        
        <xsl:result-document href="../../collections_new/{$filename}.xml" method="xml" encoding="UTF-8" indent="yes">
            
            <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/msdesc/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
            <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/msdesc/consolidated-tei-schema/master/msdesc.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
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
                                <resp when="2020">Summary description</resp>
                                <persName>Charles Manson</persName>
                            </respStmt>
                            <respStmt xml:id="AM">
                                <resp when="2020">Markup and encoding</resp>
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
                                <xsl:value-of select="$filename"/>
                            </idno>
                            <idno type="collection">JESD</idno>
                            <idno type="catalogue">Tibetan</idno>
                        </publicationStmt>
                        <sourceDesc>
                            <msDesc xml:lang="en" xml:id="{ $filename }">
                                <msIdentifier>
                                    <settlement>Oxford</settlement>
                                    <repository>Weston Library</repository>
                                    <collection>John Stapleton Driver Collection</collection>
                                    <idno type="shelfmark">
                                        <xsl:value-of select="$shelfmark"/>
                                    </idno>
                                </msIdentifier>
                                <msContents>
                                    <msItem xml:id="{ $filename }-item1">
                                        <xsl:choose>
                                            <xsl:when test="not($notitle)">
                                                <xsl:if test="string-length($tibetantitle) gt 0">
                                                    <title key="" xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($tibetantitle)"/>
                                                    </title>
                                                </xsl:if>
                                                <xsl:if test="string-length($romanizedtitle) gt 0">
                                                    <title key="" xml:lang="{ $langscript }">
                                                        <xsl:value-of select="normalize-space($romanizedtitle)"/>
                                                    </title>
                                                </xsl:if>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:if test="string-length($tibetanincipit) gt 0">
                                                    <incipit xml:lang="bo">
                                                        <xsl:value-of select="normalize-space($tibetanincipit)"/>
                                                    </incipit>
                                                </xsl:if>
                                                <xsl:if test="string-length($romanizedincipit) gt 0">
                                                    <incipit xml:lang="{ $langscript }">
                                                        <xsl:value-of select="normalize-space($romanizedincipit)"/>
                                                    </incipit>
                                                </xsl:if>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="string-length($langcode) gt 0">
                                            <textLang mainLang="{ $langcode }">
                                                <xsl:if test="string-length($language) gt 0">
                                                    <xsl:value-of select="$language"/>
                                                </xsl:if>
                                            </textLang>
                                        </xsl:if>
                                    </msItem>
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
                                                <xsl:otherwise>
                                                    <xsl:text>other</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <supportDesc material="chart">
                                            <support>
                                                <xsl:text>Paper</xsl:text>
                                            </support>
                                            <extent>
                                                <xsl:value-of select="$extent"/>
                                                <xsl:text> </xsl:text>
                                                <dimensions unit="cm" type="leaf">
                                                    <width>
                                                        <xsl:value-of select="$width"/>
                                                    </width>
                                                    <height>
                                                        <xsl:value-of select="$height"/>
                                                    </height>
                                                </dimensions>
                                            </extent>
                                            <condition>
                                                <xsl:comment> Add description of condition, if applicable, otherwise delete the condition element. See https://git.io/msdescdoc#condition </xsl:comment>
                                            </condition>
                                        </supportDesc>
                                        <layoutDesc>
                                            <layout>
                                                <xsl:comment> Add description of layout, if applicable, otherwise delete the layoutDesc element. See https://git.io/msdescdoc#layoutdesc </xsl:comment>
                                            </layout>
                                        </layoutDesc>
                                    </objectDesc>
                                    <xsl:if test="$types = ('ms')">
                                        <handDesc>
                                            <handNote>
                                                <xsl:comment> Add description of hands, if applicable, otherwise delete the handDesc element. See https://git.io/msdescdoc#handdesc </xsl:comment>
                                            </handNote>
                                        </handDesc>
                                    </xsl:if>
                                    <xsl:if test="$types = ('xyl','print','typeset')">
                                        <typeDesc>
                                            <xsl:for-each select="$types[. = ('xyl','print','typeset')]">
                                                <typeNote medium="{ . }">
                                                    <xsl:choose>
                                                        <xsl:when test=". = 'xyl'">
                                                            <xsl:text>Woodcut print</xsl:text>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(., 2))"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </typeNote>
                                            </xsl:for-each>
                                        </typeDesc>
                                    </xsl:if>
                                    <additions>
                                        <xsl:comment> Add description additions, if applicable, otherwise delete the additions element. See https://git.io/msdescdoc#additions </xsl:comment>
                                    </additions>
                                </physDesc>
                                <history>
                                    <origin>
                                        <xsl:comment> Add origin, if applicable, otherwise delete the origin element. See https://git.io/msdescdoc#origin </xsl:comment>
                                    </origin>
                                    <provenance>
                                        <xsl:comment> Add provenance, if applicable, otherwise delete the provenance element. See https://git.io/msdescdoc#provenance </xsl:comment>
                                    </provenance>
                                    <acquisition when="2016"><persName role="fmo" key="person_286478621">John E. Stapleton Driver</persName> collection, donated by <persName role="dnr" key="person_n2017054713">Prof Felix Driver</persName> to the Bodleian Libraries in 2016</acquisition>
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
                                            <xsl:variable name="subjectterm" as="xs:string" select="."/>
                                            <xsl:variable name="matchedauthority" as="element(tei:item)*" select="$authoritysubjects[tei:term/normalize-space(lower-case(string(.))) = lower-case($subjectterm)]"/>
                                            <xsl:choose>
                                                <xsl:when test="count($matchedauthority) gt 0">
                                                    <xsl:for-each select="$matchedauthority">
                                                        <item>
                                                            <term key="{ @xml:id }">
                                                                <xsl:value-of select="$subjectterm"/>
                                                            </term>
                                                        </item>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:message>Cannot find authority entry for <xsl:value-of select="$subjectterm"/></xsl:message>
                                                    <item>
                                                        <term>
                                                            <xsl:value-of select="$subjectterm"/>
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
                        <p><!--Body paragraph provided for validation and future transcription--></p>
                    </body>
                </text>
            </TEI>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>