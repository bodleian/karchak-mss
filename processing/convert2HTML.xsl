<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:bod="http://www.bodleian.ox.ac.uk/bdlss"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei html xs bod"
    version="2.0">
    
    <xsl:import href="https://raw.githubusercontent.com/bodleian/consolidated-tei-schema/master/msdesc2html.xsl"/>

    <!-- Only set this variable if you want full URLs hardcoded into the HTML
         on the web site (previewManuscript.xsl overrides this to do so when previewing.) -->
    <xsl:variable name="website-url" as="xs:string" select="''"/>

    <!-- Any templates added below will override the templates in the shared
         imported stylesheet, allowing customization of manuscript display for each catalogue. -->

    
    
    <!-- The next two templates override the default by putting authors, editors and titles on separate lines, because in Tibetan there are often
         titles in different languages, which gets confusing all on one line -->
    
    <xsl:template match="msItem/title">
        <div class="tei-title">
            <span class="tei-label">
                <xsl:choose>
                    <xsl:when test="@type = 'margin'">
                        <xsl:copy-of select="bod:standardText('Margin title:')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="bod:standardText('Title:')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:copy-of select="bod:direction(.)"/>
                        <xsl:choose>
                            <xsl:when test="@xml:lang = 'bo'">
                                <!-- Do not display Tibetan titles in italic -->
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                <span>
                                    <xsl:if test="not(@type = 'desc')">
                                        <xsl:attribute name="class" select="'italic'"/>
                                    </xsl:if>
                                    <xsl:choose>
                                        <xsl:when test="@xml:lang = 'bo-Latn-x-EWTS'">
                                            <xsl:attribute name="title">
                                                <xsl:text>Wylie transliteration</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="class" select="'italic wylie-translit'"/>
                                        </xsl:when>
                                        <xsl:when test="@xml:lang = 'bo-Latn-x-LC'">
                                            <xsl:attribute name="title">
                                                <xsl:text>Library of Congress transliteration</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="class" select="'italic lc-translit'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="class" select="'italic'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:apply-templates/>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="bod:direction(.)"/>
                    <xsl:choose>
                        <xsl:when test="@xml:lang = 'bo'">
                            <!-- Do not display Tibetan titles in italic -->
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <span>
                                <xsl:if test="not(@type = 'desc')">
                                    <xsl:attribute name="class" select="'italic'"/>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="@xml:lang = 'bo-Latn-x-EWTS'">
                                        <xsl:attribute name="title">
                                            <xsl:text>Wylie transliteration</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="class" select="'italic wylie-translit'"/>
                                    </xsl:when>
                                    <xsl:when test="@xml:lang = 'bo-Latn-x-LC'">
                                        <xsl:attribute name="title">
                                            <xsl:text>Library of Congress transliteration</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="class" select="'italic lc-translit'"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class" select="'italic'"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:apply-templates/>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/author">
        <div class="tei-author">
            <span class="tei-label">
                <xsl:copy-of select="bod:standardText('Author:')"/>
                <xsl:text> </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
                    <a class="author">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xsl:template match="msItem/editor">
        <xsl:variable name="rolelabel" as="xs:string" select="if(@role) then bod:personRoleLookup(@role) else 'Editor'"/>
        <div class="tei-editor">
            <span class="tei-label">
                <xsl:value-of select="$rolelabel"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:choose>
                <xsl:when test="@key and not(@key='')">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$website-url"/>
                            <xsl:text>/catalog/</xsl:text>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="persName[not(@key)]">
        <span>
            <xsl:attribute name="class">
                <xsl:value-of select="string-join((name(), @role), ' ')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="@xml:lang = 'bo-Latn-x-EWTS'">
                    <xsl:attribute name="title">
                        <xsl:text>Wylie transliteration</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class" select="'wylie-translit'"/>
                </xsl:when>
                <xsl:when test="@xml:lang = 'bo-Latn-x-LC'">
                    <xsl:attribute name="title">
                        <xsl:text>Library of Congress transliteration</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="class" select="'lc-translit'"/>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    
    <!-- Move bibliographic references (which can include a links to the digitial surrogates but those are not tagged any differently) 
         so they appear under a separate subheading. First override their display in document order... -->
    <xsl:template match="msItem/listBibl"></xsl:template>
    
    <!-- ...then implement a named-template that will be called at the appropriate point in msdesc2html.xsl to display after the rest 
         of the item description but before nested msItems, if any. The context for this template is the msItem. -->
    <xsl:template name="MsItemFooter">
        <xsl:if test="listBibl/bibl">
            <xsl:choose>
                <xsl:when test="@n or ancestor::msItem[@xml:id and title] or following-sibling::msItem or preceding-sibling::msItem">
                    <h4>
                        <xsl:copy-of select="bod:standardText('References')"/>
                    </h4>
                </xsl:when>
                <xsl:otherwise>
                    <h3>
                        <xsl:copy-of select="bod:standardText('References')"/>
                    </h3>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Return control back to msdesc2html.xsl -->
            <xsl:apply-templates select="listBibl/bibl"/>
        </xsl:if>
    </xsl:template>
    
    
    
    <!-- This implements a named-template that will be called at the appropriate point in msdesc2html.xsl to display
         at the very end of the HTML generated by the XSL (which on the web site means just before the "Comments" subheading). -->
    <xsl:template name="Footer">
        <xsl:variable name="profiledesc" as="element()*" select="/TEI//profileDesc"/>
        <xsl:if test="count($profiledesc//term) gt 0">
            <div class="subjects">
                <h3>
                    <xsl:copy-of select="bod:standardText('Subjects')"/>
                </h3>
                <ul>
                    <!-- First the terms with keys, which can be turned into links to their entry in the subjects index -->
                    <xsl:for-each select="distinct-values($profiledesc//term/@key)">
                        <xsl:variable name="key" as="xs:string" select="."/>
                        <xsl:variable name="termswiththiskey" as="xs:string*" select="distinct-values(for $term in $profiledesc//term[@key = $key] return normalize-space(string-join($term//text(), ' ')))[string-length() gt 0]"/>
                        <li>
                            <a>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="$website-url"/>
                                    <xsl:text>/catalog/</xsl:text>
                                    <xsl:value-of select="$key"/>
                                </xsl:attribute>
                                <xsl:for-each select="$termswiththiskey">
                                    <!-- Merge variant forms of the same subject (e.g. Word history and Universal History) into one link -->
                                    <xsl:value-of select="."/>
                                    <xsl:if test="position() ne last()">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </a>
                        </li>
                    </xsl:for-each>
                    
                    <!-- Next the terms without keys, which can only be displayed as text -->
                    <xsl:for-each select="distinct-values(for $term in $profiledesc//term[not(@key)] return normalize-space(string-join($term//text(), ' ')))[string-length() gt 0]">
                        <li>
                            <xsl:value-of select="."/>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
    </xsl:template>
    
    
    <!-- In Karchak, custodialHist contains nothing but a custEvent of @type "check". Do not display. -->
    <xsl:template match="custodialHist"></xsl:template>


</xsl:stylesheet>
