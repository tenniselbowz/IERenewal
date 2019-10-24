public class ServiceCodeModel {
        public Map<Id, List<Service_Code__c>> serviceCodesWithParent;
        public Map<Id, Map<Id, List<Service_Code__c>>> parentToUnitToSC;

        public static Map<String, ServiceCodeModel> generateModelsPerType(Set<String> types) {
            Map<String, ServiceCodeModel> typesToModel = new Map<String, ServiceCodeModel>();
            for (String typeKey : types) {
                typesToModel.put(typeKey, new ServiceCodeModel());
            }
            return typesToModel;
        }

        public ServiceCodeModel() {
            this.serviceCodesWithParent = new Map<Id, List<Service_Code__c>>();
            this.parentToUnitToSC = new Map<Id, Map<Id, List<Service_Code__c>>>();
           
        }
        public void removeAll() {
            this.serviceCodesWithParent = new Map<Id, List<Service_Code__c>>();
            this.parentToUnitToSC = new Map<Id, Map<Id, List<Service_Code__c>>>();
        }
/*        public void add(Service_Code__c sc) {
            if(!serviceCodesWithParent.containsKey(sc.Parent__c)) {
                this.serviceCodesWithParent.put(sc.Parent__c, new List<Service_Code__c>{sc});
                this.parentToUnitToSC.put(sc.Parent__c, new Map<Id, List<Service_Code__c>>{sc.Unit_Code__c => new List<Service_Code__c>{sc}});
            }
            else {
                this.serviceCodesWithParent.get(sc.Parent__c).add(sc);
                if (parentToUnitToSC.get(sc.Parent__c).containsKey(sc.Unit_Code__c)){
                    parentToUnitToSC.get(sc.Parent__c).get(sc.Unit_Code__c).add(sc);
                } else {
                    parentToUnitToSC.get(sc.Parent__c).put(sc.Unit_Code__c, new List<Service_Code__c>{sc});
                }
            }
        }
*/        public void add(Service_Code__c sc) {
            if(!serviceCodesWithParent.containsKey(sc.Id)) {
                this.serviceCodesWithParent.put(sc.Id, new List<Service_Code__c>{sc});
                this.parentToUnitToSC.put(sc.Id, new Map<Id, List<Service_Code__c>>{sc.Id => new List<Service_Code__c>{sc}});
            }
            else {
                this.serviceCodesWithParent.get(sc.Id).add(sc);
                if (parentToUnitToSC.get(sc.Id).containsKey(sc.Id)){
                    parentToUnitToSC.get(sc.Id).get(sc.Id).add(sc);
                } else {
                    parentToUnitToSC.get(sc.Id).put(sc.Id, new List<Service_Code__c>{sc});
                }
            }
        }

        public List<Service_Code__c> all() {
            List<Service_Code__c> allCodes = new List<Service_Code__c>();
            for (List<Service_Code__c> codeList : this.serviceCodesWithParent.values()) {
                allCodes.addAll(codeList);
            }
            return allCodes;
        }

        public List<Service_Code__c> fromParentAndUnit(Id parentId, Id unitId) {
            if (parentId == null || unitId == null) {
                return null;
            }
            Map<Id, List<Service_Code__c>> toUnitMap = this.parentToUnitToSC.get(parentId);
            if (toUnitMap == null) {
                return null;
            }
            return toUnitMap.get(unitId);
        }
    }