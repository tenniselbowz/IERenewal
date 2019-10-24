/***********************************************************************
 Author       :   Amarendar Junuthula
 Created Date :   April 04, 2016
 Description  :   Controller for  creating MABundleandTasking Records
************************************************************************/
public with sharing class GenerateMABundleTaskingController {
    /*This class creates MA-Bundle and MA-Tasking records from Proposal Line Items.
    If the ProposalLineItem.Apttus_QPConfig__LineType__c == 'Product/Service' then it will Create MA-Bundle Records
    else if the ProposalLineItem.Apttus_QPConfig__LineType__c == 'Option' then it will Create MA-Tasking Records
    */
    Private String quoteId;     //To hold the passed in Proposal Id
    private Set<String> excludedProductCodes = Pluck.strings('MasterLabel',[SELECT MasterLabel FROM Excluded_Product_Code__mdt]);
    @TestVisible private Set<String> specialProductSet 
    {
        get
        {
            if(specialProductSet == null)
            {                
                specialProductSet = MABundleTaskingUtility.specialProductSet;
            }
            return specialProductSet;
        }
        set;
    }
    //Constructor
    public GenerateMABundleTaskingController(){
        quoteId = ApexPages.currentPage().getParameters().get('Id');        //This statement captures the Id from the url
    }
    
    public pageReference generateMABundleTaskingItems(){
        if(String.isBlank(quoteId)) return null;
        if(excludedProductCodes == null|| excludedProductCodes.isEmpty()) {
            excludedProductCodes = new Set<String>{'T0313','T1000','T2000','T2100', 'T2200'};
        }
        //Delete MA Bundle records, as a result MA-Tasking records will also be deleted as the relationship between them is Master-Detail
        List<Proposal_MA_Bundle__c> MABundleitems = MABundleTaskingUtility.getMABundleItems(quoteId);
        MABundleTaskingUtility.deleteMABundleItems(MABundleItems);
        
        //Retrieve ProposalLineItems for given Quote.
        List<Apttus_Proposal__Proposal_Line_Item__c> quoteLineItems = MABundleTaskingUtility.getQuoteLineItems(quoteId);

        if(quoteLineItems != null && !quoteLineItems.isEmpty()){
            //List variables to store records
            List<Proposal_MA_Bundle__c> bundleRecords = new List<Proposal_MA_Bundle__c>();
            List<Proposal_MA_Tasking__c> taskingRecords = new List< Proposal_MA_Tasking__c>();
            List<Proposal_MA_Tasking__c> taskingRecordsTemp = new List< Proposal_MA_Tasking__c>();
            //Iterate over Proposal Line Items to find MA-bundle Records and MA- Tasking Records  --- FYI: Proposal Line Item can be a bundle or a tasking record.
            Map<String, List<Apttus_Proposal__Proposal_Line_Item__c>> productNames = Groupby.strings('Apttus_QPConfig__OptionId__r.Name', quoteLineItems);
            Map<String, List<Product_To_Category_Check__mdt>> optionGroupToProductName = GroupBy.strings('Option_Group__c',[SELECT Option_Group__c, Product_Name__c, Check_Box_Field__c FROM Product_To_Category_Check__mdt]);
            for(Apttus_Proposal__Proposal_Line_Item__c lineItem : quoteLineItems){
                if(lineItem.Apttus_QPConfig__LineType__c == 'Product/Service' 
                    || ( specialProductSet != null && specialProductSet.contains(lineItem.Apttus_Proposal__Product__r.ProductCode) )
                ){     //If the Proposal Line item Line type is Product/Service then it is a bundle record
                    Proposal_MA_Bundle__c maBundle = new Proposal_MA_Bundle__c();
                    maBundle.MA_Bundle_Name__c = lineItem.Apttus_Proposal__Product__r.Name;
                    maBundle.Quote_Proposal__c = quoteId;
                    maBundle.Manufacturer_Model_Serial__c = lineItem.Serial__c;
                    maBundle.Quantity__c = lineItem.Apttus_QPConfig__Quantity2__c;
                    maBundle.Program__c = lineItem.Program__c;
                    maBundle.MA_Bundle_Line_Number__c = lineItem.Apttus_QPConfig__LineNumber__c;
                    maBundle.MA_Bundle_Item_Sequence__c = lineItem.Apttus_QPConfig__ItemSequence__c;
                    maBundle.Description__c = string.valueof(lineItem.Capacity_Tons__c);
                    maBundle.Quantity__c = lineItem.Apttus_QPConfig__Quantity2__c;
                    maBundle.Program__c = lineItem.Program__c;
                    maBundle.Annual__c = lineItem.Annual__c;
                    maBundle.Operational__c = lineItem.Operational__c;
                    maBundle.Equipment_Group__c = lineItem.Equipment_Group__c;
                    maBundle.Emergency_Coverage_Response__c = lineItem.Apttus_QPConfig__AttributeValueId__r.Emergency_Coverage_Response__c;
                    maBundle.Site_Location__c = lineItem.Site_Location_Text__c;
                    
                    bundleRecords.add(maBundle);
                    
                } 
                //}//Here we have to check for tasking records and exclude The Annual Inspection and The operational Inspection - We're not going to insert these two records
                else if(lineItem.Apttus_QPConfig__LineType__c == 'Option' 
                && (!excludedProductCodes.contains(lineItem.Apttus_QPConfig__OptionId__r.ProductCode) || lineItem.Option_Group__c == 'Preventative Maintenance')
                && (!optionGroupToProductName.containsKey(lineItem.Option_Group__c)||
                    (optionGroupToProductName.containsKey(lineItem.Option_Group__c) && productNames.containsKey(optionGroupToProductName.get(lineItem.Option_Group__c)[0].Product_Name__c) 
                    && Pluck.decimals('Apttus_QPConfig__LineNumber__c', productNames.get(optionGroupToProductName.get(lineItem.Option_Group__c)[0].Product_Name__c)).contains(lineItem.Apttus_QPConfig__LineNumber__c)))){ //If the Proposal Line item Line type is Option then it is a tasking record
                    
                    Proposal_MA_Tasking__c maTasking = new Proposal_MA_Tasking__c();
                    maTasking.MA_Tasking_Name__c = lineItem.Apttus_QPConfig__OptionId__r.Description; //maTasking.MA_Tasking_Name__c = lineItem.Apttus_QPConfig__OptionId__r.Name;
                    maTasking.Option_Group__c = lineItem.Option_Group__c;
                    maTasking.MA_Tasking_Line_Number__c = lineItem.Apttus_QPConfig__LineNumber__c;
                    maTasking.MA_Tasking_Item_Sequence__c = lineItem.Apttus_QPConfig__ItemSequence__c;
                    maTasking.Attribute_Description__c = lineItem.APTPS_Attribute_Description__c;
                    maTasking.Of_Hours__c = lineItem.Attribute_of_Hours__c;
                    maTasking.Task_Frequency__c = lineItem.Attribute_Task_Frequency__c;
                    maTasking.Option_Code__c = lineItem.Apttus_QPConfig__OptionId__r.ProductCode;
					maTasking.MA_Tasking_French_Product_Name__c = lineItem.French_Product_Name__c;
                    taskingRecords.add(maTasking);
                    
                }  //Here we have to check for tasking records and include The Annual Inspection and The operational Inspection - We're not going to insert these records. But we just need to mark the values on related parent bundle
                else if(lineItem.Apttus_QPConfig__LineType__c == 'Option' && excludedProductCodes.contains(lineItem.Apttus_QPConfig__OptionId__r.ProductCode)){ Proposal_MA_Tasking__c maTaskingTemp = new Proposal_MA_Tasking__c();
                    maTaskingTemp.Option_Code__c = lineItem.Apttus_QPConfig__OptionId__r.ProductCode;
                    maTaskingTemp.MA_Tasking_Line_Number__c = lineItem.Apttus_QPConfig__LineNumber__c;
                    maTaskingTemp.MA_Tasking_Item_Sequence__c = lineItem.Apttus_QPConfig__ItemSequence__c;
                    maTaskingTemp.Task_Frequency__c = lineItem.Apttus_QPConfig__AttributeValueId__r.Task_Frequency__c;
                    taskingRecordsTemp.add(maTaskingTemp);
                }
                 
            }
            
            
            insert bundleRecords;
            
            
            //Now we have to relate the Tasking records to Bundle records by populating a Master-Detail Lookup field on Taskign records with the Parent Bundle Id
          
            for(Proposal_MA_Bundle__c bundle: bundleRecords){
                for(Proposal_MA_Tasking__c task: taskingRecords){
                    if(bundle.MA_Bundle_Line_Number__c == task.MA_Tasking_Line_Number__c){
                        task.Proposal_MA_Bundle__c = bundle.id;
                      
                    }
                }
                for(Proposal_MA_Tasking__c task1: taskingRecordsTemp){
                    if(bundle.MA_Bundle_Line_Number__c == task1.MA_Tasking_Line_Number__c){
                        task1.Proposal_MA_Bundle__c = bundle.id;
                        
                    }
                }
            }
            
            
            insert taskingRecords;
            
            //Now retrieve the bundle records to update the fields on it based on related tasking records -The logic is: If there is at least one task record of a Option group type then we will mark the check box as true on the parent bundle record.
            List<Proposal_MA_Bundle__c> retrieveBundles = [SELECT Id, ADDITION_S_AND_OR_EXCEPTION_S__c, Annual_Inspection__c, Annual_Inspection_Re_Certification__c, Burners_and_Combustions_Boilers__c, Coils_Services__c, Electric_type__c, Filters_and_Belts__c, 
                                                                Generic_Tasks__c, High_efficiency_purge__c, Indoor_Unit_Annual_Inspection__c, Indoor_Unit_Operation_Inspection__c, Note__c, Oil_type__c, Oil_type_boilers__c, Operational_Inspection__c, Outdoor_unit_Annual_Inspection__c, Outdoor_Unit_Operation_Inspection__c, 
                                                                PRE_COOLING_INSPECTION_Spring_Seasona__c, Predictive_Maintenance__c, PRE_HEATING_INSPECTION_Fall_Seasonal__c, Preventative_Maintenance__c, Propane_natural_gas_type__c, Propane_natural_gas_type_boilers__c, Purge_System__c, Starter_Type__c, Steam_type__c, Steam_type_boilers__c, 
                                                                The_Annual_Inspection__c, The_Operational_Inspection__c, The_Seasonal_Inspection_Spring__c, Tube_Services_Condenser_Evaporator__c, Variable_frequency_drive_s__c, Water_cooled_purge__c, Seasonal_Start_up__c, Seasonal_Shut_down__c, Annual__c, Operational__c, MA_Bundle_Name__c, The_Seasonal_Inspection_Fall__c, Perform_Seasonal_Start_up__c, 
                                                                Intelligent_Solutions_Options__c, X300_Point_Inspection__c
                                                           FROM Proposal_MA_Bundle__c 
                                                           WHERE ID in : bundleRecords];
            List<Proposal_MA_Tasking__c> tasksToDelete = new List<Proposal_MA_Tasking__c>();
            for(Proposal_MA_Bundle__c bundle1: retrieveBundles){
                for(Proposal_MA_Tasking__c c : taskingRecords){
                    if(bundle1.id == c.Proposal_MA_Bundle__c ){
                        if(c.Option_Group__c == 'ADDITION(S) AND/OR EXCEPTION(S):' && bundle1.ADDITION_S_AND_OR_EXCEPTION_S__c == FALSE){bundle1.ADDITION_S_AND_OR_EXCEPTION_S__c = TRUE;
                        } else if(c.Option_Group__c == 'Annual Inspection:' && bundle1.Annual_Inspection__c == FALSE){  bundle1.Annual_Inspection__c = true;
                        } else if(c.Option_Group__c == 'Annual Inspection & Re-Certification:' && bundle1.Annual_Inspection_Re_Certification__c == FALSE){  bundle1.Annual_Inspection_Re_Certification__c = TRUE;
                        } else if(c.Option_Group__c == 'Burners and Combustions / Boilers' && bundle1.Burners_and_Combustions_Boilers__c == FALSE){ bundle1.Burners_and_Combustions_Boilers__c = TRUE;
                        } else if(c.Option_Group__c == 'Coils Services' && bundle1.Coils_Services__c == FALSE){ bundle1.Coils_Services__c = TRUE;
                        } else if(c.Option_Group__c == 'Electric type *' && bundle1.Electric_type__c == FALSE){ bundle1.Electric_type__c = TRUE;
                        } else if(c.Option_Group__c == 'Filters and Bselts' && bundle1.Filters_and_Belts__c == FALSE){   bundle1.Filters_and_Belts__c = TRUE;
                        } else if(c.Option_Group__c == 'Generic Tasks' && bundle1.Generic_Tasks__c == FALSE){   bundle1.Generic_Tasks__c = TRUE;
                        } else if(c.Option_Group__c == 'High efficiency purge *' && bundle1.High_efficiency_purge__c == FALSE){ bundle1.High_efficiency_purge__c = TRUE;
                        } else if(c.Option_Group__c == 'Indoor Unit - Annual Inspection' && bundle1.Indoor_Unit_Annual_Inspection__c == FALSE){ bundle1.Indoor_Unit_Annual_Inspection__c = TRUE;
                        } else if(c.Option_Group__c == 'Indoor Unit - Operation Inspection' && bundle1.Indoor_Unit_Operation_Inspection__c == FALSE){   bundle1.Indoor_Unit_Operation_Inspection__c = TRUE;
                        } else if(c.Option_Group__c == 'Note' && bundle1.Note__c == FALSE){ bundle1.Note__c = TRUE;
                        } else if(c.Option_Group__c == 'Oil type *' && bundle1.Oil_type__c == FALSE){   bundle1.Oil_type__c = TRUE;
                        } else if(c.Option_Group__c == 'Oil type boilers *' && bundle1.Oil_type_boilers__c == FALSE){   bundle1.Oil_type_boilers__c = TRUE;
                        } else if(c.Option_Group__c == 'Operational Inspection:' && bundle1.Operational_Inspection__c == FALSE){    bundle1.Operational_Inspection__c = TRUE;
                        } else if(c.Option_Group__c == 'Outdoor unit - Annual Inspection' && bundle1.Outdoor_unit_Annual_Inspection__c == FALSE){   bundle1.Outdoor_unit_Annual_Inspection__c = TRUE;
                        } else if(c.Option_Group__c == 'Outdoor_Unit_Operation_Inspection__c' && bundle1.Outdoor_Unit_Operation_Inspection__c == FALSE){    bundle1.Annual_Inspection_Re_Certification__c = TRUE;
                        } else if(c.Option_Group__c == 'PRE-COOLING INSPECTION (Spring)- Seasona' && bundle1.PRE_COOLING_INSPECTION_Spring_Seasona__c == FALSE){    bundle1.Annual_Inspection_Re_Certification__c = TRUE;
                        } else if(c.Option_Group__c == 'Predictive Maintenance' && bundle1.Predictive_Maintenance__c == FALSE){ bundle1.Predictive_Maintenance__c = TRUE;
                        } else if(c.Option_Group__c == 'PRE-HEATING INSPECTION (Fall)- Seasonal' && bundle1.PRE_HEATING_INSPECTION_Fall_Seasonal__c == FALSE){  bundle1.PRE_HEATING_INSPECTION_Fall_Seasonal__c = TRUE;
                        } else if(c.Option_Group__c == 'Preventative Maintenance' && bundle1.Preventative_Maintenance__c == FALSE){ bundle1.Preventative_Maintenance__c = TRUE;
                        } else if(c.Option_Group__c == 'Propane & natural gas type *' && bundle1.Propane_natural_gas_type__c == FALSE){ bundle1.Propane_natural_gas_type__c = TRUE;
                        } else if(c.Option_Group__c == 'Propane & natural gas type boilers *' && bundle1.Propane_natural_gas_type_boilers__c == FALSE){ bundle1.Propane_natural_gas_type_boilers__c = TRUE;
                        } else if(c.Option_Group__c == 'Purge System*' && bundle1.Purge_System__c == FALSE){    bundle1.Purge_System__c = TRUE;
                        } else if(c.Option_Group__c == 'Starter Type*' && bundle1.Starter_Type__c == FALSE){    bundle1.Starter_Type__c = TRUE;
                        } else if(c.Option_Group__c == 'Steam type *' && bundle1.Steam_type__c == FALSE){   bundle1.Steam_type__c = TRUE;
                        } else if(c.Option_Group__c == 'Steam type boilers *' && bundle1.Steam_type_boilers__c == FALSE){   bundle1.Steam_type_boilers__c = TRUE;
                        } else if(c.Option_Group__c == 'Tube Services - (Condenser/Evaporator)' && bundle1.Tube_Services_Condenser_Evaporator__c == FALSE){ bundle1.Tube_Services_Condenser_Evaporator__c = TRUE;
                        } else if(c.Option_Group__c == 'Variable frequency drive(s) *' && bundle1.Variable_frequency_drive_s__c == FALSE){  bundle1.Variable_frequency_drive_s__c = TRUE;
                        } else if(c.Option_Group__c == 'Water cooled purge *' && bundle1.Water_cooled_purge__c == FALSE){   bundle1.Water_cooled_purge__c = TRUE;
                        } else if((c.Option_Group__c == 'Seasonal Start-up') && bundle1.Perform_Seasonal_Start_up__c == FALSE){   bundle1.Perform_Seasonal_Start_up__c = TRUE;
                        } else if(c.Option_Group__c == 'PRE-COOLING INSPECTION (Spring)- Seasonal Inspection' && bundle1.PRE_COOLING_INSPECTION_Spring_Seasona__c == FALSE){   bundle1.PRE_COOLING_INSPECTION_Spring_Seasona__c = TRUE;
                        } else if(c.Option_Group__c == 'PRE-HEATING INSPECTION (Fall)- Seasonal Inspection' && bundle1.PRE_HEATING_INSPECTION_Fall_Seasonal__c == FALSE){   bundle1.PRE_HEATING_INSPECTION_Fall_Seasonal__c = TRUE;
                        }else if(c.Option_Group__c == 'Intelligent Solution Options' && bundle1.Intelligent_Solutions_Options__c == FALSE){   bundle1.Intelligent_Solutions_Options__c = TRUE;
                        }else if(c.Option_Group__c == '300 point Inspection' && bundle1.X300_Point_Inspection__c == FALSE){   bundle1.X300_Point_Inspection__c = TRUE;
                        }

                        if(c.Option_Group__c == 'Preventative Maintenance' && c.MA_Tasking_Name__c == 'Perform Seasonal Start-up.') {
                            bundle1.Perform_Seasonal_Start_up__c = true;
                        }
                        
                        // Set the Seasonal flags
                        if (c.MA_Tasking_Name__c == 'Perform Seasonal Start-up.' && bundle1.Seasonal_Start_up__c != 1) {
                            bundle1.Seasonal_Start_up__c = 1;
                        }
                        if (c.MA_Tasking_Name__c == 'Perform Seasonal Shut-down.' && bundle1.Seasonal_Shut_down__c != 1) {
                            bundle1.Seasonal_Shut_down__c = 1;
                        }

                        if(c.Option_Code__c == 'T1000' && c.of_Hours__c != 0){
                            bundle1.Annual__c = c.Task_Frequency__c;
                        } else if(c.Option_Code__c == 'T2000' && c.of_Hours__c != 0){
                            bundle1.Operational__c = c.Task_Frequency__c;
                        }
                    } 

                }
            }
            try {
                update retrieveBundles;
            }
            catch(DmlException dmlE) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlE.getMessage()));
                return null;
            }
        }
        
        
        //redirect to the generate document page
        PageReference generateQuotePage = Page.Apttus_Proposal__ProposalGenerate;
        generateQuotePage.getParameters().put('Id', quoteId);
        generateQuotePage.setRedirect(true);
        return generateQuotePage;
    }
}