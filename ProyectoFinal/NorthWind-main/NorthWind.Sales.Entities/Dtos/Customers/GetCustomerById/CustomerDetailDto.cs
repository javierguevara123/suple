namespace NorthWind.Sales.Entities.Dtos.Customers.GetCustomerById
{
    public record CustomerDetailDto(
        string Id,
        string Name,
        decimal CurrentBalance,
        string Email,      // Nuevo
        string Cedula,
        string? ProfilePictureBase64,
        string? Address,
    string? Phone,
    DateTime? BirthDate

    );
}