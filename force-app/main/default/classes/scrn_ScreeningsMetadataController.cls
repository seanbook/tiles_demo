public with sharing class scrn_ScreeningsMetadataController {
    public class wrapperClass{
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String iconName {get;set;}
        @AuraEnabled public String iconSize {get; set;}
        @AuraEnabled public Decimal sortOrder {get;set;}
        @AuraEnabled public String screenStatus {get;set;}
        @AuraEnabled public Boolean isInstruction {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}
        @AuraEnabled public Boolean isNotStarted {get;set;}
        @AuraEnabled public Boolean isInProgress {get;set;}
        @AuraEnabled public Boolean isComplete {get;set;}
        
        public wrapperClass(Screenings__MDT scrn) {
            this.title = scrn.Title__c;
            this.iconName = scrn.Icon_Name__c;
            this.iconSize = scrn.Icon_Size__c;
            this.sortOrder = scrn.Order__c;
            this.isDisabled = true;
        }
        public wrapperClass(scrn_Screening__c scrnStatus){
            this.title = scrnStatus.Name;
            this.screenStatus = scrnStatus.Status__c;
        }
    }
    
    public static List<Screenings__MDT> getMTD(){
        return [SELECT Id, Title__c, Icon_Name__c, Active__c, Order__c, Icon_Size__c FROM Screenings__MDT WHERE Active__c = TRUE ORDER BY Order__c];
    }
    
    public static List<scrn_Screening__c> getScrnStatus(String oppId){
        return [SELECT Id, Name, Opportunity__c, Status__c FROM scrn_Screening__c WHERE Opportunity__c = :oppId ORDER BY Sort_Order__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, WrapperClass> getScreenings(String oppId){
        Map<String, WrapperClass> mapTitleToWrapper = new Map<String, WrapperClass>();
        Screenings__MDT[] qliList = getMTD();
        for (Screenings__MDT qli : qliList) {
            WrapperClass wrapper = new WrapperClass(qli);
            mapTitleToWrapper.put(wrapper.title, wrapper);
        }
        scrn_Screening__c[] scrnStatusList = getScrnStatus(oppId);
        Boolean scrnDisabled = false;
        for (scrn_Screening__c scrnStatus : scrnStatusList) {
            mapTitleToWrapper.get(scrnStatus.Name).screenStatus = scrnStatus.Status__c;
            if (scrnStatus.Name == 'Instructions' && scrnStatus.Status__c == 'Not Started'){
                mapTitleToWrapper.get(scrnStatus.Name).isInstruction = true;
                mapTitleToWrapper.get(scrnStatus.Name).isDisabled = false;
                scrnDisabled = true;
            } else if (!scrnDisabled) {
                mapTitleToWrapper.get(scrnStatus.Name).isDisabled = false;
                switch on scrnStatus.Status__c {
                    when 'Not Started' {
                        mapTitleToWrapper.get(scrnStatus.Name).isNotStarted = true;
                    }
                    when 'In Progress' {
                        mapTitleToWrapper.get(scrnStatus.Name).isInProgress = true;
                    }
                    when else {
                        mapTitleToWrapper.get(scrnStatus.Name).isComplete = true;
                    }
                }
            }
        }
        return mapTitleToWrapper;
    }
}