<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Activity_Type</fullName>
        <description>Update the Activity Type with the Type to make it reportable</description>
        <field>Activity_Type__c</field>
        <formula>TEXT(Type)</formula>
        <name>Activity Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Activity Type</fullName>
        <actions>
            <name>Activity_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Type</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Copies the Type from the Task to the Activity Type field so it&apos;s reportable</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
