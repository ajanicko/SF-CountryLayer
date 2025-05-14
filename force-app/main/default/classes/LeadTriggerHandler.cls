public with sharing class LeadTriggerHandler {
    public void updateCountry(List<Lead> leads) {
        Set<String> countryNames = new Set<String>();
        for (Lead lead : leads) {
            if (lead.Country_Name__c != null) {
                countryNames.add(lead.Country_Name__c.trim());
            }
        }

        if (!countryNames.isEmpty()) {
            List<Country__c> countries = [
                SELECT Name
                FROM Country__c
                WHERE Name IN :countryNames
            ];

            Map<String, Country__c> countryMap = new Map<String, Country__c>();
            for (Country__c country : countries) {
                countryMap.put(country.Name.toLowerCase(), country);
            }

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
}
