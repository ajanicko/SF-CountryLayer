Salesforce coding excercise
1. With API from https://countrylayer.com/ upload information to Salesforce about countries specifically we
are interested in Name, Country alpha2code and alpha3code, Capital city, region, regionalBlocs (acronyms
are sufficient).
Once a day, check if any of the information on the API has been changed and if so, update it in Salesforce.
Then create a trigger that will show the information on the leads based on their countries. Create tests for
the feature to be ready for deployment.
2. Additionally create validation rule for leads that do not allow to change owner unless Country, Lead
Source and No. of Employees are filled in.
This applies for all profiles except of System Administrator and Contract Manager profiles do not need to
fill in the No. of Employees and System Administrator profile also does not need to fill in Country.
3. Also, create a flow that will track assignments of Lead Owner. Meaning when Lead Owner is assigned
then save timestamp to the field Owner Since.
