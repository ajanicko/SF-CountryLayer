trigger LeadTrigger on Lead(before insert, before update) {
    LeadCountryTriggerHandler countryHandler = new LeadCountryTriggerHandler();

    if (Trigger.isBefore) {
        if (Trigger.isInsert)
            countryHandler.beforeInsert(Trigger.new);
        if (Trigger.isUpdate)
            countryHandler.beforeUpdate(Trigger.new, Trigger.old);
    }
}
