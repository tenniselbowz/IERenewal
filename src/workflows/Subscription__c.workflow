<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Subscription_Active</fullName>
        <description>Subscription Active Rule updates Active field TRUE when the IE Subscription is TRUE.</description>
        <field>Active__c</field>
        <literalValue>1</literalValue>
        <name>Subscription Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Subscription Active</fullName>
        <actions>
            <name>Subscription_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Subscription__c.Active__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Subscription__c.IE_Subscription__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This Rule updates Active field TRUE when the IE Subscription is TRUE.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
