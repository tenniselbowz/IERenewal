<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LatamWebtoLead_Notification_when_a_new_lead_is_created</fullName>
        <description>LatamWebtoLead Notification when a new lead is created</description>
        <protected>false</protected>
        <recipients>
            <recipient>amarendar.junuthula@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rosa.villasmil@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LatamWebtoLead_Owner_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Lead_Opportunity_City_Update</fullName>
        <description>This rule updated Opportunity City to City if City is populated.</description>
        <field>Opportunity_City__c</field>
        <formula>IF(City!=&quot;&quot;, City , Opportunity_City__c )</formula>
        <name>Lead Opportunity City Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Opportunity_State_Update</fullName>
        <description>This field popupated State value in state is not empty</description>
        <field>Opportunity_State__c</field>
        <formula>if(  State  !=&quot;&quot;, State , Opportunity_State__c )</formula>
        <name>Lead Opportunity State Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LatamWebtoLead Notification when a new lead is created</fullName>
        <actions>
            <name>LatamWebtoLead_Notification_when_a_new_lead_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Contact Us Web Page</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <description>This rule sends an email to Latin America.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Update Opportunity City %26 Opportunity State</fullName>
        <actions>
            <name>Lead_Opportunity_City_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Lead_Opportunity_State_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Create workflow rule to populate the Opportunity City &amp; Opportunity State from the City &amp; State standard fields every time the record is edited.  For Lead object.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
