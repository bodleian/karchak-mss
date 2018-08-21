<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:saxon="http://saxon.sf.net/"
	exclude-result-prefixes="xs"
	version="2.0">
    
    <xsl:output method="xml" indent="no"/>

	<xsl:variable name="newline" select="'&#10;'"/>
	
    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:value-of select="$newline"/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')">
        <xsl:value-of select="$newline"/>
        <xsl:copy/>
        <xsl:if test="preceding::processing-instruction('xml-model')"><xsl:value-of select="$newline"/></xsl:if>
    </xsl:template>

    <xsl:template match="comment()|processing-instruction()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <!-- Reorder the titles within works... -->

	<xsl:template match="tei:msItem[count(tei:title) gt 1]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="(*|text()|comment()|processing-instruction())[not(self::tei:title) and following-sibling::tei:title and not(preceding-sibling::tei:title)]"/>
		    <xsl:apply-templates select="tei:title[@xml:lang='bo']"/>
		    <xsl:value-of select="$newline"/>
		    <xsl:apply-templates select="tei:title[not(@xml:lang='bo' or @xml:lang='bo-Latn-x-LC')]"/>
		    <xsl:value-of select="$newline"/>
		    <xsl:apply-templates select="tei:title[@xml:lang='bo-Latn-x-LC']"/>
		    <xsl:apply-templates select="(*|text()|comment()|processing-instruction())[not(self::tei:title) and preceding-sibling::tei:title]"/>
		</xsl:copy>
	</xsl:template>
    
    <xsl:template match="tei:msItem[count(tei:title) gt 1]/tei:title[@xml:lang='bo']">
        <xsl:copy>
            <xsl:copy-of select="preceding-sibling::tei:title/@key"/>
            <xsl:copy-of select="@*[not(name()='type' and . = 'alt')]"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msItem[count(tei:title) gt 1]/tei:title[@xml:lang='']">
        <xsl:copy-of select="replace(preceding-sibling::text()[1][string-length(normalize-space(.)) eq 0], '\n', '')"/>
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='xml:lang')]"/>
            <xsl:attribute name="xml:lang" select="'bo-Latn-x-EWTS'"/><!-- These were stripped out by convertTibetan2Bodley.xsl, for reasons unknown, so I'm putting them back in -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msItem[count(tei:title) gt 1]/tei:title[@xml:lang='bo-Latn-x-LC']">
        <xsl:copy-of select="replace(preceding-sibling::text()[1][string-length(normalize-space(.)) eq 0], '\n', '')"/>
        <xsl:copy>
            <xsl:copy-of select="preceding-sibling::tei:title/@key"/>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:msItem[count(tei:title) eq 1]/tei:title[@xml:lang='']">
        <xsl:copy>
            <xsl:copy-of select="@*[not(name()='xml:lang')]"/>
            <xsl:attribute name="xml:lang" select="'bo-Latn-x-EWTS'"/><!-- These were stripped out by convertTibetan2Bodley.xsl, for reasons unknown, so I'm putting them back in -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Authors are easier because I constructed these recently -->
    
    <xsl:template match="tei:author[count(tei:persName) eq 3]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:lang" select="'bo'"/>
                <xsl:value-of select="tei:persName[3]"/>
            </xsl:element>
            <xsl:text> (</xsl:text>
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:lang" select="'bo-Latn-x-EWTS'"/>
                <xsl:value-of select="tei:persName[1]"/>
            </xsl:element>
            <xsl:text> / </xsl:text>
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:lang" select="'bo-Latn-x-LC'"/>
                <xsl:value-of select="tei:persName[2]"/>
            </xsl:element>
            <xsl:text>)</xsl:text>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:author[count(tei:persName) eq 2]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:lang" select="'bo'"/>
                <xsl:value-of select="tei:persName[2]"/>
            </xsl:element>
            <xsl:text> (</xsl:text>
            <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="xml:lang" select="'bo-Latn-x-LC'"/>
                <xsl:value-of select="tei:persName[1]"/>
            </xsl:element>
            <xsl:text>)</xsl:text>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>