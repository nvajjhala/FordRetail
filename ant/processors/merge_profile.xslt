<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exsl="http://exslt.org/common" xmlns:meta="http://soap.sforce.com/2006/04/metadata" version="1.0" exclude-result-prefixes="meta exsl">
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    <xsl:param name="metadata_type" select="'CustomObject'"/>
    <xsl:param name="current_filename"/>
    <xsl:param name="current_dir"/>
    <xsl:variable name="mergeProfileData" select="document(string(concat($current_dir, $current_filename)))"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="meta:objectPermissionsList" mode="sorting">
        <xsl:for-each select="*">
            <xsl:sort select="meta:object"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="meta:tabVisibilitiesList" mode="sorting">
        <xsl:for-each select="*">
            <xsl:sort select="meta:tab"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="meta:fieldPermissionsList" mode="sorting">
        <xsl:for-each select="*">
            <xsl:sort select="meta:field"/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/meta:Profile">
        <xsl:text>&#10;</xsl:text>
        <xsl:copy>
            <xsl:for-each select="meta:applicationVisibilities">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:categoryGroupVisibilities">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:classAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:custom">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:customMetadataTypeAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:customPermissions">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:customSettingAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:description">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:externalDataSourceAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:fieldLevelSecurities">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <!-- merge field permissions -->
            <xsl:variable name="fieldPermList">
                <xsl:element name="fieldPermissionsList" namespace="{namespace-uri()}">
                    <xsl:if test="$metadata_type = 'CustomField'">
                        <xsl:for-each select="$mergeProfileData/meta:Profile/meta:fieldPermissions">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="meta:fieldPermissions">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:variable name="sortFieldPerm" select="exsl:node-set($fieldPermList)"/>
            <xsl:apply-templates select="$sortFieldPerm/*" mode="sorting"/>
            <xsl:for-each select="meta:flowAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:fullName">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:layoutAssignments">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:loginFlows">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:loginHours">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:loginIpRanges">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <!-- merge object permissions -->
            <xsl:variable name="objectPermList">
                <xsl:element name="objectPermissionsList" namespace="{namespace-uri()}">
                    <xsl:if test="$metadata_type = 'CustomObject'">
                        <xsl:for-each select="$mergeProfileData/meta:Profile/meta:objectPermissions">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="meta:objectPermissions">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:variable name="sortObjPerms" select="exsl:node-set($objectPermList)"/>
            <xsl:apply-templates select="$sortObjPerms/*" mode="sorting"/>
            <xsl:for-each select="meta:pageAccesses">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:profileActionOverrides">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:recordTypeVisibilities">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <!-- merge tab permissions -->
            <xsl:variable name="tabVisibleList">
                <xsl:element name="tabVisibilitiesList" namespace="{namespace-uri()}">
                    <xsl:if test="$metadata_type = 'CustomObject'">
                        <xsl:for-each select="$mergeProfileData/meta:Profile/meta:tabVisibilities">
                            <xsl:copy-of select="."/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="meta:tabVisibilities">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <xsl:variable name="sortTabVis" select="exsl:node-set($tabVisibleList)"/>
            <xsl:apply-templates select="$sortTabVis/*" mode="sorting"/>
            <xsl:for-each select="meta:userLicense">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="meta:userPermissions">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
