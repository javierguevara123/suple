namespace NorthWind.Sales.Entities.Dtos.Customers.CreateCustomer
{
    public class CreateCustomerDto(
        string id,
        string name,
        decimal currentBalance,
        string email,      // Nuevo
        string cedula,     // Nuevo
        string password,
        string? profilePictureBase64,
        string? address,
    string? phone,
    DateTime? birthDate)   // Nuevo (Texto plano)
    {
        public string Id => id;
        public string Name => name;
        public decimal CurrentBalance => currentBalance;
        public string Email => email;
        public string Cedula => cedula;
        public string Password => password;
        public string? ProfilePictureBase64 => profilePictureBase64;

        public string? Address => address;
        public string? Phone => phone;
        public DateTime? BirthDate => birthDate;
    }
}