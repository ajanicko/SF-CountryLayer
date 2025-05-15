@isTest
public class LeadCountryTriggerHandlerTest {
    @testSetup
    static void setupData() {
        insert new List<Country__c>{
            new Country__c(Name = 'United States'),
            new Country__c(Name = 'Canada')
        };
    }

    @isTest
    static void testLeadInsert_MatchingCountry() {
        Country__c usa = [
            SELECT Id
            FROM Country__c
            WHERE Name = 'United States'
            LIMIT 1
        ];

        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'TestCo',
            Country_Name__c = 'united states'
        );
        insert lead;
        Test.stopTest();

        Lead insertedLead = [
            SELECT Country__c, Country_Name__c
            FROM Lead
            WHERE Id = :lead.Id
        ];

        System.assertEquals(
            usa.Id,
            insertedLead.Country__c,
            'Country__c should be set'
        );
        System.assertEquals(
            'United States',
            insertedLead.Country_Name__c,
            'Country_Name__c should be normalized'
        );
    }

    @isTest
    static void testLeadInsert_NonMatchingCountry() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'TestCo',
            Country_Name__c = 'Mexico'
        );
        insert lead;
        Test.stopTest();

        Lead insertedLead = [SELECT Country__c FROM Lead WHERE Id = :lead.Id];

        System.assertEquals(
            null,
            insertedLead.Country__c,
            'Country__c should not be set for unknown country'
        );
    }

    @isTest
    static void testLeadUpdate_ChangeCountryName() {
        Country__c usa = [
            SELECT Id
            FROM Country__c
            WHERE Name = 'United States'
            LIMIT 1
        ];

        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'TestCo',
            Country_Name__c = 'Canada'
        );
        insert lead;

        lead.Country_Name__c = 'United States';
        update lead;
        Test.stopTest();

        Lead updatedLead = [
            SELECT Country__c, Country_Name__c
            FROM Lead
            WHERE Id = :lead.Id
        ];

        System.assertEquals(
            usa.Id,
            updatedLead.Country__c,
            'Country__c should update to new country'
        );
        System.assertEquals(
            'United States',
            updatedLead.Country_Name__c,
            'Country_Name__c should be normalized'
        );
    }
}
