({
	retrieveProductInfo : function( component, event, helper ) {
		var action = component.get("c.getProductInfo");
        action.setParams({
            "caseId": component.get("v.recordId")
        });
        
        // Callback which will fetch the response from Apex and set the value to Component        
        action.setCallback(this, function(a) { 
            console.log(a.getReturnValue());
            // Set the value in the Alerts List an attribute that we created into Apex Controller
            component.set("v.productName", a.getReturnValue().productName);
            component.set("v.homeCountry", a.getReturnValue().homeCountry);
            component.set("v.Cost", a.getReturnValue().cost);
            component.set("v.AtmFee", a.getReturnValue().atmFee);
            component.set("v.cardReplacementCost", a.getReturnValue().cardReplacementCost);
            
        });       
        
        // Place the Action in the Queue    
        $A.enqueueAction(action); 
	}
})