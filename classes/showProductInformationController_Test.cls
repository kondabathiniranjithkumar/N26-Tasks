@isTest(seeAllData = false)
public class showProductInformationController_Test {

    @testSetup
    public static void createTestData(){
        
        //insert accounts
        List<Account> listAccounts = new List<Account>();  
        
        Account acc = new Account();
        acc.Name = 'Test Account 1';
        listAccounts.add(acc);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account 2';
        listAccounts.add(acc2);
        
        insert listAccounts;
                
        //insert contacts for above accounts
        List<Contact> listContacts = new List<Contact>();
        
        Contact con = new Contact();
        con.FirstName = 'Ranjith';
        con.LastName = 'Test';
        con.Email = 'ranjith@test.com';
        con.AccountId = listAccounts[0].Id;
        con.Language__c = 'en';
        con.Home_Country__c = 'IT';
        con.Product__c = 'Black';
        listContacts.add(con);   
        
        con = new Contact();
        con.FirstName = 'Ranjith 2';
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        con.AccountId = listAccounts[1].Id;
        con.Language__c = 'en';
        con.Home_Country__c = 'UK';
        con.Product__c = 'Standard';
        listContacts.add(con); 
        
        insert listContacts;
        
        // insert cases
        List<Case> listCases = new List<Case>();
        
        Case c = new Case();
        c.Subject = 'test';
        c.ContactId = listContacts[0].Id;
        listCases.add(c);
        
        c = new Case();
        c.Subject = 'test';
        c.ContactId = listContacts[1].Id;
        listCases.add(c);
        
        insert listCases;
        
        // insert products
        List<Product2> listProducts = new List<Product2>();
        
        Product2 p = new Product2();
        p.Name = 'Standard';    
        p.IsActive = true;
        listProducts.add(p);
        
        p = new Product2();
        p.Name = 'Black';   
        p.IsActive = true;
        listProducts.add(p);
        
        insert listProducts;
        
        // insert pricebooks as per Country name and currency
        List<Pricebook2> listPricebooks = new List<Pricebook2>();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'UK';
        pb.CurrencyIsoCode = 'GBP';
        pb.IsActive = true;
        listPricebooks.add(pb);
        
        pb = new Pricebook2();
        pb.Name = 'IT';
        pb.CurrencyIsoCode = 'EUR';  
        pb.IsActive = true;
        listPricebooks.add(pb);
        
        insert listPricebooks;
        
        List<PricebookEntry> listPriceBookEntries = new List<PricebookEntry>();
        
        // Define Standard price for the products
        Id standardPricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPricebookId, CurrencyIsoCode='GBP', Product2Id = listProducts[0].Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry standardPBE2 = new PricebookEntry(Pricebook2Id = standardPricebookId, CurrencyIsoCode='EUR', Product2Id = listProducts[1].Id, UnitPrice = 1000, IsActive = true);
    	
        listPriceBookEntries.add(standardPBE);
        listPriceBookEntries.add(standardPBE2);
        
        insert listPriceBookEntries;
        
        listPricebookEntries.clear();
                
        // Define the Pricebook entries for both products in individual pricebooks
        PricebookEntry pbe = new PricebookEntry();
        pbe.ATM_Fee__c = 1.7;
        pbe.Card_Replacement_Cost__c = 6;
        pbe.UnitPrice = 0;
        pbe.Product2Id = listProducts[0].Id;
        pbe.Pricebook2Id = listPricebooks[0].Id;
        pbe.CurrencyIsoCode = 'GBP';
        listPriceBookEntries.add(pbe);
        
        pbe = new PricebookEntry();
        pbe.ATM_Fee__c = 0;
        pbe.Card_Replacement_Cost__c = 6;
        pbe.UnitPrice = 990;
        pbe.Product2Id = listProducts[1].Id;
        pbe.Pricebook2Id = listPricebooks[1].Id;
        pbe.CurrencyIsoCode = 'EUR';
        listPriceBookEntries.add(pbe);
        
        insert listPriceBookEntries;
    }
    
    public static testMethod void testProductInfo(){
        
        Test.startTest();
        for(Case c: [select Id from Case]){
            showProductInformationController.productInfoWrapper pw = showProductInformationController.getProductInfo(c.Id);
            
            // Assert values for both the cases
            if(pw.homeCountry == 'UK' && pw.productName == 'General'){
                system.assertEquals('N/a',pw.cost);
                system.assertEquals('1.7 %',pw.atmFee);
                system.assertEquals('6.00 GBP',pw.cardReplacementCost);
            }
            
            if(pw.homeCountry == 'IT' && pw.productName == 'Black'){
                system.assertEquals('990.00 EUR',pw.cost);
                system.assertEquals('Free',pw.atmFee);
                system.assertEquals('6.00 EUR',pw.cardReplacementCost);
            }
        }
        Test.stopTest();
        
    }
}