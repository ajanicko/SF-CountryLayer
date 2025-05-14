trigger LeadTrigger on Lead (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            LeadTriggerHandler handler = new LeadTriggerHandler();
            handler.updateCountry(Trigger.new);
        }
        if (Trigger.isUpdate) {
            List<Lead> leadsToUpdate = new List<Lead>();
            for (Integer i = 0; i < Trigger.new.size(); i++) {
                Lead newLead = Trigger.new[i];
                Lead oldLead = Trigger.old[i];
                if (newLead.Country_Name__c != oldLead.Country_Name__c) {
                    leadsToUpdate.add(newLead);
                }
            }
            if (!leadsToUpdate.isEmpty()) {
                LeadTriggerHandler handler = new LeadTriggerHandler();
                handler.updateCountry(leadsToUpdate);
            }
        }
    }
}