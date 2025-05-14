@isTest
private class CountryServiceTest {
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '[{"name":"CountryA","alpha2Code":"AA","alpha3Code":"AAA","capital":"CapitalA","region":"RegionA","regionalBlocs":[{"acronym":"RB1"},{"acronym":"RB2"}]},' +
                '{"name":"CountryB","alpha2Code":"BB","alpha3Code":"BBB","capital":"CapitalB","region":"RegionB"}]'
            );
            return res;
        }
    }

    private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');
            return res;
        }
    }

    @IsTest
    static void testUpdateCountries_Insert() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        new CountryService().updateCountries();
        Test.stopTest();

        List<Country__c> countries = [SELECT Name, Alpha_2_Code__c, Alpha_3_Code__c, Capital__c, Region__c, Regional_Blocks__c FROM Country__c ORDER BY Alpha_2_Code__c];
        System.assertEquals(2, countries.size());
        System.assertEquals('CountryA', countries[0].Name);
        System.assertEquals('CountryB', countries[1].Name);
    }

    @IsTest
    static void testUpdateCountries_Update() {
        // Insert an existing country with different values
        insert new Country__c(
            Name = 'CountryA',
            Alpha_2_Code__c = 'AA',
            Alpha_3_Code__c = 'AAA',
            Capital__c = 'CapitalA',
            Region__c = 'RegionA',
            Regional_Blocks__c = 'TEST1, TEST2'
        );
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        new CountryService().updateCountries();
        Test.stopTest();

        Country__c updated = [SELECT Name, Alpha_3_Code__c, Capital__c, Region__c, Regional_Blocks__c FROM Country__c WHERE Alpha_2_Code__c = 'AA' LIMIT 1];
        System.assertEquals('CountryA', updated.Name);
        System.assertEquals('AAA', updated.Alpha_3_Code__c);
        System.assertEquals('CapitalA', updated.Capital__c);
        System.assertEquals('RegionA', updated.Region__c);
        System.assertEquals('RB1, RB2', updated.Regional_Blocks__c);
    }

    @IsTest
    static void testUpdateCountries_HttpError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        Boolean exceptionThrown = false;
        try {
            new CountryService().updateCountries();
        } catch (CountryService.ResponseException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Exception should be thrown on HTTP error');
    }
}
