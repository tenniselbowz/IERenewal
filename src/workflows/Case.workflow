<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_TRC_AAH_Public_Group_Members</fullName>
        <description>Notify TRC - AAH Public Group Members</description>
        <protected>false</protected>
        <recipients>
            <recipient>TRC_AAH</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRC/SUPPORTNewCaseassignmentnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_TRC_ATS_Public_Group_Members</fullName>
        <description>Notify TRC - ATS Public Group Members</description>
        <protected>false</protected>
        <recipients>
            <recipient>TRC_ATS</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRC/SUPPORTNewCaseassignmentnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_TRC_Chiller_Group</fullName>
        <description>Notify TRC - Chiller Group</description>
        <protected>false</protected>
        <recipients>
            <recipient>chad.mcdearmon@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mark.palmer@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRC/SUPPORTNewCaseassignmentnotification</template>
    </alerts>
    <alerts>
        <fullName>Notify_TRC_Controls_Public_Group_Members</fullName>
        <description>Notify TRC - Controls Public Group Members</description>
        <protected>false</protected>
        <recipients>
            <recipient>TRC_Controls</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRC/SUPPORTNewCaseassignmentnotification</template>
    </alerts>
    <alerts>
        <fullName>TRC_Cases_Past_Due</fullName>
        <description>TRC Cases Past Due</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TRC/TRC_Cases_Past_Due</template>
    </alerts>
    <alerts>
        <fullName>TRC_Cases_Past_Re_Open_Date</fullName>
        <description>TRC Cases Past Re-Open Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TRC/TRC_Cases_Past_Due</template>
    </alerts>
    <alerts>
        <fullName>TRC_Cases_ReOpen_Past_Due</fullName>
        <description>TRC Cases ReOpen Past Due</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TRC/TRC_Cases_Past_Due</template>
    </alerts>
    <alerts>
        <fullName>TRC_Controls_Case_Closed_Email_Template_Sent</fullName>
        <description>TRC Controls Case Closed - Email Template Sent</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TRC_Controls_Templates/TRC_Controls_Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>TRC_Urgent_RGM_Email</fullName>
        <description>TRC-Urgent RGM Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>TRC/TRC_Urgent_RGM</template>
    </alerts>
    <alerts>
        <fullName>TRC_Urgent_case_notification</fullName>
        <description>TRC - Urgent case notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>TRC/TRC_Urgent</template>
    </alerts>
    <alerts>
        <fullName>Warranty_AAH_Case_Approved</fullName>
        <description>Warranty AAH Case Approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>peri.kremer@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Warranty_AAH_Cases/Warranty_AAH_Case_Approved</template>
    </alerts>
    <alerts>
        <fullName>Warranty_Case_Approved</fullName>
        <description>Warranty Case Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Warranty/Warranty_Case_Approved</template>
    </alerts>
    <alerts>
        <fullName>Warranty_Case_Disputed</fullName>
        <description>Warranty Case Disputed</description>
        <protected>false</protected>
        <recipients>
            <field>PGM_RGM_Approver__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Warranty/Warranty_Case_Disputed</template>
    </alerts>
    <alerts>
        <fullName>Warranty_Case_Rejected</fullName>
        <description>Warranty Case Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Warranty/Warranty_Case_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Warranty_Chiller_Case_Approved_send_email</fullName>
        <description>Warranty - Chiller: Case Approved, send email</description>
        <protected>false</protected>
        <recipients>
            <recipient>cindi.rella@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Warranty/Warranty_Case_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Amount_Approved_0</fullName>
        <description>Sets Approved Amount to $0 when Warranty case Status = &quot;Denied: Awaiting Customer Response&quot;</description>
        <field>Amount_Approved__c</field>
        <formula>0</formula>
        <name>Amount Approved $0</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Blank</fullName>
        <description>Blank out the Approval Status</description>
        <field>Approval_Status__c</field>
        <name>Approval Status Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_CEO_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>CEO Approved</literalValue>
        <name>Approval Status CEO Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_CEO_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>CEO Rejected</literalValue>
        <name>Approval Status CEO Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_EVP_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>EVP Approved</literalValue>
        <name>Approval Status EVP Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_EVP_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>EVP Rejected</literalValue>
        <name>Approval Status EVP Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_PGM_RGM_Approved</fullName>
        <description>Updates Approval Status when to PGM/RGM Approved</description>
        <field>Approval_Status__c</field>
        <literalValue>PGM/RGM Approved</literalValue>
        <name>Approval Status PGM/RGM Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_PGM_RGM_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>PGM/RGM Rejected</literalValue>
        <name>Approval Status PGM/RGM Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Submitted_for_Approval</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Approval Status Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Warranty_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Warranty Approved</literalValue>
        <name>Approval Status Warranty Admin Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Warranty_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Warranty Rejected</literalValue>
        <name>Approval Status Warranty Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Status_Warranty_Review</fullName>
        <description>Updates the Approval Status back to Warranty Review</description>
        <field>Status</field>
        <literalValue>Warranty Review</literalValue>
        <name>Status - Warranty Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Authorized_DateUpdate</fullName>
        <description>Update the Authorized Date field with the date that the final approval happens</description>
        <field>Authorized_Date__c</field>
        <formula>NOW()</formula>
        <name>Authorized Date (now)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Acct_to_Credit_field_update</fullName>
        <description>Stamps the field for Warranty 01.023.23402.0000.0PCL.000.000.0000</description>
        <field>Acct_to_Credit__c</field>
        <formula>&quot;01.023.23402.0000.0PCL.000.000.0000&quot;</formula>
        <name>Case Acct # to Credit field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_First_Activity_Date</fullName>
        <field>First_Activity_Date__c</field>
        <formula>Today()</formula>
        <name>Case First Activity Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_First_Activity_Date_and_Time</fullName>
        <field>First_Activity_Date_and_Time__c</field>
        <formula>Now()</formula>
        <name>Case First Activity Date and Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Quality_Related_Checkbox_update</fullName>
        <description>Once the Quality description gets data in it the Quality Related checkbox is automatically set to checked (true)</description>
        <field>Quality_Related__c</field>
        <literalValue>1</literalValue>
        <name>Case Quality Related Checkbox update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_Status_to_Working</fullName>
        <description>Used to change the case status field from &quot;New&quot; to &quot;Working&quot; once the case assignment has been associated to a TRC Support Analyst.</description>
        <field>Status</field>
        <literalValue>Working</literalValue>
        <name>Change Case Status to Working</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_TRC_AAH</fullName>
        <description>Change the Case Record Type to TRC - AAH</description>
        <field>RecordTypeId</field>
        <lookupValue>TRC_AAH</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to TRC - AAH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_TRC_ATS</fullName>
        <description>Change the Case Record Type to TRC - ATS when the Case Owner (Queue) is TRC - ATS</description>
        <field>RecordTypeId</field>
        <lookupValue>TRC_ATS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to TRC - ATS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_TRC_Chillers</fullName>
        <description>Change the Case Record Type to TRC - Chillers when the Case Owner (Queue) is TRC - Chillers</description>
        <field>RecordTypeId</field>
        <lookupValue>TRC_Chillers</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to TRC - Chillers</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Record_Type_to_TRC_Controls</fullName>
        <description>Change the Case Record Type to TRC - Controls when the Case Owner (Queue) is TRC - Controls</description>
        <field>RecordTypeId</field>
        <lookupValue>TRC_Controls</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Record Type to TRC - Controls</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <name>Clear Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Case_Description_with_Web_Email</fullName>
        <field>Description</field>
        <formula>SuppliedEmail</formula>
        <name>Populate Case Description with Web Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Date_Set_to_Current_Status</fullName>
        <field>Date_Set_to_Current_Status__c</field>
        <formula>NOW()</formula>
        <name>Populate Date Set to Current Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quality_Date_update</fullName>
        <description>Quality date is updated to the date that the Quality Description had data entered into it.</description>
        <field>Quality_Related_Date__c</field>
        <formula>Today()</formula>
        <name>Quality Date update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGM_Approval_Date</fullName>
        <description>Date that the RGM Approved the claim</description>
        <field>RGM_Approved_Date__c</field>
        <formula>NOW()</formula>
        <name>RGM Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGM_Approval_Name</fullName>
        <description>Which RGM approved the claim</description>
        <field>RGM_Approval_Name__c</field>
        <formula>$User.FirstName&amp;&quot; &quot;&amp;$User.LastName</formula>
        <name>RGM Approval Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGM_Processed</fullName>
        <description>Update the Status to RGM Processed - It&apos;s been reviewed by the RGM and either approved or rejected</description>
        <field>Status</field>
        <literalValue>RGM Processed</literalValue>
        <name>RGM Processed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGM_Rejected_Date</fullName>
        <description>Date the RGM rejected</description>
        <field>RGM_Rejected_Date__c</field>
        <formula>NOW()</formula>
        <name>RGM Rejected Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RGM_Rejected_Name</fullName>
        <description>RGM that rejected the concession</description>
        <field>RGM_Rejected_Name__c</field>
        <formula>$User.FirstName&amp;&quot; &quot;&amp;$User.LastName</formula>
        <name>RGM Rejected Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Priority_Level_to_Low</fullName>
        <description>Used to set the initial case record priority to Low for Web-to-Case submissions.</description>
        <field>Priority</field>
        <literalValue>Low</literalValue>
        <name>Set Web2Case Priority Level to Low</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Warranty_Approved</fullName>
        <description>Status change to &quot;Warranty Approved&quot; when Warranty case claims are fully approved</description>
        <field>Status</field>
        <literalValue>Warranty Approved</literalValue>
        <name>Status Warranty Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Time_Re_opened_field</fullName>
        <description>Update the Date/Time Re-opened field when the case is changed from Closed to Working</description>
        <field>Date_Time_Re_Opened__c</field>
        <formula>NOW()</formula>
        <name>Update Date/Time Re-opened field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Admin_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Admin Approved</literalValue>
        <name>Warranty Admin Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Approval_Status_to_CEO</fullName>
        <description>Updates Approval Status when Warranty case claim is approved/denied by CEO</description>
        <field>Approval_Status__c</field>
        <literalValue>CEO Approved/Denied</literalValue>
        <name>Warranty Approval Status to CEO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Approval_Status_to_EVP</fullName>
        <description>Updates Approval Status when Warranty case claim is approved/denied by EVP</description>
        <field>Approval_Status__c</field>
        <literalValue>EVP Approved/Denied</literalValue>
        <name>Warranty Approval Status to EVP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Approved</fullName>
        <field>Status</field>
        <literalValue>Warranty Approved</literalValue>
        <name>Warranty Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Case_Disputed</fullName>
        <description>Notifies internal Daikin (primarily RGM) that customer has disputed Warranty Claim. Updates Status to &quot;In Dispute&quot;</description>
        <field>Status</field>
        <literalValue>In Dispute</literalValue>
        <name>Warranty Case Disputed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Status_Approval_Complete</fullName>
        <description>Status change to &quot;Warranty Approved&quot; when Warranty case claims are fully approved</description>
        <field>Status</field>
        <literalValue>Warranty Approved</literalValue>
        <name>Warranty Status Approval Complete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Status_Denied_WAR_Confirm</fullName>
        <description>Updates Case Status to &quot;Denied: Warranty Confirmation&quot; when Warranty case claim approval is rejected</description>
        <field>Status</field>
        <literalValue>Denied: Warranty Confirmation</literalValue>
        <name>Warranty Status Denied WAR Confim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Status_Rejected</fullName>
        <description>Approval was denied/rejected</description>
        <field>Status</field>
        <literalValue>Warranty Denied</literalValue>
        <name>Warranty Status Rejected/Denied</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Warranty_Status_Submitted_for_Approval</fullName>
        <description>Update Case Status to &quot;Submitted for Approval&quot; during approval process</description>
        <field>Status</field>
        <literalValue>Submitted for Approval</literalValue>
        <name>Warranty Status Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Case First Activity Date</fullName>
        <actions>
            <name>Case_First_Activity_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_First_Activity_Date_and_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Number_of_Activities__c &gt; 0 &amp;&amp; PRIORVALUE( Number_of_Activities__c ) = 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner to TRC AAH Queue</fullName>
        <actions>
            <name>Notify_TRC_AAH_Public_Group_Members</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Record_Type_to_TRC_AAH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>TRC - AAH</value>
        </criteriaItems>
        <description>TRUE when the Case Owner (Queue Name) is set to TRC - AAH</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner to TRC ATS Queue</fullName>
        <actions>
            <name>Notify_TRC_ATS_Public_Group_Members</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Record_Type_to_TRC_ATS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>TRC - ATS</value>
        </criteriaItems>
        <description>TRUE when the Case Owner (Queue Name) is set to TRC - ATS</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner to TRC Chillers Queue</fullName>
        <actions>
            <name>Notify_TRC_Chiller_Group</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Record_Type_to_TRC_Chillers</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>TRC - Chillers</value>
        </criteriaItems>
        <description>TRUE when the Case Owner (Queue Name) is set to TRC - Chillers</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner to TRC Controls Queue</fullName>
        <actions>
            <name>Notify_TRC_Controls_Public_Group_Members</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_Record_Type_to_TRC_Controls</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>TRC - Controls</value>
        </criteriaItems>
        <description>TRUE when the Case Owner (Queue Name) is set to TRC - Controls</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner-Record Type TRC-AAH</fullName>
        <actions>
            <name>Change_Record_Type_to_TRC_AAH</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TRUE when Case Owner&apos;s Profile (TRC - AAH) does not match their Record Type (TRC - AAH).</description>
        <formula>(Owner:User.Profile.Id = &quot;00eC0000001GAxD&quot;) &amp;&amp; 
