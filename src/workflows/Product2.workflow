<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Product_created_in_Salesforce_form_Daikin_Tools</fullName>
        <ccEmails>Salesforcehelp@daikinapplied.com</ccEmails>
        <description>New Product created in Salesforce form Daikin Tools</description>
        <protected>false</protected>
        <recipients>
            <recipient>mark.lockwood@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Product_Created_from_Daikin_Tools</template>
    </alerts>
    <rules>
        <fullName>Product Creation E-Mail Alert</fullName>
        <actions>
            <name>New_Product_created_in_Salesforce_form_Daikin_Tools</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>And(CreatedBy.Username = &quot;DT Interface&quot; ,Name = ProductCode)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
