<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Asset_Serial_Number_ID_Update</fullName>
        <description>This rule updates Serial Number ID with Serial Number field when Serial number is valid.</description>
        <field>Serial_Number_ID__c</field>
        <formula>SerialNumber</formula>
        <name>Asset Serial Number ID Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Gateway_Commissioned_Date</fullName>
        <field>Gateway_Commissioned_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Gateway Commissioned Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Asset Serial Number ID Update</fullName>
        <actions>
            <name>Asset_Serial_Number_ID_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Asset.SerialNumber</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Asset.SerialNumber</field>
            <operation>notEqual</operation>
            <value>Unknown,UNKNOWN</value>
        </criteriaItems>
        <description>This rule updates Serial Number ID with Serial Number field when Serial number is valid.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Gateway Commissioned</fullName>
        <actions>
            <name>Update_Gateway_Commissioned_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Asset.Commissioned__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>TRUE when Gateway Commissioned is set to True. Field Update sets Gateway Commissioned Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
