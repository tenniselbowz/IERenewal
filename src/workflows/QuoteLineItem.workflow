<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Temp_Quote_Line_Item_Description</fullName>
        <description>If(Product2.Name = &quot;User Defined Model&quot; || Product2.Name = &quot;Part&quot;,Custom_Description__c,If(LEN(Product2.Name) &gt; 0,Product2.Name &amp; &quot;. &quot; &amp; Custom_Description__c,Custom_Description__c))</description>
        <field>Item_Description__c</field>
        <formula>(If(Product2.Name = &quot;User Defined Model&quot; || Product2.Name = &quot;Part&quot;,Custom_Description__c, 

If( Product_Product_Category__c =&quot;Unitary&quot; ||  Product_Product_Category__c = &quot;VRV&quot; ||  Product_Product_Category__c = &quot;Daikin&quot;,

If(LEN(Product2.Description)&gt;0, Product2.Name &amp; &quot;. &quot; &amp; Product2.Description &amp;&quot;. &quot;&amp; Custom_Description__c, Product2.Name &amp; &quot;. &quot; &amp; Custom_Description__c), Product2.Name &amp; &quot;. &quot; &amp; Custom_Description__c)))</formula>
        <name>Temp - Quote Line Item Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Line_Item_Description</fullName>
        <description>Update Quote Line Item Description</description>
        <field>Item_Description__c</field>
        <formula>If(Product2.Name = &quot;User Defined Model&quot; || Product2.Name = &quot;Part&quot;,Custom_Description__c, 

If( Product_Product_Category__c =&quot;Unitary&quot; || Product_Product_Category__c = &quot;VRV&quot; || Product_Product_Category__c = &quot;Daikin&quot;, 

If(LEN(Product2.Description)&gt;0, Product2.Name &amp; &quot;. &quot; &amp; Product2.Description &amp;&quot;. &quot;&amp; Custom_Description__c, Product2.Name &amp; &quot;. &quot; &amp; Custom_Description__c), Product2.Name &amp; &quot;. &quot; &amp; Custom_Description__c))</formula>
        <name>Update Quote Line Item Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Line_Item_Spanish_Descripti</fullName>
        <description>Update Quote Line Item Spanish Descripti</description>
        <field>Item_Description_Spanish__c</field>
        <formula>If(Product2.Spanish_Product_Name__c = &quot;User Defined Model&quot; || Product2.Spanish_Product_Name__c = &quot;Part&quot;,Custom_Description__c,If(LEN(Product2.Spanish_Product_Name__c) &gt; 0,Product2.Spanish_Product_Name__c &amp; &quot;. &quot; &amp; Custom_Description__c,Custom_Description__c))</formula>
        <name>Update Quote Line Item Spanish Descripti</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Quote Line Item Description</fullName>
        <actions>
            <name>Update_Quote_Line_Item_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Quote Line Item Description</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Spanish Quote Line Item Description</fullName>
        <actions>
            <name>Update_Quote_Line_Item_Spanish_Descripti</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Spanish Quote Line Item Description</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
