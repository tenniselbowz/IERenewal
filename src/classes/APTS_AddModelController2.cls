/*************************************************************
@Name: APTS_AddModelController
@Author: Hardik Shah
@CreateDate: 18/01/2016
@Description: Controller to save MA Model Data Enter by User
@UsedBy: VF-Page/APTS_AddModel.page
@ModifiedBy: NA
@ModifiedDate: NA
@ChangeDescription:
PS: @ModifiedBy and @ChangeDescription can be repeated multiple time, based on number of changes made to the original process.
******************************************************************/

global class APTS_AddModelController2 {

 public List<MA_Model__c > newModels;
 private String sConfigRequestID = null;
 private String sID = null;
 public String configurationId;
 public String proposalId;
 public Integer rowCount = 0;
 public Integer rowToDelete {get;set;}
 private List<Apttus_Config2__LineItem__c> lineItems;
 public Set<String> singleLineItemCategories;
 public List<Ma_Model__c> modelsToDelete;
 private Set<String> lineTypes;
 private Set<String> lineGroups;
 private Set<String> serialNumbers;
 private Map<String, Set<String>> typeToGroup;
 private Map<String, Ma_Model__c> serialNumberToModel;
 private Map<String, Map<String, Ma_Model__c>> nonSerializedNumbers;
 private Map<String, List<Ma_Model__c>> nonSerializedServiceTech;
 public Boolean isAllLabor {get;set;}
 public Boolean makeServiceTech = false;
 public Set<String> hierarchiesWithNoModels;
 public Set<String> productWithNoModels;
 public Set<String> laborHierarchies;
 public List<Ma_Model__c> pulledInModels;
 final public String SERVICE_TECH = '*Service Technician S&R/TK';
 final public String ROOF_TOP = 'Roof Top / Packaged or Split Systems (Unitary Equipment, Heating and cooling)';
 final public Integer serialNumberPos = 2;
 public List<ModelWrapper> allModels {
  get {
   if (allModels == null) {
    allModels = new List<ModelWrapper > ();
   }
   return allModels;
  }
  set;
 }

 public APTS_AddModelController2() {

  typeToGroup = new Map<String, Set<String >> ();
  serialNumberToModel = new Map<String, Ma_Model__c > ();
  nonSerializedNumbers = new Map<String, Map<String, Ma_Model__c >> ();
  singleLineItemCategories = new Set<String > (Label.singleLineItemCategories.trim().split(','));
  hierarchiesWithNoModels = new Set<String > (Label.hierarchiesWithNoModels.trim().split(','));
  productWithNoModels = new Set<String > (Label.productWithNoModels.trim().split(','));
  laborHierarchies = new Set<String > ();
  for (String laborHierarchy: Label.laborHierarchies.split(',')) {
   laborHierarchies.add(laborHierarchy.trim());
  }

  Map<String, String > parameters = Apexpages.currentPage().getParameters();
  sConfigRequestID = parameters.get('configRequestId');
  configurationId = parameters.get('id');
  proposalId = parameters.get('businessObjectId');

  lineItems = [
   SELECT Apttus_Config2__Quantity__c, Equipment_Group__c, APTPS_Product_Name__c, Apttus_Config2__Description__c, Serial__c,
   Apttus_Config2__AttributeValueId__r.Model__r.Name, Apttus_Config2__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name,
   Apttus_Config2__BaseProductId__r.Name
   FROM Apttus_Config2__LineItem__c
   WHERE Apttus_Config2__ConfigurationId__c = : configurationId
   AND Apttus_Config2__Quantity__c > 0
   AND Apttus_Config2__AdHocGroupId__c != null
   AND Apttus_Config2__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name NOT IN: hierarchiesWithNoModels
  ];

  newModels = new List<MA_Model__c > ();

  Set<String > lineItemHierarchies = Pluck.strings('Apttus_Config2__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name', lineItems);
  isAllLabor = laborHierarchies.containsAll(lineItemHierarchies);
  if (!isAllLabor) {
   removeNonMaintenceProducts(lineItems, laborHierarchies);
   makeServiceTech = false;
  }

  serialNumbers = getAllSerialNumbers(lineItems);

  lineGroups = Pluck.strings('Equipment_Group__c', lineItems);
  lineTypes = Pluck.strings('APTPS_Product_Name__c', lineItems);
  String query = 'SELECT Equipment_Type__c, Equipment_Type_Labor__c, Equipment_Group__c, Model__c, Serial__c, Non_Serialized__c, Manufacturer__c, Other_Manufacturer__c, Special_Instructions__c, UniqueNumber__c, Proposal__c, Site_Location__c FROM MA_Model__c';
  String filter = ' WHERE Proposal__c = :proposalId AND Equipment_Group__c IN  :lineGroups AND (Serial__c IN :serialNumbers OR Non_Serialized__c = true)';
  String lineTypefilter = 'AND Equipment_Type__c IN :lineTypes';
  query += filter;

  if (!lineTypes.contains(SERVICE_TECH)) {
   query += lineTypefilter;
  } else {
   makeServiceTech = true;
   nonSerializedServiceTech = new Map<String, List<Ma_Model__c >> ();
  }

  pulledInModels = Database.query(query);
  modelsToDelete = [SELECT Id FROM Ma_Model__c
   WHERE Proposal__c = : proposalId
   AND Id NOT IN: pulledInModels
  ];

  for (Ma_Model__c model: pulledInModels) {
   if (!model.Non_Serialized__c) {
    serialNumberToModel.put(model.Serial__c, model);
   } else {
    if (lineTypes.contains(model.Equipment_Type__c)) {
     nonSerializedNumbers.put(model.Equipment_Type__c, new Map<String, Ma_Model__c > {
      model.Equipment_Group__c => model
     });
    } else if (makeServiceTech) {
     if (nonSerializedServiceTech.containsKey(model.Equipment_Group__c)) {
      nonSerializedServiceTech.get(model.Equipment_Group__c).add(model);
     } else {
      nonSerializedServiceTech.put(model.Equipment_Group__c, new List<Ma_Model__c > {
       model
      });
     }
    }
   }
  }


  if (lineItems.isEmpty()) {
   return;
  }


  for (Apttus_Config2__LineItem__c lineItem: lineItems) {
   Decimal numOfModels = 0;
   if (productWithNoModels.contains(lineItem.APTPS_Product_Name__c)) {
    continue;
   }
   if (typeToGroup.containsKey(lineItem.APTPS_Product_Name__c)) {
    typeToGroup.get(lineItem.APTPS_Product_Name__c).add(lineItem.Equipment_Group__c);

   } else {
    typeToGroup.put(lineItem.APTPS_Product_Name__c, new Set<String > {
     lineItem.Equipment_Group__c
    });
   }

   if (lineItem.Apttus_Config2__Quantity__c != null) {
    numOfModels = numberOfModelsToMake(lineItem, isSingleQuanity(lineItem));
   }
   if (!makeServiceTech && numOfModels > 0) {
    createBlankModel(numOfModels, lineItem);
   } else if (makeServiceTech) {
    createBlankModel(1, lineItem);
   }
  }
 }

 private void removeNonMaintenceProducts(List<Apttus_Config2__LineItem__c > lineItems, Set<String > laborHierarchies) {
  for (Integer spot = 0; spot<lineItems.size(); spot++) {
   if (laborHierarchies.contains(lineItems.get(spot).Apttus_Config2__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name)) {
    lineItems.remove(spot);
   }
  }
 }

 private void createBlankModel(Decimal numOfModels, Apttus_Config2__LineItem__c li) {
  for (Decimal i = 0; i<numOfModels; i++) {
   MA_Model__c newModel = new MA_Model__c();
   newModel.Equipment_Type__c = li.APTPS_Product_Name__c;
   newModel.Equipment_Group__c = li.Equipment_Group__c;
   newModel.Model__c = li.Apttus_Config2__AttributeValueId__r.Model__r.Name;
   newModel.Proposal__c = proposalId;
   allModels.add(new ModelWrapper(newModel, li, rowCount, isAllLabor));
   rowCount++;
  }
 }

 private Decimal numberOfModelsToMake(Apttus_Config2__LineItem__c lineItem, Boolean isSingleQuanity) {
  Decimal numberOfNewModels = lineItem.Apttus_Config2__Quantity__c;
  Boolean singleLineCreateBlank = true;
  if (lineItem.Serial__c != null) {
   if (productWithNoModels.contains(lineItem.APTPS_Product_Name__c)) {
    return 0;
   }
   for (String serialNumber: getAllSerialNumbers(new List<Apttus_Config2__LineItem__c > {
     lineItem
    })) {
    Ma_Model__c ma;
    serialNumber = serialNumber.trim();
    if (serialNumberToModel.containsKey(serialNumber)) {
     ma = serialNumberToModel.get(serialNumber);
     singleLineCreateBlank = false;
     if ((ma.Equipment_Type__c == lineItem.APTPS_Product_Name__c && ma.Equipment_Group__c == lineItem.Equipment_Group__c)) {
      numberOfNewModels = makeNewModelWrapper(ma, lineItem, numberOfNewModels);
      serialNumberToModel.remove(serialNumber);
     } else if (lineItem.APTPS_Product_Name__c == SERVICE_TECH) {
      numberOfNewModels = makeNewModelWrapper(ma, lineItem, numberOfNewModels);
      serialNumberToModel.remove(serialNumber);
      makeServiceTech = false;
     }
    } else if (nonSerializedNumbers.containsKey(lineItem.APTPS_Product_Name__c) && nonSerializedNumbers.get(lineItem.APTPS_Product_Name__c).containsKey(lineItem.Equipment_Group__c)) {
     numberOfNewModels = makeNewModelWrapper(nonSerializedNumbers.get(lineItem.APTPS_Product_Name__c).get(lineItem.Equipment_Group__c), lineItem, numberOfNewModels);
     singleLineCreateBlank = false;
    }
   }
  } else if (makeServiceTech) {
   if (nonSerializedServiceTech.containsKey(lineItem.Equipment_Group__c)) {
    for (Ma_Model__c model: nonSerializedServiceTech.get(lineItem.Equipment_Group__c)) {
     numberOfNewModels = makeNewModelWrapper(model, lineItem, numberOfNewModels);
    }
   }
  }

  if (!singleLineCreateBlank && isSingleQuanity) {
   return 0;
  } else if (singleLineCreateBlank && isSingleQuanity) {
   return 1;
  }
  return numberOfNewModels;
 }

 private Decimal makeNewModelWrapper(Ma_Model__c ma, Apttus_Config2__LineItem__c lineItem, Decimal numOfModels) {
  allModels.add(new ModelWrapper(ma, lineItem, rowCount, isAllLabor));
  rowCount++;
  return --numOfModels;
 }

 private Boolean isSingleQuanity(Apttus_Config2__LineItem__c li) {
  return (!String.isBlank(li.APTPS_Product_Name__c)) && (singleLineItemCategories.contains(li.APTPS_Product_Name__c) || li.APTPS_Product_Name__c == ROOF_TOP);
 }

 private Set<String > getAllSerialNumbers(List<Apttus_Config2__LineItem__c > lineItems) {
  Set<String > allSerialNumbers = new Set<String > ();
  for (String serialNumber: Pluck.strings('Serial__c', lineItems)) {
   for (String str: serialNumber.split(',')) {
    allSerialNumbers.add(str.trim().split('\\|')[serialNumberPos].trim());
   }
  }
  return allSerialNumbers;
 }


 public Pagereference saveMAModels() {
  PageReference pageRef = null;
  Map<String, Map<String, List<Ma_Model__c >>> typeToGroupToModel = new Map<String, Map<String, List<Ma_Model__c >>> {};
  List<Ma_Model__c > allMas = new List<Ma_Model__c > ();
  for (ModelWrapper oModel: allModels) {
   Boolean error = false;
   Ma_Model__c ma = oModel.modelObj;
   if (!isAllLabor && !(typeToGroup.containsKey(ma.Equipment_Type__c) && typeToGroup.get(ma.Equipment_Type__c).contains(ma.Equipment_Group__c))) {
    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'A model would not relate to line item that is in the cart'));
    return null;
   }
   if (String.isEmpty(ma.Equipment_Group__c) || (String.isEmpty(ma.Equipment_Type__c) && String.isEmpty(ma.Equipment_Type_Labor__c)) || String.isEmpty(ma.Model__c)) {
    error = true;
   } else if (String.isEmpty(ma.Serial__c) && !ma.Non_Serialized__c) {
    error = true;
   }

   if (error) {
    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, LABEL.APTS_Model_Validation_Message));
    return null;
   }

   if (isAllLabor) {
    ma.Equipment_Type__c = ma.Equipment_Type_Labor__c;
   }
   allMas.add(ma);
   //setting map from type -> equipment group -> list of MA_Model
   if (ma != null) {
    if (typeToGroupToModel.containsKey(ma.Equipment_Type__c)) {
     if (typeToGroupToModel.get(ma.Equipment_Type__c).containsKey(ma.Equipment_Group__c)) {
      typeToGroupToModel.get(ma.Equipment_Type__c).get(ma.Equipment_Group__c).add(ma);
     } else {
      typeToGroupToModel.get(ma.Equipment_Type__c).put(ma.Equipment_Group__c, new List<Ma_Model__c > {
       ma
      });
     }
    } else if (lineTypes.contains(SERVICE_TECH)) {
     if (typeToGroupToModel.containsKey(SERVICE_TECH)) {
      if (typeToGroupToModel.get(SERVICE_TECH).containsKey(ma.Equipment_Group__c)) {
       typeToGroupToModel.get(SERVICE_TECH).get(ma.Equipment_Group__c).add(ma);
      } else {
       typeToGroupToModel.get(SERVICE_TECH).put(ma.Equipment_Group__c, new List<Ma_Model__c > {
        ma
       });
      }
     } else {
      typeToGroupToModel.put(SERVICE_TECH, new Map<String, List<Ma_Model__c >> {
       ma.Equipment_Group__c => new List<Ma_Model__c > {
        ma
       }
      });
     }
    } else {
     typeToGroupToModel.put(ma.Equipment_Type__c, new Map<String, List<Ma_Model__c >> {
      ma.Equipment_Group__c => new List<Ma_Model__c > {
       ma
      }
     });
    }
   }
  }
  List<Apttus_Config2__LineItem__c > updateLines = getUpdatedLineItems(allMas, typeToGroupToModel);
  Savepoint sp = Database.setSavepoint();
  try {
   if (allModels != null && allModels.size() >= 1 && updateLines != null) {
    upsert allMas;
    if (!Test.isRunningTest()) {
     update updateLines;
    }
    delete modelsToDelete;
    Apttus_Config2__ProductConfiguration__c objProduct = new Apttus_Config2__ProductConfiguration__c(id = configurationid, AddModelsPageChecked__c = true);
    update objProduct;
    //Changed By Harsh To make redirection dynamic based on flow
    //pageRef = Page.Apttus_Config2__CartDetailView;

    String currentFlow = ApexPages.currentPage().getParameters().get('flow');
    Apttus_Config2__ConfigFlow__c configSetting = getFlowOrDefaultSetting(currentFlow);
    if (configSetting != null && configSetting.Apttus_Config2__CartPage__c != null) {
     pageRef = new PageReference('/apex/' + configSetting.Apttus_Config2__CartPage__c);
     pageRef.getParameters().put('configRequestId', sConfigRequestID);
     pageRef.getParameters().put('id', configurationId);
     pageRef.getParameters().put('businessObjectId', proposalId);
     pageRef.setredirect(true);
    } else {
     Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'No Cart Page found for current flow'));
    }


   }

  } catch (DmlException dml) {
   Database.rollback(sp);
   Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, dml.getMessage()));
   return null;
  }
  return pageRef;
 }


 private List<Apttus_Config2__LineItem__c > getUpdatedLineItems(List<Ma_Model__c > allMas, Map<String, Map<String, List<Ma_Model__c >>> typeToGroupToModel) {
  List<Apttus_Config2__LineItem__c > updateLines = new List<Apttus_Config2__LineItem__c > ();
  Set<ID > updatedIds = new Set<Id > ();
  for (Apttus_Config2__LineItem__c lineItem: lineItems) {
   if ((!isAllLabor && laborHierarchies.contains(lineItem.Apttus_Config2__ClassificationId__r.Apttus_Config2__HierarchyId__r.Name))) {
    continue;
   }
   Decimal newNumToMake = 0;
   Boolean hasNonSerialized = false;
   if (typeToGroupToModel.containsKey(lineItem.APTPS_Product_Name__c) &&
    typeToGroupToModel.get(lineItem.APTPS_Product_Name__c).containsKey(lineItem.Equipment_Group__c)) {
    for (Ma_Model__c ma: typeToGroupToModel.get(lineItem.APTPS_Product_Name__c).get(lineItem.Equipment_Group__c)) {
     String manufacturer = '';

     if (ma.Manufacturer__c == 'Other' && !String.isBlank(ma.Other_Manufacturer__c)) {
      manufacturer = ma.Other_Manufacturer__c;
     } else if (ma.Manufacturer__c == 'Other' && String.isBlank(ma.Other_Manufacturer__c)) {
      manufacturer = 'Other Manufacturer';
     } else {
      manufacturer = ma.Manufacturer__c;
     }

     if (ma.Non_Serialized__c == true) {
      hasNonSerialized = true;
     }
     if (lineItem.Serial__c == null) {
      lineItem.Serial__c = '';
     }
     if (!updatedIds.contains(lineItem.Id)) {
      updatedIds.add(lineItem.Id);
      updateLines.add(lineItem);
      newNumToMake++;

      lineItem.Serial__c = manufacturer + '|' + ma.Model__c + '|' + ma.Serial__c;
      lineItem.Site_Location_Text__c = ma.Site_Location__c;
     } else {
      newNumToMake++;
      lineItem.Serial__c = lineItem.Serial__c + ',\n' + manufacturer + '|' + ma.Model__c + '|' + ma.Serial__c;
      lineItem.Site_Location_Text__c += ', ' + ma.Site_Location__c;
     }
    }
   }
   if (hasNonSerialized && (newNumToMake > lineItem.Apttus_Config2__Quantity__c)) {
    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Label.NonSerializedQuantityError));
    return null;
   } else if (isSingleQuanity(lineItem) && newNumToMake > lineItem.Apttus_Config2__Quantity__c) {
    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Label.SingLineItemsError));
    return null;
   }
   if (!isSingleQuanity(lineItem) && !isAllLabor) {
    lineItem.Apttus_Config2__Quantity__c = newNumToMake;
   }
  }
  return updateLines;
 }

 // Add a row - Associate Proposal-Id,Unique-Number
 // Unique Number field is used to associate with MA Model Object.
 public PageReference AddRow() {
  MA_Model__c newModel = new MA_Model__c(Proposal__c = proposalId);
  allModels.add(new ModelWrapper(newModel, null, rowCount, isAllLabor));
  rowCount++;
  return null;
 }

 // Delete a row - Associate Proposal-Id,Unique-Number
 // Unique Number field is used to associate with MA Model Object.
 public Pagereference removeRow() {
  Integer modelToRemove = 0;
  for (Integer i = 0; i<allModels.size(); i++) {
   ModelWrapper model = allModels.get(i);
   if (model.rowNumber == rowToDelete) {
    modelToRemove = i;
    break;
   }
  }
  if (allModels.get(modelToRemove).modelObj.Id != null) {
   modelsToDelete.add(allModels.get(modelToRemove).modelObj);
  }
  allModels.remove(modelToRemove);
  rowCount--;
  Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, 'Row ' + modelToRemove + ' was removed'));

  return null;
 }

 private Apttus_Config2__ConfigFlow__c getFlowOrDefaultSetting(String flowname) {
  Apttus_Config2__ConfigFlow__c configSetting = Apttus_Config2__ConfigFlow__c.getValues(flowname);
  if (configSetting == null) {
   configSetting = Apttus_Config2__ConfigFlow__c.getValues('Default');
  }
  return configSetting;
 }
}