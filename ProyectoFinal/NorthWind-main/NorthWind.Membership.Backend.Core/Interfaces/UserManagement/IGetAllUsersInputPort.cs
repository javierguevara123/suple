namespace NorthWind.Membership.Backend.Core.Interfaces.UserManagement
{
    public interface IGetAllUsersInputPort
    {
        // ✅ CAMBIO AQUÍ: Agregamos string requestingUserRole
        Task Handle(int pageNumber, int pageSize, string requestingUserRole);
    }
}