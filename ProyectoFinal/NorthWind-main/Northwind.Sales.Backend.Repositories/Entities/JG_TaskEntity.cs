using System.ComponentModel.DataAnnotations; // <--- AGREGA ESTO

namespace NorthWind.Sales.Backend.Repositories.Entities;

public class JG_TaskEntity
{
    [Key] // <--- AGREGA ESTO para decirle a EF que esta es la Primary Key
    public int JG_Id { get; set; }

    public string JG_Name { get; set; } = string.Empty;
    public string JG_Notes { get; set; } = string.Empty;
    public string JG_Type { get; set; } = "Personal";
    public bool JG_IsCompleted { get; set; } = false;
    public string JG_UserId { get; set; } = string.Empty;
    public DateTime JG_Fecha { get; set; } = DateTime.UtcNow;
}