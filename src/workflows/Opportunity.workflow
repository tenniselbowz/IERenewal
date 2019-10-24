<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Basis_of_Design_Email_Notification</fullName>
        <description>Basis of Design Email Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mark.lockwood@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/Basis_of_Design</template>
    </alerts>
    <alerts>
        <fullName>Cups_Email_Notification_to_DM_ROSM</fullName>
        <description>Cups Email Notification to DM/ROSM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>DM_District_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>ROSM_Regional_Owner_Sales_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CUPS_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>FS_Closed_Won</fullName>
        <description>FS Closed Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>richard.grenz@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ron.schneider@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTCaseescalationnotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>High_Value_Opp_has_been_entered</fullName>
        <description>High Value Opp has been entered</description>
        <protected>false</protected>
        <recipients>
            <recipient>richard.grenz@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ron.schneider@daikinapplied.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTSelfServiceNewCommentNotificationSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>LATAM_Market_Fund_CO_OP_Email_Notification</fullName>
        <description>LATAM Market Fund CO-OP Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LATAM_Market_Fund_CO_OP_Email_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_Colombia</fullName>
        <description>LA Opp Won Logistics Notification - Colombia</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_Colombia</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_DALA</fullName>
        <description>LA Opp Won Logistics Notification - DALA</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_DALA</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_Mexico</fullName>
        <description>LA Opp Won Logistics Notification - Mexico</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_Mexico</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_Peru</fullName>
        <description>LA Opp Won Logistics Notification - Peru</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_Peru</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_Puerto_Rico</fullName>
        <description>LA Opp Won Logistics Notification - Puerto Rico</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_Puerto_Rico</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Opp_Won_Logistics_Notification_South_Cone</fullName>
        <description>LA Opp Won Logistics Notification - South Cone</description>
        <protected>false</protected>
        <recipients>
            <recipient>LA_Logistics_Staff_South_Cone</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Latin_America_Templates/LA_Opp_Won_Logistics_Notification</template>
    </alerts>
    <alerts>
        <fullName>LA_Provide_VRV_Daikin_Product_Notification_Mexico</fullName>
        <description>LA_Provide VRV/Daikin Product Notification - Mexico</description>
        <protected>false</protected>
        <recipients>
            <recipient>benjamin.galvez@daikin.com.mx.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Provide_Product_Notification</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Credit_Release_Notification</fullName>
        <description>Latin America Credit Release Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Credit_Release_Notification</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Email_Alert_notifies_User_Shigetomo_Komatsu_when_an_Opportunity_wi</fullName>
        <description>Latin America Email Alert notifies User: Shigetomo Komatsu when an Opportunity with VRV/Daikin Opportunity product line items created.</description>
        <protected>false</protected>
        <recipients>
            <recipient>andres.zamora@daikinapplied.com.na</recipient>
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
        <template>unfiled$public/Latin_America_Provide_Product_Notification</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_14_Days_after_Close_Date</fullName>
        <description>Latin America Opportunity 14 Days after Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_14_Days_before_Close_Date</fullName>
        <description>Latin America Opportunity 14 Days before Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_1_Day_after_Close_Date</fullName>
        <description>Latin America Opportunity 1 Day after Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_1_Day_before_Close_Date</fullName>
        <description>Latin America Opportunity 1 Day before Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_7_Days_after_Close_Date</fullName>
        <description>Latin America Opportunity 7 Days after Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_7_Days_before_Close_Date</fullName>
        <description>Latin America Opportunity 7 Days before Close Date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_Close_date_is_in_the_past</fullName>
        <description>Latin America Opportunity Close date is in the past</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Workflow_Send_email_reminder_to_user_with_Open_Opportunity_Close_Date_before_cur</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_Close_date_is_in_the_past_Notify_User</fullName>
        <description>Latin America Opportunity Close date is in the past</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Workflow_Send_email_reminder_to_user_with_Open_Opportunity_Close_Date_before_cur</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_Close_date_is_today</fullName>
        <description>Latin America Opportunity Close date is today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Opportunity_Notify_Owner_before_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_Credit_status_changed_notification</fullName>
        <description>Latin America Opportunity Credit status changed notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Open_Opportunity_Response_From_Customer_With_Credit_Response</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_still_Open_14_days_after_credit_decision</fullName>
        <description>Latin America Opportunity still Open 14 days after credit decision</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Open_Opportunity_Response_From_Customer_With_Credit_Response</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_still_Open_21_days_after_credit_decision</fullName>
        <description>Latin America Opportunity still Open 21 days after credit decision</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Open_Opportunity_Response_From_Customer_With_Credit_Response</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Opportunity_still_Open_7_days_after_credit_decision</fullName>
        <description>Latin America Opportunity still Open 7 days after credit decision</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Open_Opportunity_Response_From_Customer_With_Credit_Response</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Service_Contract_Notification_DALA</fullName>
        <description>Latin America Service Contract Notification - DALA</description>
        <protected>false</protected>
        <recipients>
            <recipient>astrid.marin@daikinapplied.com.na</recipient>
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
        <fullName>Latin_America_Service_Contract_Notification_Mexico</fullName>
        <description>Latin America Service Contract Notification - Mexico</description>
        <protected>false</protected>
        <recipients>
            <recipient>christian.romeroll@daikin.com.mx.na</recipient>
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
        <fullName>Latin_America_Service_Contract_Notification_Peru</fullName>
        <description>Latin America Service Contract Notification - Peru</description>
        <protected>false</protected>
        <recipients>
            <recipient>rene.villa@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rolando.mendoza@daikinapplied.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Service_Contract_Notification</template>
    </alerts>
    <alerts>
        <fullName>Latin_America_Service_Contract_Notification_Puerto_Rico</fullName>
        <description>Latin America Service Contract Notification - Puerto Rico</description>
        <protected>false</protected>
        <recipients>
            <recipient>jdoleo@mcquaycaribe.com.na</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lcolon@mcquaycaribe.com.na</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Service_Contract_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Tech_of_Closed_Won</fullName>
        <description>Notify Tech of Closed Won</description>
        <protected>false</protected>
        <recipients>
            <field>Tech__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Technician_Tip_Templates/Notify_Tech_Opportunity_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Notify_Tech_of_Tech_Tip_Converted</fullName>
        <description>Notify Tech of Tech Tip Converted</description>
        <protected>false</protected>
        <recipients>
            <field>Tech__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Technician_Tip_Templates/Notify_Tech_Lead_Converted</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_is_Closed_Won_and_Quote_is_5k</fullName>
        <description>Opportunity is Closed Won and Quote is &lt;5k</description>
        <protected>false</protected>
        <recipients>
            <field>Service_Coordinator_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcehelp@daikinapplied.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Quote_is_5k_and_Opp_is_closed_won</template>
    </alerts>
    <alerts>
        <fullName>Solutions_oppotunity_has_a_scheduled_close_date_of_30_days_from_today</fullName>
        <ccEmails>Ann.Slavec@mcquay.com</ccEmails>
        <description>Solutions oppotunity has a scheduled close date of 30 days from today</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Solutions_Opportunity_Close_Date</template>
    </alerts>
    <alerts>
        <fullName>Who_to_Contact_auto_email_to_owner_of_opportunity_once_Opportunity_is_Won</fullName>
        <ccEmails>Rene.Villa@daikinapplied.com</ccEmails>
        <description>Who to Contact auto-email to owner of opportunity once Opportunity is Won</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/Who_to_Contact_auto_email_to_owner_of_opportunity_once_Opportunity_is_Won</template>
    </alerts>
    <alerts>
        <fullName>immidiate_action</fullName>
        <description>immidiate action</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Latin_America_Open_Opportunity_Response_From_Customer_With_Credit_Response</template>
    </alerts>
    <fieldUpdates>
        <fullName>LA_Opp_Stage_Update_Lead_Conversion</fullName>
        <description>This Field Update Updates Stage value to Target/Lead Specification after a Lead is converted.</description>
        <field>StageName</field>
        <literalValue>E-Project on Hold-Booking beyond 120days</literalValue>
        <name>LA Opp Stage Update-Lead Conversion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>MAPS_Reporting_LOB_Population</fullName>
        <description>Populates MAPS Reporting LOB based on Line of Business field.</description>
        <field>MAPS_Reporting_LOB__c</field>
        <formula>IF (ISPICKVAL(Line_of_Business__c,&quot;MA - Maintenance Agreement&quot;),&quot;MA - New&quot;,
IF (ISPICKVAL(Line_of_Business__c,&quot;MA - Renewal&quot;),&quot;MA - Renewal&quot;,
IF (ISPICKVAL(Line_of_Business__c,&quot;Service &amp; Repair - Quoted&quot;), &quot;SR - Quoted&quot;, 
IF (ISPICKVAL(Line_of_Business__c,&quot;Service &amp; Repair - T&amp;M&quot;), &quot;SR - T&amp;M&quot;, 
IF (ISPICKVAL(Line_of_Business__c,&quot;TK - Turnkey Contracting&quot;), &quot;TK&quot;,
IF (ISPICKVAL(Line_of_Business__c,&quot;CTK - Complex Turnkey&quot;), &quot;TK&quot;,
IF (ISPICKVAL(Line_of_Business__c,&quot;Equipment Only&quot;), &quot;Equipment Only&quot;,
IF (ISPICKVAL(Line_of_Business__c,&quot;Rental Chillers&quot;), &quot;Rental Chillers&quot;, 
IF (ISPICKVAL(Line_of_Business__c,&quot;MCP&quot;), &quot;MCP&quot;,&quot;Other&quot;)))))))))</formula>
        <name>MAPS Reporting LOB Population</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NA_Opp_Stage_Update_Lead_Conversion</fullName>
        <description>This Field Update Updates Stage value to Target/Lead Specification after a Lead is converted.</description>
        <field>StageName</field>
        <literalValue>Target/Lead Verification</literalValue>
        <name>NA Opp Stage Update-Lead Conversion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rollback_CreditApproval_if_Amount_change</fullName>
        <field>Credit_Approval_Status__c</field>
        <literalValue>Hold</literalValue>
        <name>Rollback CreditApproval if Amount change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Subregion</fullName>
        <field>SubRegion__c</field>
        <formula>CASE( Opportunity_Country__c, 
&quot;Colombia&quot;, &quot;Andean Pact&quot;, 
&quot;Ecuador&quot;, &quot;Andean Pact&quot;, 
&quot;Venezuela&quot;, &quot;Andean Pact&quot;,
 
&quot;Peru&quot;, &quot;Andean Pact Sales&quot;, 

&quot;Anguilla&quot;, &quot;Caribbean&quot;, 
&quot;Antigua and Barbuda&quot;, &quot;Caribbean&quot;, 
&quot;Aruba&quot;, &quot;Caribbean&quot;, 
&quot;Bahamas, The&quot;, &quot;Caribbean&quot;, 
&quot;Barbados&quot;, &quot;Caribbean&quot;, 
&quot;Belize_BLZ&quot;, &quot;Caribbean&quot;, 
&quot;Bermuda Islands&quot;, &quot;Caribbean&quot;, 
&quot;Bonaire&quot;, &quot;Caribbean&quot;, 
&quot;Cayman Islands&quot;, &quot;Caribbean&quot;, 
&quot;Cuba&quot;, &quot;Caribbean&quot;, 
&quot;Curacao&quot;, &quot;Caribbean&quot;, 
&quot;Dominica&quot;, &quot;Caribbean&quot;, 
&quot;Dominican Republic&quot;, &quot;Caribbean&quot;, 
&quot;Grenada&quot;, &quot;Caribbean&quot;, 
&quot;Guyana&quot;, &quot;Caribbean&quot;, 
&quot;Haiti&quot;, &quot;Caribbean&quot;, 
&quot;Jamaica&quot;, &quot;Caribbean&quot;, 
&quot;Saint Kitts and Nevis&quot;, &quot;Caribbean&quot;, 
&quot;Saint Lucia&quot;, &quot;Caribbean&quot;, 
&quot;Saint Martin&quot;, &quot;Caribbean&quot;, 
&quot;Saint Vincent and The Grenadines&quot;, &quot;Caribbean&quot;, 
&quot;St Croix&quot;, &quot;Caribbean&quot;, 
&quot;St John&quot;, &quot;Caribbean&quot;, 
&quot;St Thomas&quot;, &quot;Caribbean&quot;, 
&quot;Suriname&quot;, &quot;Caribbean&quot;, 
&quot;Tortola&quot;, &quot;Caribbean&quot;, 
&quot;Turks and Caicos Islands&quot;, &quot;Caribbean&quot;, 
&quot;Virgin Gorda&quot;, &quot;Caribbean&quot;, 
&quot;Virgin Islands&quot; , &quot;Caribbean&quot;,

&quot;Costa Rica&quot;, &quot;Central America&quot;, 
&quot;El Salvador&quot;, &quot;Central America&quot;, 
&quot;Guatemala&quot;, &quot;Central America&quot;, 
&quot;Honduras&quot;, &quot;Central America&quot;, 
&quot;Nicaragua&quot;, &quot;Central America&quot;, 
&quot;Panama&quot;, &quot;Central America&quot;,

&quot;Brazil&quot;, &quot;Miami Core&quot;,
&quot;Mexico&quot;, &quot;Miami Core&quot;,
&quot;Spain-ESP&quot;, &quot;Miami Core&quot;, 
&quot;USA-USA&quot;, &quot;Miami Core&quot;, 
&quot;Other&quot;, &quot;Miami Core&quot;,

&quot;Chile&quot;, &quot;South Cone&quot;,

&quot;Argentina&quot;, &quot;Miami Core - South Cone&quot;,
&quot;Italy-ITA&quot;, &quot;Miami Core - South Cone&quot;,
&quot;Bolivia&quot;, &quot;Miami Core - South Cone&quot;,
&quot;Paraguay&quot;, &quot;Miami Core - South Cone&quot;,
&quot;Uruguay&quot;, &quot;Miami Core - South Cone&quot;,

&quot;Puerto Rico&quot;, &quot;Miami Core - Caribbean Sales - Puerto Rico Sales&quot;,
&quot;St Marteen&quot;, &quot;Miami Core - Caribbean Sales - Puerto Rico Sales&quot;,
&quot;Trinidad and Tobago&quot;, &quot;Miami Core - Caribbean Sales - Puerto Rico Sales&quot;,
&quot;US-Puerto Rico&quot;, &quot;Miami Core - Caribbean Sales - Puerto Rico Sales&quot;,

&quot;none&quot;)</formula>
        <name>Subregion</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date_On_Won_Opportunities</fullName>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Update Close Date On Won Opportunities</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Credit_Approval_To_Release</fullName>
        <field>Credit_Approval_Status__c</field>
        <literalValue>Release</literalValue>
        <name>Update Credit Approval To Release</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Gross_Margin_Approval_Status</fullName>
        <field>GM_Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Gross Margin Approval Status - Ap</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Gross_Margin_Approval_Status_NA</fullName>
        <field>GM_Approval_Status__c</field>
        <literalValue>Needs Approval</literalValue>
        <name>Update Gross Margin Approval Status - NA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Latin_America_Opportunity_Number</fullName>
        <description>Updates the Latin America Opportunity Number opportunity field.</description>
        <field>Latin_America_Opportunity_Number__c</field>
        <formula>IF( (RecordType.Name = &quot;North America&quot; || RecordType.Name = &quot;North America - DSO&quot; || RecordType.Name = &quot;North America Apttus&quot;), 


IF( BEGINS( Owner.Profile.Name , &quot;MCP&quot;), &quot;PHX-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;), 

IF( BEGINS( Owner.Profile.Name , &quot;Direct&quot;), MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;) ,LPAD(Auto_Number__c,7,&quot;0&quot;))),


