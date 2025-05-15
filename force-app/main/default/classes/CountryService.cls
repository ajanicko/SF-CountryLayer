public without sharing class CountryService {
    private class Country {
        public String name;
        public String alpha2Code;
        public String alpha3Code;
        public String capital;
        public String region;
        public List<RegionalBloc> regionalBlocs;
    }

    private class RegionalBloc {
        public String acronym;
    }

    public class ResponseException extends Exception {
    }

    @future(callout=true)
    public static void updateCountries() {
        List<Country> countries = sendRequest();

        Map<String, Country> newCountriesMap = convertCountriesToMap(countries);
        Map<String, Country__c> oldCountriesMap = getExistingCountries(
            newCountriesMap.keySet()
        );

        List<Country__c> countriesToUpsert = compareCountries(
            newCountriesMap,
            oldCountriesMap
        );

        if (!countriesToUpsert.isEmpty()) {
            upsert countriesToUpsert;
        }
    }

    private static List<Country> sendRequest() {
        Http http = new Http();
        CountryLayerEndpoint__c endpointParams = CountryLayerEndpoint__c.getInstance();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            endpointParams.URL__c +
                'all?access_key=' +
                endpointParams.Access_Key__c
        );
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        if (res.getStatusCode() != 200) {
            throw new ResponseException(res.getBody());
        }

        return (List<Country>) JSON.deserialize(
            res.getBody(),
            List<Country>.class
        );
    }

    private static Map<String, Country> convertCountriesToMap(
        List<Country> countries
    ) {
        Map<String, Country> countryMap = new Map<String, Country>();

        for (Country country : countries) {
            countryMap.put(country.alpha2Code, country);
        }

        return countryMap;
    }

    private static Map<String, Country__c> getExistingCountries(
        Set<String> newCountryCodes
    ) {
        Map<String, Country__c> existingCountries = new Map<String, Country__c>();

        for (Country__c country : [
            SELECT
                Name,
                Alpha_2_Code__c,
                Alpha_3_Code__c,
                Capital__c,
                Region__c,
                Regional_Blocks__c
            FROM Country__c
            WHERE Alpha_2_Code__c IN :newCountryCodes
        ]) {
            existingCountries.put(country.Alpha_2_Code__c, country);
        }

        return existingCountries;
    }

    private static List<Country__c> compareCountries(
        Map<String, Country> newCountriesMap,
        Map<String, Country__c> oldCountriesMap
    ) {
        List<Country__c> countriesToUpsert = new List<Country__c>();

        for (String alpha2Code : newCountriesMap.keySet()) {
            Country newCountry = newCountriesMap.get(alpha2Code);
            String newCountryRegionalBlocks = concatenateRegionalBlocks(
                newCountry.regionalBlocs
            );
            Country__c existingCountry = oldCountriesMap.get(alpha2Code);

            if (existingCountry != null) {
                Boolean hasChanged =
                    existingCountry.Name != newCountry.name ||
                    existingCountry.Alpha_2_Code__c != newCountry.alpha2Code ||
                    existingCountry.Alpha_3_Code__c != newCountry.alpha3Code ||
                    existingCountry.Capital__c != newCountry.capital ||
                    existingCountry.Region__c != newCountry.region ||
                    existingCountry.Regional_Blocks__c !=
                    newCountryRegionalBlocks;

                if (hasChanged) {
                    existingCountry.Name = newCountry.name;
                    existingCountry.Alpha_2_Code__c = newCountry.alpha2Code;
                    existingCountry.Alpha_3_Code__c = newCountry.alpha3Code;
                    existingCountry.Capital__c = newCountry.capital;
                    existingCountry.Region__c = newCountry.region;
                    existingCountry.Regional_Blocks__c = newCountryRegionalBlocks;

                    countriesToUpsert.add(existingCountry);
                }
            } else {
                Country__c newCountryRecord = new Country__c(
                    Name = newCountry.name,
                    Alpha_2_Code__c = newCountry.alpha2Code,
                    Alpha_3_Code__c = newCountry.alpha3Code,
                    Capital__c = newCountry.capital,
                    Region__c = newCountry.region,
                    Regional_Blocks__c = newCountryRegionalBlocks
                );
                countriesToUpsert.add(newCountryRecord);
            }
        }
        return countriesToUpsert;
    }

    private static String concatenateRegionalBlocks(
        List<RegionalBloc> regionalBlocs
    ) {
        if (regionalBlocs == null || regionalBlocs.isEmpty()) {
            return null;
        }

        String regionalBlocks = '';
        for (RegionalBloc block : regionalBlocs) {
            regionalBlocks += block.acronym + ', ';
        }

        return regionalBlocks.removeEnd(', ');
    }
}
