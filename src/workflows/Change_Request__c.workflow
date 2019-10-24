<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Change_Request_Administrator_Notification</fullName>
        <description>Change Request Administrator Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Administrative_Email_Templates/Administrator_Change_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Administrator_Notification_NA</fullName>
        <description>Change Request Administrator Notification NA</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <recipient>joyce.drinnin@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Administrative_Email_Templates/Administrator_Change_Request_Notification</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Assigned_To_Notification</fullName>
        <description>Change Request Assigned To Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Change_Request_Assigned_To_Notification</template>
    </alerts>
    <alerts>
        <fullName>Change_Request_Status_Changed_Admin_Notification</fullName>
        <description>Change Request Status Changed_Admin Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>cindi.rella@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joyce.drinnin@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NA_Change_Request_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_CR_Requested_Information_modified_Notification</fullName>
        <description>LA CR Requested Information modified - Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NA_Change_Request_Update_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Change_Request_Status_Changed_Admin_Notification</fullName>
        <description>LA Change Request Status Changed Admin Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>akihiro.yoshida@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jesus.gonzalez@daikin.com.mx.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>shigetomo.komatsu@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NA_Change_Request_Status_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Change_Request_modified_User_Notification</fullName>
        <description>LA_Change Request modified - User Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>amarendar.junuthula@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NA_Change_Request_Update_Notification</template>
    </alerts>
    <alerts>
        <fullName>NA_Change_Request_Update_Notification</fullName>
        <description>NA_Change Request Update Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>Salesforce_Administration</recipient>
            <type>group</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>joyce.drinnin@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NA_Change_Request_Update_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Actual_Completion_Date_to_TODAY</fullName>
        <description>When Request Status is updated to &quot;Completed&quot;, Actual Completion Date = TODAY.</description>
        <field>Actual_Completion_Date__c</field>
        <formula>Today()</formula>
        <name>Actual Completion Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CR_Estimated_Hours_Field_Update</fullName>
        <field>Estimated_Hours__c</field>
        <formula>IF( ISBLANK(Admin_Estimated_Hours__c) , 0,Admin_Estimated_Hours__c)  +  IF(ISBLANK(BA_Estimated_Hours__c),0,BA_Estimated_Hours__c) + If( ISBLANK(Developer_Estimated_hours__c),0,Developer_Estimated_hours__c)</formula>
        <name>CR Estimated Hours Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Status_Approved</fullName>
        <field>Request_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Change Request Status: Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Status_Denied</fullName>
        <field>Request_Status__c</field>
        <literalValue>Denied</literalValue>
        <name>Change Request Status: Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Request_Status_Effort_Estimation</fullName>
        <description>Change Request Status: Effort Estimation</description>
        <field>Request_Status__c</field>
        <literalValue>Effort Estimation</literalValue>
        <name>Change Request Status: Effort Estimation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CR Estimated Hours Field Update</fullName>
        <actions>
            <name>CR_Estimated_Hours_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This Workflow updates Change_Request__c.Estimated_Hours__c field with the sum of Admin Estimated Hours, Developer Estimated Hours and BA Estimated Hours.</description>
        <formula>ISCHANGED( Admin_Estimated_Hours__c ) || ISCHANGED( Developer_Estimated_hours__c ) ||  ISCHANGED( BA_Estimated_Hours__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change Request Assigned To Notification</fullName>
        <actions>
            <name>Change_Request_Assigned_To_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Change_Request__c.Assigned_To__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notifies Assigned To User at initial assignment. Will NOT notify the assigned to user if it was previously assigned to someone else. This would require a workflow rule for each possible User available as the Assigned To.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA CR Requested Information modified - Notification</fullName>
        <actions>
            <name>LA_CR_Requested_Information_modified_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies Selected Administrators when requested information modified on Latin America Change Requests.</description>
        <formula>RecordType.Name = &quot;Latin America&quot; &amp;&amp;  
(ISCHANGED( OwnerId ) || ISCHANGED( Company_Division__c ) || ISCHANGED( Request_Type__c ) || ISCHANGED( Request_Category__c ) || ISCHANGED( Request_Priority_Level__c ) || ISCHANGED( Desired_Completion_Date__c ) || ISCHANGED(  Change_Summary__c  ) || ISCHANGED( Detailed_Change_Description__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LA_Change Request modified - User Notification</fullName>
        <actions>
            <name>LA_Change_Request_modified_User_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notifies change request owners when modified.</description>
        <formula>RecordType.Name = &quot;Latin America&quot; &amp;&amp; 
(NOT( ISCHANGED( Request_Status__c ) ) ||   ISPICKVAL(Request_Status__c, &quot;In Development&quot;) ) &amp;&amp;
( ISCHANGED( Actual_Priority_Level__c ) || ISCHANGED( Actual_Start_Date__c ) || ISCHANGED( Priority_Sequence__c ) || ISCHANGED( Estimated_Hours__c ) || ISCHANGED( Scheduled_Start_Date__c ) || ISCHANGED( Scheduled_Completion_Date__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NA CR Requested Information modified - Notification</fullName>
        <actions>
            <name>Change_Request_Administrator_Notification_NA</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies Selected Administrators when requested information modified on North America Change Requests.</description>
        <formula>RecordType.Name = &quot;North America&quot; &amp;&amp;  
(ISCHANGED( OwnerId ) || ISCHANGED( Company_Division__c ) || ISCHANGED( Request_Type__c ) || ISCHANGED( Request_Category__c ) || ISCHANGED( Request_Priority_Level__c ) || ISCHANGED( Desired_Completion_Date__c ) || ISCHANGED(  Change_Summary__c  ) || ISCHANGED( Detailed_Change_Description__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NA_Change Request modified - User Notification</fullName>
        <actions>
            <name>NA_Change_Request_Update_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies change request owners when modified.</description>
        <formula>RecordType.Name = &quot;North America&quot; &amp;&amp; 
(NOT( ISCHANGED( Request_Status__c ) ) ||   ISPICKVAL(Request_Status__c, &quot;In Development&quot;) ) &amp;&amp;
( ISCHANGED( Actual_Priority_Level__c ) || ISCHANGED( Actual_Start_Date__c ) || ISCHANGED( Priority_Sequence__c ) || ISCHANGED( Estimated_Hours__c ) || ISCHANGED( Scheduled_Start_Date__c ) || ISCHANGED( Scheduled_Completion_Date__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>CR_Effort_Estimation</fullName>
        <assignedTo>mark.lockwood@daikinapplied.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>CR Effort Estimation</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>CR Effort Estimation</subject>
    </tasks>
    <tasks>
        <fullName>LA_CR_Effort_Estimation</fullName>
        <assignedTo>mark.lockwood@daikinapplied.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Please specify Effort Estimation.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>LA CR Effort Estimation</subject>
    </tasks>
</Workflow>
