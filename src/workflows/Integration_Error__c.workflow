<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Integration_Error_Alert</fullName>
        <description>Integration Error Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Administrative_Email_Templates/Integration_Error_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Intel_Integration_Error</fullName>
        <description>Intel Integration Error: Model Not Found</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Intel_Notification</template>
    </alerts>
    <rules>
        <fullName>Integration Error Creation</fullName>
        <actions>
            <name>Integration_Error_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>True whenever an Integration Error Record is created.</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Intel Notification</fullName>
        <actions>
            <name>Intel_Integration_Error</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Integration_Error__c.Integration_Point__c</field>
            <operation>equals</operation>
            <value>Intel TAS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Integration_Error__c.Error_Description__c</field>
            <operation>contains</operation>
            <value>Above model name and revision number combination was not found in Intel.</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
