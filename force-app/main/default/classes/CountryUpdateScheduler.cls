public class CountryUpdateScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        CountryService.updateCountries();
    }
}
