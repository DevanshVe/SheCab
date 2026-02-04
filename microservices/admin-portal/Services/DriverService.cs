using System.Text.Json;
using admin_portal.Models;

namespace admin_portal.Services;

public class DriverService : IDriverService
{
    private readonly HttpClient _httpClient;
    private const string BaseUrl = "http://localhost:8080/api/drivers";

    public DriverService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<List<DriverViewModel>> GetPendingDrivers()
    {
        var response = await _httpClient.GetAsync($"{BaseUrl}/pending");
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        return JsonSerializer.Deserialize<List<DriverViewModel>>(content, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
    }

    public async Task VerifyDriver(long driverId)
    {
        var response = await _httpClient.PostAsync($"{BaseUrl}/{driverId}/verify", null);
        response.EnsureSuccessStatusCode();
    }
}
