<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Username</fullName>
        <description>Update username with Email.</description>
        <field>IE_Username__c</field>
        <formula>Email</formula>
        <name>Update Username</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Username from IE Contact</fullName>
        <actions>
            <name>Update_Username</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.IE_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <description>If  IE_Contact__c = true and Email is not Null then Update Username with Email.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
