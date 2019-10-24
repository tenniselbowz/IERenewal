<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Job_Name_Population</fullName>
        <field>Job_Name__c</field>
        <formula>Asset__r.Order__r.Job_Name__c</formula>
        <name>Job Name Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Model_Population</fullName>
        <field>Model__c</field>
        <formula>Asset__r.Product2.ProductCode</formula>
        <name>Model Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_Line_Population</fullName>
        <field>Product_Class__c</field>
        <formula>Asset__r.Product2.DW_Product_Class__c</formula>
        <name>Product Line Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SO_Number_Population</fullName>
        <field>SO_Number__c</field>
        <formula>Asset__r.Order__r.SO_Number__c</formula>
        <name>SO Number Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Serial_Number_Population</fullName>
        <field>Serial_Number__c</field>
        <formula>Asset__r.SerialNumber</formula>
        <name>Serial Number Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Asset Created or Edited</fullName>
        <actions>
            <name>Job_Name_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Model_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Product_Line_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SO_Number_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Serial_Number_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