IF(TEXT( Region_Territory__c ) = &quot;Colombia&quot;, &quot;CO-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;) , 

IF(TEXT( Region_Territory__c ) = &quot;DALA&quot;, &quot;MC-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;) , 

IF(TEXT( Region_Territory__c )= &quot;Mexico&quot;, &quot;MX-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;), 

IF(TEXT( Region_Territory__c ) = &quot;Peru&quot;, &quot;PE-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;) , 

IF(TEXT( Region_Territory__c )= &quot;Puerto Rico&quot;, &quot;PR-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;), 

IF(TEXT( Region_Territory__c )= &quot;South Cone&quot;, &quot;SC-&quot;&amp; MID(TEXT(CreatedDate), 3, 2) &amp; MID(TEXT(CreatedDate), 6, 2) &amp;&quot;-&quot;&amp; LPAD(Auto_Number__c,7,&quot;0&quot;), &quot;&quot;)))))))</formula>
        <name>Update Latin America Opportunity Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Basis of Design Email Notification</fullName>
        <actions>
            <name>Basis_of_Design_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America Apttus,Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Basis_of_Design_BOD__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Entity__c</field>
            <operation>notEqual</operation>
            <value>Mexico</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA Opportunity Stage Update upon Lead Conversion</fullName>
        <actions>
            <name>LA_Opp_Stage_Update_Lead_Conversion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Converted_from_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Owner_Division__c</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <description>LA Opportunity Stage Update upon Lead Conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LATAM Market Fund CO-OP Email Notification</fullName>
        <actions>
            <name>LATAM_Market_Fund_CO_OP_Email_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.Market_Fund_CO_OP__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Latin America Market Fund CO-OP Email Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA_Provide VRV%2FDaikin Product Email Notification -Mexico</fullName>
        <actions>
            <name>LA_Provide_VRV_Daikin_Product_Notification_Mexico</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 )</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Provide_Product_Notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <description>This Workflow notifies User: Shigetomo Komatsu when an Opportunity with VRV/Daikin Opportunity product line items created. It uses the field Provide Product Notification on the Opportunity to know if VRV/Daikin product is created or not.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LA_Provide VRV%2FDaikin Product Email Notification w%2Fo Mexico</fullName>
        <actions>
            <name>Latin_America_Email_Alert_notifies_User_Shigetomo_Komatsu_when_an_Opportunity_wi</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND (NOT(3 OR 4 ))</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Provide_Product_Notification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Country__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <description>This Workflow notifies User: Shigetomo Komatsu when an Opportunity with VRV/Daikin Opportunity product line items created. It uses the field Provide Product Notification on the Opportunity to know if VRV/Daikin product is created or not.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Credit Approval Release</fullName>
        <actions>
            <name>Update_Credit_Approval_To_Release</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR (3 AND 4))</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America,Latin America Apttus</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Latin America Unitary Sales User</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Latin America Service User,Latin America Apttus Service User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Line_of_Business__c</field>
            <operation>notEqual</operation>
            <value>Retrofit/Upgrades,TK - Turnkey Contracting,CTK - Complex Turnkey,Equipment Only</value>
        </criteriaItems>
        <description>Updates Credit Approval status to release.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Credit Release Notification</fullName>
        <actions>
            <name>Latin_America_Credit_Release_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>,Latin America,Latin America Apttus</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Credit_Approval_Status__c</field>
            <operation>equals</operation>
            <value>Release</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type</field>
            <operation>notEqual</operation>
            <value>Over-Counter Unitary</value>
        </criteriaItems>
        <description>Latin America Credit Release Notification</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Open Opportunity - No Synced Quote</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Lost,&quot;Order-Won-Crdt Release, Submittal signed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Synced_To_Quote__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Latin America Notify user before and after close date if the opportunity is still open and having no synced quotes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Latin_America_Opportunity_7_Days_before_Close_Date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Latin_America_Opportunity_Close_date_is_today</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>9</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Latin America Open Opportunity-  Response From Customer With Credit Response</fullName>
        <active>false</active>
        <booleanFilter>1 AND (2 OR (3 AND 4)) AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Quote_Status__c</field>
            <operation>equals</operation>
            <value>Rejected by Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Quote_Status__c</field>
            <operation>equals</operation>
            <value>Accepted by Customer</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Credit_Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Lost,&quot;Order-Won-Crdt Release, Submittal signed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Quote.IsSyncing</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This workflow notifies User if an Opportunity is still open after the Opportunity Quote Status is rejected or Accepted with a credit decision</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Latin_America_Opportunity_still_Open_7_days_after_credit_decision</name>
                <type>Alert</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Latin_America_Opportunity_still_Open_14_days_after_credit_decision</name>
                <type>Alert</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Latin_America_Opportunity_still_Open_21_days_after_credit_decision</name>
                <type>Alert</type>
            </actions>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - Colombia</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Colombia</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - DALA</fullName>
        <actions>
            <name>Latin_America_Service_Contract_Notification_DALA</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>DALA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - Mexico</fullName>
        <actions>
            <name>Latin_America_Service_Contract_Notification_Mexico</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Mexico</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - Peru</fullName>
        <actions>
            <name>Latin_America_Service_Contract_Notification_Peru</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Peru</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - Puerto Rico</fullName>
        <actions>
            <name>Latin_America_Service_Contract_Notification_Puerto_Rico</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>Puerto Rico</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Service Contract Notification - South Cone</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Service_Item_Included__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>equals</operation>
            <value>South Cone</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Latin America Sub-Region field update</fullName>
        <actions>
            <name>Subregion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This Rule Updates the Text field Sub region on the Opportunity object when an Opportunity created and every time its edited. Sub region is used to share Opportunities with sub region managers</description>
        <formula>RecordTypeId =&quot;012C0000000HnEo&quot; &amp;&amp; (ISCHANGED( Opportunity_Country__c ) ||  ISNEW() )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MAPS Reporting LOB</fullName>
        <actions>
            <name>MAPS_Reporting_LOB_Population</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NA Opportunity Stage Update upon Lead Conversion</fullName>
        <actions>
            <name>NA_Opp_Stage_Update_Lead_Conversion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Converted_from_Lead__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Opportunity_Owner_Division__c</field>
            <operation>notEqual</operation>
            <value>Latin America</value>
        </criteriaItems>
        <description>NA Opportunity Stage Update upon Lead Conversion</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Rollback Credit Release if the Selling price changes</fullName>
        <actions>
            <name>Rollback_CreditApproval_if_Amount_change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rollback Credit Release if the Selling price changes</description>
        <formula>ISPICKVAL( Credit_Approval_Status__c , &quot;Release&quot;) &amp;&amp; (ISCHANGED( Amount ) || ISCHANGED( GM_Percentage__c )) &amp;&amp;  ( ($Profile.Name != &quot;Latin America Unitary Sales User&quot;)&amp;&amp; ($Profile.Name != &quot;Latin America Service User&quot;) &amp;&amp; ($Profile.Name != &quot;Latin America Apttus Service User&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Solutions Opportunity Close Date in 30 days</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Solutions Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Closed Lost,Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>Notify Opportunity owner that the solutions opportunity is scheduled to be closed in 30 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Solutions_oppotunity_has_a_scheduled_close_date_of_30_days_from_today</name>
                <type>Alert</type>
            </actions>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Solutions Opportunity Closed Won 100%25</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Solutions Opportunity</value>
        </criteriaItems>
        <description>A Solution Opportunity has been Closed Won, notify the assigned Project Manager.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Close Date On Won Opportunities</fullName>
        <actions>
            <name>Update_Close_Date_On_Won_Opportunities</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets Close Date to today&apos;s date when opportunities get marked as won.</description>
        <formula>ISPICKVAL(StageName,&quot;Order-Won-Crdt Release, Submittal signed&quot;) || ISPICKVAL(StageName,&quot;Closed Won&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Gross Margin Approval Pocess - Needs Approval</fullName>
        <actions>
            <name>Update_Gross_Margin_Approval_Status_NA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Margin_Percent__c</field>
            <operation>lessThan</operation>
            <value>15</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.GM_Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Under Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.GM_Approval_Status__c</field>
            <operation>notEqual</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Gross Margin Approval Status - Approved</fullName>
        <actions>
            <name>Update_Gross_Margin_Approval_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Latin America</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Total_Margin_Percent__c</field>
            <operation>greaterOrEqual</operation>
            <value>15</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Latin America Proposal Number</fullName>
        <actions>
            <name>Update_Latin_America_Opportunity_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the Latin America proposal number.</description>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Who to Contact auto-email to owner of opportunity once Opportunity is Won</fullName>
        <actions>
            <name>Who_to_Contact_auto_email_to_owner_of_opportunity_once_Opportunity_is_Won</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>&quot;Order-Won-Crdt Release, Submittal signed&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Region_Territory__c</field>
            <operation>notEqual</operation>
            <value>Mexico</value>
        </criteriaItems>
        <description>Who to Contact auto-email to owner of opportunity once Opportunity is Won</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>update</fullName>
        <active>false</active>
        <formula>ISCHANGED( Amount_Report__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
