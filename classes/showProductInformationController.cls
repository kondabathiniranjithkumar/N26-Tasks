public class showProductInformationController {
    
    @auraEnabled
    public static productInfoWrapper getProductInfo( Id caseId ) {
        productInfoWrapper piw = new productInfoWrapper();
        
        if( !String.isBlank( caseId ) ) {
            // retrieve contact Info from Case record
            for( Case cs : [ SELECT Id, Contact.Product__c, Contact.Home_Country__c FROM Case WHERE Id =: caseId ]) {
                piw.productName = cs.Contact.Product__c;
                piw.homeCountry = cs.Contact.Home_Country__c;
            }
            
            for( PricebookEntry pe : [ SELECT Id,
                                          UnitPrice,
                                          ATM_Fee__c,
                                          Card_Replacement_Cost__c,
                                          CurrencyISOCode
                                   FROM PricebookEntry 
                                   WHERE Product2.Name =:piw.productName 
                                   AND Pricebook2.Name =: piw.homeCountry  ]) {
            	
                // assign values to wrapper from pricebook entry according to their product and country                       
                piw.cost = (pe.UnitPrice ==0)?'N/a':String.valueOf(pe.UnitPrice) + ' ' + pe.CurrencyISOCode;                                           
                piw.atmFee = (pe.ATM_Fee__c == 0)?'Free':String.valueOf(pe.ATM_Fee__c) + ' %';
                piw.cardReplacementCost = String.valueOf(pe.Card_Replacement_Cost__c) +' '+ pe.CurrencyISOCode ;
            }
        
        }
        return piw;
    }
    
    
    public class productInfoWrapper {
        @auraEnabled public String productName;
        @auraEnabled public String homeCountry;
        @auraEnabled public String cost;
        @auraEnabled public String atmFee;
        @auraEnabled public String cardReplacementCost;
        
    }
}