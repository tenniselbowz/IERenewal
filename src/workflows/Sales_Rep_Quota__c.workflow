<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>User_Name_Population</fullName>
        <field>User_Name__c</field>
        <formula>User__r.FirstName &amp; &quot; &quot; &amp; User__r.LastName</formula>
        <name>User Name Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Sales Rep Quota TRUE</fullName>
        <actions>
            <name>User_Name_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Evaluates to TRUE on creation and every edit.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
