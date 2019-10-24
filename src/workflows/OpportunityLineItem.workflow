<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LA_Duplicate_Service_Item_Notification_South_Cone</fullName>
        <description>LA Duplicate Service Item Notification - South Cone</description>
        <protected>false</protected>
        <recipients>
            <recipient>amarendar.junuthula@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>elizabeth.monsalve@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Service_Contract_Notification</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Product_Service_Item_Notification</fullName>
        <description>Opportunity Product Service Item Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>astrid.marin@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rolando.mendoza@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_Product_Service_Item_Notification</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Product_Service_Item_Notification_SouthCone</fullName>
        <description>Opportunity Product Service Item Notification- SouthCone</description>
        <protected>false</protected>
        <recipients>
            <recipient>amarendar.junuthula@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>elizabeth.monsalve@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Opportunity_Product_Service_Item_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>LA_Opportunity_Product_Item_Update</fullName>
        <description>This rule updated Opportunity Product item# to 3-digit number by padding &apos;0&apos; to the left of Item#</description>
        <field>Item_Number__c</field>
        <formula>IF(ISNUMBER( Item_Number__c ),  

LPAD(Text(VALUE( Item_Number__c )),3,&apos;0&apos;), Item_Number__c )</formula>
        <name>LA_Opportunity Product Item# Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LA_Provide_VRV_Daikin_Product_Notificati</fullName>
        <description>This Workflow updates the field Provide Product Notification on the Opportunity  when a VRV/Daikin product line item is created.</description>
        <field>Provide_Product_Notification__c</field>
        <literalValue>1</literalValue>
        <name>LA_Provide VRV/Daikin Product Notificati</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LA_Service_Item_Field_Update</fullName>
        <field>Service_Item_Included__c</field>
        <literalValue>Yes</literalValue>
        <name>LA Service Item Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LA_Service_Item_Field_Update_South_Cone</fullName>
        <field>Service_Item_Included__c</field>
        <literalValue>Yes</literalValue>
        <name>LA Service Item Field Update- South Cone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Selling_Price_Update</fullName>
        <field>UnitPrice</field>
        <formula>Unitary_Selling_Price_w_Log_Disc__c</formula>
        <name>Selling Price Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>LA Service Item Field Update - DALA only</fullName>
        <actions>
            <name>Opportunity_Product_Service_Item_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LA_Service_Item_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND (2 OR 3 OR 4 OR 5)) AND 6</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>DALA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>equals</operation>
            <value>Parts,Refrigeration,AAF Filter,Aftermarket,PPM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>contains</operation>
            <value>Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Service_Add_On__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Start_up_Add_On__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.LastModifiedById</field>
            <operation>notEqual</operation>
            <value>Gustavo Corral,Raquel Biollo</value>
        </criteriaItems>
        <description>Service Item Field Update - DALA only. The email notification is duplicate as Rene wants to Email Astrid Marin when a Service/part item included or Service add on or start up add on greater than 0.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA Service Item Field Update - South Cone only</fullName>
        <actions>
            <name>Opportunity_Product_Service_Item_Notification_SouthCone</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LA_Service_Item_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>South Cone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>equals</operation>
            <value>Parts,Refrigeration,AAF Filter,Aftermarket,PPM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>contains</operation>
            <value>Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Service_Add_On__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Start_up_Add_On__c</field>
            <operation>greaterThan</operation>
            <value>USD 0</value>
        </criteriaItems>
        <description>Service Item Field Update - South Cone only. The email notification is duplicate as Rene wants to Email Elizabeth Monsalve when a Service/part item included or Service add on or start up add on greater than 0.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LATAM Commission add-on or any Misc%2E Add ons Notification</fullName>
        <active>false</active>
        <booleanFilter>(1 OR 2 OR 3 OR 4 OR 5) AND(6 OR 7 OR(8 AND 9))</booleanFilter>
        <criteriaItems>
            <field>OpportunityLineItem.Outsource_Add_On__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Misc_Add_On_One_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Misc_Add_On_Two_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Misc_Add_On_Three_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OpportunityLineItem.Misc_Add_On_Four_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>Antigua and Barbuda,Argentina,Aruba,&quot;Bahamas, The&quot;,Barbados,Belize_BLZ,Bermuda Islands,Bonaire,Brazil,Cayman Islands,Costa Rica,Cuba,Curacao,Dominica,Dominican Republic,Ecuador,El Salvador,Grenada,Guatemala,Guyana,Haiti,Honduras</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>Italy-ITA,Jamaica,Nicaragua,Not Available,Panama,Saint Kitts and Nevis,Saint Lucia,Saint Martin,Saint Vincent and The Grenadines,Sint Maarten,Spain-ESP,Suriname,Turks and Caicos Islands,USA-USA,US-Puerto Rico,Venezuela,Virgin Islands</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>DALA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>Other</value>
        </criteriaItems>
        <description>This workflow has an email notification which notifies specified users</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA_Opportunity Product Item%23 Update</fullName>
        <actions>
            <name>LA_Opportunity_Product_Item_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule updated Opportunity Product item# to 3-digit number by padding &apos;0&apos; to the left of Item#</description>
        <formula>ISNUMBER( Item_Number__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LA_Provide VRV%2FDaikin Product Notification</fullName>
        <actions>
            <name>LA_Provide_VRV_Daikin_Product_Notificati</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>equals</operation>
            <value>VRV</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product2.Product_Category__c</field>
            <operation>equals</operation>
            <value>Daikin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Provide_Product_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This Workflow updates the field Provide Product Notification on the Opportunity  when a VRV/Daikin product line item is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Selling Price Update</fullName>
        <actions>
            <name>Selling_Price_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Test Field Update</fullName>
        <active>false</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
