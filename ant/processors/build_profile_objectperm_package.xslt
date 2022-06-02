<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:exsl="http://exslt.org/common"
xmlns:meta="http://soap.sforce.com/2006/04/metadata"
exclude-result-prefixes="meta exsl">

<xsl:output method="xml" version="1.0"
encoding="UTF-8" indent="yes"/>

<xsl:strip-space elements="meta:types"/>

<xsl:param name="metadataType" select="'CustomField'"/>
<xsl:param name="mergeFromFilename" />
<xsl:variable name="mergeFromXml" select="document(string($mergeFromFilename))" />


<xsl:template match="*">
    <xsl:copy-of select="." />
</xsl:template>

<!-- build object and profile package -->
<xsl:template name="CustomObject" >
    <xsl:apply-templates select="$mergeFromXml/meta:Package/meta:types[meta:name='CustomObject']" />
</xsl:template>

<xsl:template name="CustomField" >
    <xsl:apply-templates select="$mergeFromXml/meta:Package/meta:types[meta:name='CustomField']" />
</xsl:template>

<xsl:template match="/meta:Package">
    <xsl:text>&#10;</xsl:text>
    <xsl:copy>

        <xsl:if test="$metadataType = 'CustomObject'">
            <xsl:call-template name="CustomObject"/>
        </xsl:if>

        <xsl:if test="$metadataType = 'CustomField'">
            <xsl:call-template name="CustomField"/>
        </xsl:if>

        <xsl:apply-templates select="meta:types[meta:name='Profile']" />
        <xsl:apply-templates select="meta:version" />
    </xsl:copy>
</xsl:template>

</xsl:stylesheet>
