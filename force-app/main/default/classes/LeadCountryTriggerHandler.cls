public without sharing class LeadCountryTriggerHandler {
    private Boolean isHandlerEnabled;

    public LeadCountryTriggerHandler() {
        if (Test.isRunningTest()) {
            this.isHandlerEnabled = true;
            return;
        }

        if (this.isHandlerEnabled == null) {
            List<Trigger_Handler_Config__mdt> configs = [
                SELECT Is_Enabled__c
                FROM Trigger_Handler_Config__mdt
                WHERE Handler_Name__c = 'LeadCountryTriggerHandler'
                LIMIT 1
            ];
            this.isHandlerEnabled = configs.isEmpty()
                ? true
                : configs[0].Is_Enabled__c;
        }
    }

    public void beforeInsert(SObject[] newRecords) {
        if (!this.isHandlerEnabled) {
            return;
        }

        updateCountry((List<Lead>) newRecords);
    }

    public void beforeUpdate(SObject[] newRecords, SObject[] oldRecords) {
        if (!this.isHandlerEnabled) {
            return;
        }

        List<Lead> leadsToUpdate = new List<Lead>();
        for (Integer i = 0; i < newRecords.size(); i++) {
            Lead newLead = (Lead) newRecords[i];
            Lead oldLead = (Lead) oldRecords[i];
            if (newLead.Country_Name__c != oldLead.Country_Name__c) {
                leadsToUpdate.add(newLead);
            }
        }
        if (!leadsToUpdate.isEmpty()) {
            updateCountry(leadsToUpdate);
        }
    }

    private void updateCountry(List<Lead> leads) {
        Set<String> countryNames = extractCountryNames(leads);
        if (countryNames.isEmpty()) {
            return;
        }

        Map<String, Country__c> countryMap = fetchCountryMap(countryNames);

        updateLeadsWithCountry(leads, countryMap);
    }

    private Set<String> extractCountryNames(List<Lead> leads) {
        Set<String> countryNames = new Set<String>();

        for (Lead lead : leads) {
            if (lead.Country_Name__c != null) {
                countryNames.add(lead.Country_Name__c.trim());
            }
        }

        return countryNames;
    }

    private Map<String, Country__c> fetchCountryMap(Set<String> countryNames) {
        List<Country__c> countries = [
            SELECT Name
            FROM Country__c
            WHERE Name IN :countryNames
        ];
        Map<String, Country__c> countryMap = new Map<String, Country__c>();

        for (Country__c country : countries) {
            countryMap.put(country.Name.toLowerCase(), country);
        }

        return countryMap;
    }

    private void updateLeadsWithCountry(
        List<Lead> leads,
        Map<String, Country__c> countryMap
    ) {
        for (Lead lead : leads) {
            if (lead.Country_Name__c != null) {
                String countryName = lead.Country_Name__c.toLowerCase();
                if (countryMap.containsKey(countryName)) {
                    Country__c country = countryMap.get(countryName);
                    lead.Country__c = country.Id;
                    lead.Country_Name__c = country.Name;
                }
            }
        }
    }
}
