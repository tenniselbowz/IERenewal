/* 
    Class : APTPS_DaikinPricingCallback
    Description : This class will contain pricing utilities which calculate line item pricing fields accordingly.
                Class must be included in Config Custom Class setting record as Call back class.
    Author : Parth Sevak , @Apttus
    
    PS: 
    @ModifiedBy  : Hardik Shah
    @ChangeDescription : 1) ReCacluate Cost (custom field) 
               Formula : Cost = Base Price * Total Number of Hours (Apttus_Config2__LineItemRollup__c.Total_of_Hours__c)
                         + Coverage Class Cost (Apttus_Config2__ProductAttributeValue__c.Coverage_Class_Cost__c).
               2) Apply above formula to all products that have  APTS_Is_Daikin_Pricing_Applicable__c set to True
******************************************************************/


global with sharing class APTPS_DaikinPricingCallback implements Apttus_Config2.CustomClass.IPricingCallback3 {

 private Apttus_Config2.ProductConfiguration cart = null;
 private Apttus_Config2.CustomClass.PricingMode systemMode = null;
 private Map < Id, List < Apttus_Config2__LineItem__c >> mapBundleOptions = new Map < Id, List < Apttus_Config2__LineItem__c >> ();
 private List < Apttus_Config2__LineItem__c > ListCartOptionLI = new List < Apttus_Config2__LineItem__c > ();

 //private string ProductConfigId; //by AJ
 private Boolean isDaikinPricingApplicable(Apttus_Config2__LineItem__c lineItem) {
  Boolean returnValue = false;
  if (lineItem.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE) {
   returnValue = lineItem.Apttus_Config2__ProductId__r.APTS_Daikin_Pricing__c;
  } else {
   returnValue = lineItem.Apttus_Config2__OptionId__r.APTS_Daikin_Pricing__c;
  }
  return returnValue;
 }

 private Boolean applyOptionPrice(Apttus_Config2__LineItem__c lineItem) {
    return lineItem.Apttus_Config2__ProductId__r.APTS_ApplyOptionPrice__c;
 }

 global void start(Apttus_Config2.ProductConfiguration cart) {
   this.cart = cart;
   //Added by Apttus Support || Case : 00213991 || Date : 01-08-2017 || Desc : Option line item were not getting while setting LargeCartThreshold in Config System Properties custom setting
   ListCartOptionLI = [SELECT Id, Apttus_Config2__LineType__c, APTPS_Cost__c, Base_Ext_Price__c, Apttus_Config2__Quantity__c, Apttus_Config2__PrimaryLineNumber__c, Total_of_Hours__c, Apttus_Config2__LineNumber__c, Apttus_Config2__ProductId__c FROM Apttus_Config2__LineItem__c WHERE Apttus_Config2__ConfigurationId__c = : cart.getConfigSO().Id AND Apttus_Config2__LineType__c = 'Option'];


  } // End of Start

 global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
  //this.mode = mode;
  systemMode = mode;
 }

 /*
     Callback before pricing the line item collection
     Use this method to do all required pre-processing to prepare the line items for pricing.
     @param itemColl the line item collection to pre-process
 */

 global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {

  if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT != systemMode && !test.isRunningTest()) {
   return;
  }

  Boolean bIsSpecialBundle = false;

  // Added By Hardik Shah - To RollUp NumberOfhours from option-product to bundle level
  List < Apttus_Config2__LineItem__c > listBundleLineItem = new List < Apttus_Config2__LineItem__c > ();
  List < Apttus_Config2__LineItem__c > listOptionLineItem = new List < Apttus_Config2__LineItem__c > ();
  Map < Id, Decimal > mapIdToTotalHours = new Map < Id, Decimal > ();

  Decimal OptionTotalHours = 0.0;

  Integer WRCStartIndex = 0;
  Integer totalIndex = 0;
  for (Apttus_Config2.LineItem lineItem: itemColl.getAllLineItems()) {
   Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();
   if (item != null) {

    if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_OPTION) {
     listOptionLineItem.add(item);
    } else if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE) {

     listBundleLineItem.add(item);

     totalIndex++;
     if (item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c != null)
      WRCStartIndex++;


    }
   }
  }
  //Added by Apttus Support || Case : 00213991 || Date : 01-08-2017 || Desc : Option line item were not getting while setting LargeCartThreshold in Config System Properties custom setting

  listOptionLineItem = ListCartOptionLI;

  WRCStartIndex = totalIndex - WRCStartIndex + 1;
  totalIndex = 1;

  /* 
     //ProductConFigId = ApexPages.currentPage().getParameters().get('id');//bY AJ
     cartRepriced(); //by AJ*/
  for (Apttus_Config2__LineItem__c bItem: listBundleLineItem) {
   // Re-Initialize RollOfHours
   bItem.APTS_Roll_up_of_Total_Hours__c = 0;

   //bItem.APTPS_Margin_Percentage__c = NULL;
   if (bItem.Apttus_Config2__ProductId__r.APTS_WRC_Product__c != null && bItem.Apttus_Config2__AdjustmentAmount__c == null) {
    bItem.Apttus_Config2__AdjustmentType__c = '% WRC';
    bItem.Apttus_Config2__AdjustmentAmount__c = bItem.Apttus_Config2__ProductId__r.APTS_WRC_Percentage__c;
    bItem.Apttus_Config2__LineSequence__c = WRCStartIndex++;
   } else if (bItem.Apttus_Config2__ProductId__r.APTS_WRC_Product__c == null) {
    bItem.Apttus_Config2__LineSequence__c = totalIndex++;
   }

   //hjhj  for(Apttus_Config2__LineItem__c oItem : ListCartOptionLI ) {
   for (Apttus_Config2__LineItem__c oItem: listOptionLineItem) {
    if (oItem.Apttus_Config2__ProductId__c == bItem.Apttus_Config2__ProductId__c && oItem.Apttus_Config2__LineNumber__c == bItem.Apttus_Config2__LineNumber__c) {

     if (oItem.Apttus_Config2__PrimaryLineNumber__c > bItem.Apttus_Config2__PrimaryLineNumber__c) {

      if (oItem.Total_of_Hours__c != null) {
       OptionTotalHours = oItem.Total_of_Hours__c;
      }

      //bItem.APTS_Roll_up_of_Total_Hours__c = bItem.APTS_Roll_up_of_Total_Hours__c + OptionTotalHours;//NULLVALUE(oItem.Total_of_Hours__c,0.0);
      bItem.APTS_Roll_up_of_Total_Hours__c = bItem.APTS_Roll_up_of_Total_Hours__c + oItem.Total_of_Hours__c;

     }
    }
   }

   mapIdToTotalHours.put(bItem.id, bItem.APTS_Roll_up_of_Total_Hours__c);
  }

  for (Apttus_Config2.LineItem lineItem: itemColl.getAllLineItems()) {
   Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();
   bIsSpecialBundle = false;

   // Added by Apttus MS
   // item.Base_Ext_Price__c  = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
   if (isDaikinPricingApplicable(item)) {
    bIsSpecialBundle = false;
    Decimal dTotalHours = mapIdToTotalHours.get(item.id);
    if (dTotalHours == null || dTotalHours == 0) {
     dTotalHours = 1;
    }
    if (item.Apttus_Config2__BasePrice__c == null) {
     item.Apttus_Config2__BasePrice__c = 0;
    }
    item.APTPS_Cost__c = (item.Apttus_Config2__BasePrice__c * dTotalHours) + (item.APTS_Product_Attribute_RollUp__c);
   } else if (applyOptionPrice(item) && item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE) {
    bIsSpecialBundle = true;
   }

   if (!bIsSpecialBundle && item.APTPS_Cost__c != null && item.APTPS_Cost__c >= 0) {
    // changed by bhargav
    if (null != item.Estimated_Tax__c){
     item.Apttus_Config2__BaseExtendedCost__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c + item.Estimated_Tax__c;
     item.Base_Ext_Price__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
    }else {
     item.Apttus_Config2__BaseExtendedCost__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
     // Added by Apttus MS
     item.Base_Ext_Price__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
    }
    //Original code is below
    //item.Apttus_Config2__BaseExtendedCost__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
   }

   //Added  by Apttus MS 
   for (Apttus_Config2__LineItem__c bItem: listBundleLineItem) {

    Decimal BaseExtCost = 0.0;
    for (Apttus_Config2__LineItem__c oItem: listOptionLineItem) {

     if (oItem.Apttus_Config2__ProductId__c == bItem.Apttus_Config2__ProductId__c && oItem.Apttus_Config2__LineNumber__c == bItem.Apttus_Config2__LineNumber__c) {

      if (oItem.Apttus_Config2__PrimaryLineNumber__c > bItem.Apttus_Config2__PrimaryLineNumber__c) {

       if (oItem.APTPS_Cost__c == null) {
        oItem.APTPS_Cost__c = 0;
       }

       oItem.Base_Ext_Price__c = oItem.APTPS_Cost__c * oItem.Apttus_Config2__Quantity__c;
       BaseExtCost = BaseExtCost + oItem.APTPS_Cost__c * oItem.Apttus_Config2__Quantity__c;
      }
      //bItem.Base_Ext_Price__c  =  BaseExtCost;       
     }
    }
    // Above line is commented and added here by Apttus Support to avoid "Argument Cannot be null" error. DO NOT REMOVE
    bItem.Base_Ext_Price__c = BaseExtCost;
   }
   // end of addition by Apttus MS  

   //if user has changed Margin% or Selling Price 
   if (!bIsSpecialBundle && item.Apttus_Config2__BaseExtendedCost__c != null && item.Apttus_Config2__BaseExtendedCost__c >= 0 && (item.APTPS_Margin_Percentage__c != null || item.APTPS_Selling_Price__c != null)) {
    //if(!bIsSpecialBundle && item.Apttus_Config2__BaseExtendedCost__c != null && item.Apttus_Config2__BaseExtendedCost__c >= 0  && (item.APTPS_Margin_Percentage__c != null && item.APTPS_Margin_Percentage__c > 0)) {
    // User Changes Margin Percentage
    if (item.APTPS_Margin_Percentage__c != null && item.APTPS_Margin_Percentage__c != item.APTPS_Margin_Percentage_Previous__c) {
     if (item.APTPS_Margin_Percentage__c != 100) {
      item.APTPS_Selling_Price__c = item.Apttus_Config2__BaseExtendedCost__c / (1 - (item.APTPS_Margin_Percentage__c / 100));
     } else {
      item.APTPS_Selling_Price__c = item.Apttus_Config2__BaseExtendedCost__c;
     }

    } else {
     if (item.Apttus_Config2__BaseExtendedCost__c != null && item.Apttus_Config2__BaseExtendedCost__c >= 0 && item.APTPS_Selling_Price__c != null && item.APTPS_Selling_Price__c != 0.00) {
      //if(item.APTPS_Selling_Price_Previous__c != item.APTPS_Selling_Price__c) {//Vipul Commented
      if (item.APTPS_Selling_Price_Previous__c != item.APTPS_Selling_Price__c && item.APTPS_Margin_Percentage__c != item.APTPS_Margin_Percentage_Previous__c) { //Vipul Added
       item.APTPS_Margin_Percentage__c =
        ((item.APTPS_Selling_Price__c - item.Apttus_Config2__BaseExtendedCost__c) / item.APTPS_Selling_Price__c) * 100;
      }
      /*else if (item.APTPS_Selling_Price_Previous__c != item.APTPS_Selling_Price__c && item.APTPS_Margin_Percentage__c == item.APTPS_Margin_Percentage_Previous__c && item.APTPS_Margin_Percentage__c == 0.00
               && item.APTPS_Selling_Price_Previous__c == null) {
          item.APTPS_Margin_Percentage__c = 
          ((item.APTPS_Selling_Price__c - item.Apttus_Config2__BaseExtendedCost__c)/item.APTPS_Selling_Price__c)*100;
      }*/
      else {
       if (item.APTPS_Margin_Percentage__c != null && item.APTPS_Margin_Percentage__c != 100) {
        item.APTPS_Selling_Price__c = item.Apttus_Config2__BaseExtendedCost__c / (1 - (item.APTPS_Margin_Percentage__c / 100));
       } else {
        item.APTPS_Selling_Price__c = item.Apttus_Config2__BaseExtendedCost__c;
       }
      }
     } // End of If Condition
    } // End of Else Condition


    if (item.Apttus_Config2__BaseExtendedCost__c != null && item.Apttus_Config2__BaseExtendedCost__c >= 0 && item.APTPS_Selling_Price__c != null) {
     item.APTPS_Margin_Dollar__c = item.APTPS_Selling_Price__c - item.Apttus_Config2__BaseExtendedCost__c;
    }

   } // End of master if 

   if (!bIsSpecialBundle && item.APTPS_Selling_Price__c == null || item.APTPS_Selling_Price__c == 0.00) {
    item.APTPS_Selling_Price__c = item.Apttus_Config2__BaseExtendedCost__c;
    item.APTPS_Margin_Percentage__c = 0;
    item.APTPS_Margin_Dollar__c = 0;
   }

   if (!bIsSpecialBundle) {
    item.Apttus_Config2__ExtendedPrice__c = item.APTPS_Selling_Price__c;
    item.Apttus_Config2__BaseExtendedPrice__c = item.Apttus_Config2__ExtendedPrice__c;
   }
  } // End of for loop iteration


 }

 /*
     Callback after pricing the line item collection
     Use this method to do all required post-processing after line items are priced.
     @param itemColl the line item collection to post-process
 */
 global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {

  // if(mode == Apttus_Config2.CustomClass.PricingMode.ROLLDOWN){
  // rollUpNetPriceOnBundle(itemColl);
  //}

  if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT != systemMode && !test.isRunningTest()) {
   return;
  }

  for (Apttus_Config2.LineItem lineItem: itemColl.getAllLineItems()) {
   Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();
  }

 }

 /**
  * Callback after line items
  */
 global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemcoll, Apttus_Config2.LineItem li) {}

 /**
  * Callback before line items
  */
 global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemcoll, Apttus_Config2.LineItem lineItemMO) {}


 /**
  * Callback after all batches of line items are processed
  */
 global void finish() {
  if (Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == systemMode) {
   List < Apttus_Config2.LineItem > listLineitem = cart.getLineItems();

   if (listLineitem.isEmpty()) return;
   rollUpNetPriceOnBundle2(listLineitem);
   for (Apttus_Config2.LineItem lineItem: listLineitem) {
    Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();

    if (item != null) {

     if (item.APTPS_Margin_Percentage__c != null && item.APTPS_Margin_Percentage__c > 0) {
      item.APTPS_Margin_Percentage__c = item.APTPS_Margin_Percentage__c; // changed scale
     }

     if (item.APTPS_Selling_Price__c != null && item.APTPS_Selling_Price__c > 0) {
      item.APTPS_Selling_Price__c = item.APTPS_Selling_Price__c; // changed scale
     }
     item.APTPS_Selling_Price_Previous__c = item.APTPS_Selling_Price__c;
     item.APTPS_Margin_Percentage_Previous__c = item.APTPS_Margin_Percentage__c;

    }
   }

   Apttus_Config2__ProductConfiguration__c proConfig = cart.getConfigSO();
   proConfig.RePriced__c = TRUE;
   /*
       Below line is commented by apttus support || Case : 00213990 || Date : 13-09-2017 || 
       Desc : to stop below loop
              1. Click on Repice. 
              2. Finalize (Error:- Please Calculate Use Tax first and then Finalize the Cart) 
              3. Calculate the tax button 
              4. Reprice 
              5. Finalize 
   */
   //proConfig.Use_Tax_Calculated__c = FALSE;
  }

 }

 global void onPriceItemSet(Apttus_Config2__PriceListItem__c itemSO, Apttus_Config2.LineItem lineItemMO) {

 }



 public void rollUpNetPriceOnBundle2(List < Apttus_Config2.LineItem > listLineitem) {

   List < Apttus_Config2__LineItem__c > listBundleLineItem = new List < Apttus_Config2__LineItem__c > ();
   List < Apttus_Config2__LineItem__c > listOptionLineItem = new List < Apttus_Config2__LineItem__c > ();
   Map < Id, Apttus_Config2__LineItem__c > mapOptionLineItem = new Map < Id, Apttus_Config2__LineItem__c > ();
   Map < Id, Apttus_Config2.LineItem > mapIdToconfigLineItem = new Map < Id, Apttus_Config2.LineItem > ();


   Decimal totalOfAllProductsForRisk = 0;
   Decimal totalForWarrantyEquipment = 0;
   Decimal totalForWarrantyPartsMaterial = 0;
   for (Apttus_Config2.LineItem lineItem: listLineitem) {
    Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();

    if (item != null) {
     if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_OPTION && applyOptionPrice(item) && !isDaikinPricingApplicable(item)) {
      listOptionLineItem.add(item);
      mapOptionLineItem.put(item.Apttus_Config2__ProductId__c, item);
     } else if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE      
                && applyOptionPrice(item)
                && !isDaikinPricingApplicable(item)) {

      listBundleLineItem.add(item);
     } else if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE &&
      item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c == null) {
      if (item.Apttus_Config2__ClassificationId__r.Name == 'Equipment - Non Daikin' || item.Apttus_Config2__ClassificationId__r.Name == 'Equipment Daikin') {
       // Below Line commented and added by Apttus Support || Case : 00209919 || Date : 30-03-3017 || Desc : WRC price should be based on Base ext cost (w/o tax)
       totalForWarrantyEquipment += item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
       //totalForWarrantyEquipment += item.Base_Ext_Price__c;
      } else if (item.Apttus_Config2__ClassificationId__r.Name == 'Parts Daikin' || item.Apttus_Config2__ClassificationId__r.Name == 'Parts - Non Daikin') {
       // Below Line commented and added by Apttus Support || Case : 00209919 || Date : 30-03-3017 || Desc : WRC price should be based on Base ext cost (w/o tax)
       //totalForWarrantyPartsMaterial += item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
       totalForWarrantyPartsMaterial += item.Base_Ext_Price__c;
      }
     }

     /* Commented by Apttus MS 
        if(item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE && 
                      item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c==null) {
          // Below Line commented and added by Apttus Support || Case : 00209919 || Date : 30-03-3017 || Desc : WRC price should be based on Base ext cost (w/o tax)
          //totalOfAllProductsForRisk += item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
          totalOfAllProductsForRisk += item.Base_Ext_Price__c;
        }
        */

     // Added by Apttus MS 
     if (item.Apttus_Config2__LineType__c == APTPS_DaikinConstants.LINE_TYPE_PRODUCT_SERVICE &&
      item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c == null) {
      if (item.Base_Ext_Price__c == 0) {
        if(item.APTPS_Cost__c  == null) {
          item.APTPS_Cost__c = 0;
        }
        item.Base_Ext_Price__c = item.APTPS_Cost__c * item.Apttus_Config2__Quantity__c;
      }
      totalOfAllProductsForRisk += item.Base_Ext_Price__c;
      
     }

     // End by Apttus MS 


     mapIdToconfigLineItem.put(item.Id, lineItem);
    }
   }

   if (listBundleLineItem != null && !listBundleLineItem.isEmpty()) {
    for (Apttus_Config2__LineItem__c bItem: listBundleLineItem) {
     if (bItem.Apttus_Config2__ProductId__r.APTS_WRC_Product__c != null) {
      break;
     }

     //Added by Apttus MS
     if (bItem.APTPS_Cost__c == null) {
      bItem.APTPS_Cost__c = 0;
     }
     // End by Apttus MS

     //Changed as issue was faced when adding same product multiple times
     Decimal dTotalNetPrice = 0.0;
     Decimal dTotalCost = 0.0;
     Decimal dTotalExtendedCost = 0.0;
     Decimal dTotalSellingPrice = 0.0;

     for (Apttus_Config2__LineItem__c oItem: listOptionLineItem) {

      if (oItem.Apttus_Config2__ProductId__c == bItem.Apttus_Config2__ProductId__c && oItem.Apttus_Config2__LineNumber__c == bItem.Apttus_Config2__LineNumber__c) {

       if (oItem.Apttus_Config2__PrimaryLineNumber__c > bItem.Apttus_Config2__PrimaryLineNumber__c) {

        if (oItem.Apttus_Config2__NetPrice__c == null) {
         oItem.Apttus_Config2__NetPrice__c = 0;
        }

        if (oItem.APTPS_Cost__c == null) {
         oItem.APTPS_Cost__c = 0;
        }

        if (oItem.APTPS_Selling_Price__c == null) {
         oItem.APTPS_Selling_Price__c = 0;
        }

        dTotalNetPrice = dTotalNetPrice + oItem.Apttus_Config2__AdjustedPrice__c.setScale(2); //Changed From Apttus_Config2__NetPrice__c
        //Changed by Harsh
        dTotalExtendedCost = dTotalExtendedCost + (oItem.APTPS_Cost__c * oItem.Apttus_Config2__Quantity__c + ((oItem.Estimated_Tax__c != null) ? oItem.Estimated_Tax__c : 0));
        dTotalCost = dTotalCost + (oItem.APTPS_Cost__c);
        dTotalSellingPrice = dTotalSellingPrice + oItem.APTPS_Selling_Price__c;

       }
      }


     }


     // Roll-up on bundle LineItem
     bItem.Apttus_Config2__BaseCost__c = dTotalExtendedCost;
     bItem.Apttus_Config2__BaseCostOverride__c = dTotalExtendedCost;
     bItem.Apttus_Config2__Quantity__c = 1;
     bItem.Apttus_Config2__OptionPrice__c = dTotalNetPrice;
     bItem.APTS_Option_Price__c = dTotalNetPrice;

     // Added Net_Price__c on 10/4 for Net Adjustment issue
     //bItem.Apttus_Config2__NetAdjustmentPercent__c = 0;
     //bItem.Apttus_Config2__NetPrice__c = dTotalNetPrice;
     //bItem.Apttus_Config2__BasePriceOverride__c = dTotalNetPrice;
     //bItem.Apttus_Config2__BaseExtendedPrice__c = dTotalNetPrice;

     totalOfAllProductsForRisk -= bItem.APTPS_Cost__c * bItem.Apttus_Config2__Quantity__c;
     bItem.APTPS_Cost__c = dTotalCost;
     totalOfAllProductsForRisk += bItem.APTPS_Cost__c * bItem.Apttus_Config2__Quantity__c;


     if (bItem.Apttus_Config2__ClassificationId__r.Name == 'Equipment - Non Daikin' || bItem.Apttus_Config2__ClassificationId__r.Name == 'Equipment Daikin') {
      totalForWarrantyEquipment += bItem.APTPS_Cost__c * bItem.Apttus_Config2__Quantity__c;
     } else if (bItem.Apttus_Config2__ClassificationId__r.Name == 'Parts Daikin' || bItem.Apttus_Config2__ClassificationId__r.Name == 'Parts - Non Daikin') {
      //totalForWarrantyPartsMaterial += bItem.APTPS_Cost__c * bItem.Apttus_Config2__Quantity__c;
      totalForWarrantyPartsMaterial += bItem.Base_Ext_Price__c;
     }

     //Changed by Harsh
     bItem.Apttus_Config2__BaseExtendedCost__c = bItem.APTPS_Cost__c * bItem.Apttus_Config2__Quantity__c + ((bItem.Estimated_Tax__c != null) ? bItem.Estimated_Tax__c : 0);
     bItem.APTPS_Margin_Dollar__c = 0;
     bItem.APTPS_Margin_Percentage__c = 0;
     bItem.APTPS_Selling_Price__c = dTotalSellingPrice;
     Apttus_Config2.LineItem lItemConfig = mapIdToconfigLineItem.get(bItem.Id);


     lItemConfig.updatePrice();


    }

   }
   for (Apttus_Config2.LineItem lineItem: listLineitem) {
    Apttus_Config2__LineItem__c item = lineItem.getLineItemSO();
    if (item.Apttus_Config2__LineType__c == 'Product/Service' && item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c != null) {
     if (item.Apttus_Config2__AdjustmentAmount__c != null) {
      if (item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c == 'Warranty (Parts & Material)') {
       item.Apttus_Config2__BaseCostOverride__c = (totalForWarrantyPartsMaterial * item.Apttus_Config2__AdjustmentAmount__c) / 100;
      } else if (item.Apttus_Config2__ProductId__r.APTS_WRC_Product__c == 'Warranty (Equipment)') {
       item.Apttus_Config2__BaseCostOverride__c = (totalForWarrantyEquipment * item.Apttus_Config2__AdjustmentAmount__c) / 100;
      } else {
       item.Apttus_Config2__BaseCostOverride__c = (totalOfAllProductsForRisk * item.Apttus_Config2__AdjustmentAmount__c) / 100;
      }
     } else
      item.Apttus_Config2__BaseCostOverride__c = 0;
     item.Apttus_Config2__BasePriceOverride__c = item.Apttus_Config2__BaseCostOverride__c;
     Apttus_Config2.LineItem lItemConfig = mapIdToconfigLineItem.get(item.Id);
     lItemConfig.updatePrice();
    }
   }
  }
  /*Public void cartRepriced(){ //by AJ
        Apttus_Config2__ProductConfiguration__c configRecord = [SELECT Id, RePriced__c FROM Apttus_Config2__ProductConfiguration__c where Id =:ProductConFigId];
          configRecord.RePriced__c = TRUE;
          update configRecord;
    }*/

}