(RecordTypeId &lt;&gt; &quot;012C0000000HoMR&quot; ||RecordTypeId &lt;&gt; &quot;0121A000000GVVC&quot; )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner-Record Type TRC-ATS</fullName>
        <actions>
            <name>Change_Record_Type_to_TRC_ATS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TRUE when Case Owner&apos;s Profile (TRC - ATS) does not match their Record Type (TRC - ATS).</description>
        <formula>(Owner:User.Profile.Id = &quot;00eC0000001GAxI&quot;) &amp;&amp; 
((RecordTypeId &lt;&gt; &quot;012C0000000HoMS&quot;)|| RecordTypeId &lt;&gt; &quot;0121A000000GVVC&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner-Record Type TRC-Chillers</fullName>
        <actions>
            <name>Change_Record_Type_to_TRC_Chillers</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TRUE when Case Owner&apos;s Profile (TRC - Chillers) does not match their Record Type (TRC - Chillers).</description>
        <formula>(Owner:User.Profile.Id = &quot;00eC0000001GAxN&quot;) &amp;&amp; 
(RecordTypeId &lt;&gt; &quot;012C0000000HoMT&quot; || RecordTypeId &lt;&gt; &quot;0121A000000GVVC&quot;) &amp;&amp; 
(Owner:User.Id &lt;&gt; &quot;005C0000005jgxU&quot;) &amp;&amp; 
(Owner:User.Id &lt;&gt; &quot;005C0000005jgxF&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Owner-Record Type TRC-Controls</fullName>
        <actions>
            <name>Change_Record_Type_to_TRC_Controls</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TRUE when Case Owner&apos;s Profile (TRC - Controls) does not match their Record Type (TRC - Controls).</description>
        <formula>(Owner:User.Profile.Id = &quot;00eC0000001GAxS&quot;) &amp;&amp; 
(RecordTypeId &lt;&gt; &quot;012C0000000HoMU&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Quality Related field updates</fullName>
        <actions>
            <name>Case_Quality_Related_Checkbox_update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Quality_Date_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Quality_Description__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If the Quality Description contains data the Quality Related checkbox is automatically updated to checked and the Quality Date is updated to the date it&apos;s populated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change Case Status to Working</fullName>
        <actions>
            <name>Change_Case_Status_to_Working</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notContain</operation>
            <value>TRC -,Salesforce</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notContain</operation>
            <value>Warranty</value>
        </criteriaItems>
        <description>Used to change the Case Status field from &quot;New&quot; to &quot;Working&quot; when the case ownership is changed from a Queue to an actual User.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Days of Current Status</fullName>
        <actions>
            <name>Populate_Date_Set_to_Current_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populates the Date Set to Current Status field on the Case object</description>
        <formula>OR(ISNEW(),ISCHANGED(Status))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TRC -Urgent</fullName>
        <actions>
            <name>TRC_Urgent_case_notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>TRC_Urgent_Email_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TRC - AAH,TRC - ATS,TRC - Chillers,TRC - Controls</value>
        </criteriaItems>
        <description>TRC Case is updated to Urgent. Email is sent immediately to the Case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TRC Cases 15 or 21 Days Past due</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TRC - AAH,TRC - ATS,TRC - Chillers,TRC - Controls,TRC</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Days_Open__c</field>
            <operation>equals</operation>
            <value>15</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Days_Open__c</field>
            <operation>equals</operation>
            <value>21</value>
        </criteriaItems>
        <description>TRC Cases have a ReOpened Date that is 15 or 21 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TRC_Cases_Past_Re_Open_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Date_Time_Re_Opened__c</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>TRC_Cases_Past_Re_Open_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Date_Time_Re_Opened__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TRC Cases Past Due</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TRC - AAH,TRC - ATS,TRC - Chillers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>10/1/2015</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Days_Open__c</field>
            <operation>equals</operation>
            <value>15</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Days_Open__c</field>
            <operation>equals</operation>
            <value>20</value>
        </criteriaItems>
        <description>This workflow rule will send an email to Case owner if the Case is open for more than 15 days. And also sends another notification if it is open for more than 21 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TRC_Cases_Past_Due</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>TRC_Cases_ReOpen_Past_Due</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>TRC_Cases_Past_Due</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.CreatedDate</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TRC Controls Case Closed</fullName>
        <actions>
            <name>TRC_Controls_Case_Closed_Email_Template_Sent</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>TRC_Controls_Email_Survey_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TRC - Controls</value>
        </criteriaItems>
        <description>TRC Controls Case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TRC-Urgent RGM</fullName>
        <actions>
            <name>TRC_Urgent_RGM_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>TRC_Urgent_RGM_Email_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>TRC - AAH,TRC - ATS,TRC - Chillers</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Urgent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Urgent_Reason__c</field>
            <operation>equals</operation>
            <value>RGM Called</value>
        </criteriaItems>
        <description>TRC Case has been submitted by a RGM and that is the highest priority</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Date%2FTime Re-open field</fullName>
        <actions>
            <name>Update_Date_Time_Re_opened_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Date/Time Re-open field</description>
        <formula>AND(   OR(  RecordType.Name = &apos;TRC - ATS&apos;,  RecordType.Name = &apos;TRC - AAH&apos;,  RecordType.Name = &apos;TRC&apos;,  RecordType.Name = &apos;TRC - Chillers&apos;),   ISCHANGED(Status),  TEXT(PRIORVALUE(Status)) = &quot;Closed&quot;,  TEXT(Status) = &quot;Working&quot;  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Vendor Recovery Populate Acct %23 to Credit</fullName>
        <actions>
            <name>Case_Acct_to_Credit_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Vendor_Recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If the vendor recovery checkbox is checked it should automatically update the Acct # to Credit</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Chiller_Case_Approved_email_sent</fullName>
        <assignedTo>cindi.rella@daikinapplied.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>A Chiller Warranty Case has been Approved and the email was sent to Harmony.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Chiller Case Approved - email sent</subject>
    </tasks>
    <tasks>
        <fullName>TRC_Controls_Email_Survey_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>TRC Controls Email Survey has been sent since the case was closed</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>TRC Controls Email Survey Sent</subject>
    </tasks>
    <tasks>
        <fullName>TRC_Urgent_Email_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>TRC Urgent email notification sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>TRC Urgent Email Sent</subject>
    </tasks>
    <tasks>
        <fullName>TRC_Urgent_RGM_Email_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <description>TRC Urgent RGM Email Sent</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>TRC-Urgent RGM Email Sent</subject>
    </tasks>
</Workflow>
