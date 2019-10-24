public class CloneSObject {
	private final String LINE_OF_BUSINESS = 'MA - Renewal';
	public SObject cloneObject;
	public SObject masterObject;
	public Id masterObjectId;
	public List<Custom_Clone_System_Fields__mdt> cloneSystemFields;
	public List<Schema.Childrelationship> relatedObjectsList;
	public List<Custom_Clone_Child_Object__mdt> objectToChildObject;
	public String fieldSetName;
	public User currentUser;
	public String objectType;
	public Schema.SObjectType sObjectTypeObj;
	public CloneSObject(SObject masterObject, String objectType, String fieldSetName, List<Custom_Clone_System_Fields__mdt> objectToField, List<Custom_Clone_Child_Object__mdt> objectToChildObject) {
		if(objectToField == null) {
			objectToField = new List<Custom_Clone_System_Fields__mdt>();
		}
		if(objectToChildObject == null) {
			objectToChildObject = new List<Custom_Clone_Child_Object__mdt>();
		}
		this.objectType = objectType;
		this.cloneSystemFields = objectToField;
		this.objectToChildObject = objectToChildObject;
		this.cloneObject = Schema.getGlobalDescribe().get(objectType).newSObject();
		this.fieldSetName = fieldSetName;
		this.masterObject = masterObject;
		
	}

	@testvisible private void getCurrentRunningUser(Id userId) {
		Map<Boolean, List<Custom_Clone_System_Fields__mdt>> isLookupToSystemFields = Groupby.booleans('Is_Lookup__c', this.cloneSystemFields); 
		String baseQuery = 'SELECT {0} FROM User WHERE Id =: userId Limit 1';
		String queryFields = String.join(new List<String>(Pluck.strings('Value__C',isLookupToSystemFields.get(true))), ',');
		currentUser = Database.query(String.format(baseQuery, new List<String>{queryFields}));
	}

	@testvisible private void populateMasterClone() {
		String fieldsToQuery = '';
		String parentObjectFields = '';
		String subQueryFields = '';
		Map<String, List<Custom_Clone_System_Fields__mdt>> customFields = GroupBy.strings('Location__c', this.cloneSystemFields);
		for(Schema.FieldSetMember field : Schema.getGlobalDescribe().get(objectType).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()) {
            fieldsToQuery += field.getFieldPath() + ', ';
        }
        if(customFields.containsKey('ParentObject')) {
	        for(Custom_Clone_System_Fields__mdt field : customFields.get('ParentObject')) {
	        	parentObjectFields += field.Field_Api__c + ', ';
	        }
	     }
        for(Custom_Clone_Child_Object__mdt childRelationship : objectToChildObject) {
        	String requiredFields = childRelationship.Required_Fields__c == null? ' ': childRelationship.Required_Fields__c + ' ';
        	subQueryFields += '( SELECT ' + requiredFields + childRelationship.Parent_Lookup_Field__c +  ' FROM '+ childRelationship.Child_Field_on_Parent__c+ '), ';
        }
        masterObjectId = masterObject.Id;
		String sObjectQueryBase = 'SELECT {0} {1} {2} Id FROM {3} WHERE Id =: masterObjectId Limit 1';
		
		masterObject =(SObject)(Database.query(String.format(sObjectQueryBase, new List<String>{fieldsToQuery, parentObjectFields, subQueryFields, objectType})))[0];
	}

	@testvisible private void cloneFields() {
		for(Schema.FieldSetMember field :  Schema.getGlobalDescribe().get(objectType).getDescribe().FieldSets.getMap().get(fieldSetName).getFields()) {
			cloneObject.put(field.getFieldPath(), masterObject.get(field.getFieldPath()));
		}
		for(Custom_Clone_System_Fields__mdt field : cloneSystemFields) {
			if(field.Location__c.equals('Value')) {
				if(field.Type__c.equals('Decimal')) {
					cloneObject.put(field.Field_Api__c, Decimal.valueof(field.Value__c));
				}
				else {
					cloneObject.put(field.Field_Api__c, field.Value__c);
				}
			}
			else if(field.Location__c.equals('System')) {
				cloneObject.put(field.Field_Api__c, System.today().addDays(Integer.valueof(field.Value__c)));
			}
			else if(field.Location__c.equals('User')) {
				List<String> lookupLevels = field.Value__c.split('\\.');
				Boolean nullObject = false;
				SObject lookupObject = currentUser;
				for(Integer i = 0; i <  lookupLevels.size()-1; i++) {
					if(lookupObject.getSobject(lookupLevels.get(i)) == null) {
						nullObject = true;
						break;
					}
					lookupObject = lookupObject.getSobject(lookupLevels.get(i));
				}
				if(!nullObject) {
					cloneObject.put(field.Field_Api__c, lookupObject.get(lookupLevels.get(lookupLevels.size()-1)));
				}
			}
			else if(field.Location__c.equals('ParentObject')) {
				if(field.Copy_Clone__c) {
					if(field.Field_Api__c == 'Name' || field.Field_Api__c == 'Apttus_Proposal__Proposal_Name__c') {
						cloneObject.put(field.Field_Api__c, masterObject.get(field.Field_Api__c) + field.Value__c + ' ' + Datetime.now());
					}
					else {
						cloneObject.put(field.Field_Api__c, masterObject.get(field.Field_Api__c) + field.Value__c);
					}
				}
				else if(field.Is_Lookup__c) {
					cloneObject.put(field.Field_Api__c, masterObject.get(field.Value__c));
				}
				else {
					cloneObject.put(field.Field_Api__c, masterObject.get(field.Field_Api__c));

				}
			}
		}
		if(objectType == 'Apttus_Proposal__Proposal__c') {
			for(Schema.FieldSetMember field :  Schema.getGlobalDescribe().get(objectType).getDescribe().FieldSets.getMap().get('Quote_Clone_Null_Mapping').getFields()) {
				if(field.getType() == Schema.DisplayType.Boolean) {
					cloneObject.put(field.getFieldPath(), false);
				}
				else {
					cloneObject.put(field.getFieldPath(), null);
				}
			}
		}
	}

	public void runFullClone() {
		getCurrentRunningUser(UserInfo.getUserId());
		populateMasterClone();
		cloneFields();
	}

	public Boolean saveCloneObject() {
		try {
			insert cloneObject;
			if(objectType == 'Apttus_Proposal__Proposal__c') {
				Boolean status = Apttus_QPConfig.QPConfigWebService.copyProductConfiguration(masterObjectId, cloneObject.Id);
			}
		}
		catch (DmlException dmlEx) {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlEx.getMessage()));
			return false;
		}
		return true;
	}


	public Boolean cloneAndSaveChildObjects() {
		List<SObject> childObjects = new List<SObject>();
		if(objectToChildObject == null || objectToChildObject.isEmpty()) {
			objectToChildObject = new List<Custom_Clone_Child_Object__mdt>();
		}
		for(Custom_Clone_Child_Object__mdt childRelationship : objectToChildObject) {
			for(SObject obj : masterObject.getSObjects(childRelationship.Child_Field_on_Parent__c)) {
				SObject childClone = obj.clone(false, true, false, false);
				childClone.put(childRelationship.Parent_Lookup_Field__c, cloneObject.Id);
				if(childRelationship.Copy_User_Field__c) {
					childClone.put(childRelationship.User_Lookup_Field__c, currentUser.Id);
					break;
				}
				childObjects.add(childClone);
			}
		}
		try {
			insert childObjects;
		}
		catch (DmlException dmlEx) {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlEx.getMessage()));
			return false;
		}
		return true;
	}

}