using NorthWind.Membership.Backend.Core.Interfaces.Common;
using NorthWind.Membership.Backend.Core.Interfaces.UserManagement;

namespace NorthWind.Membership.Backend.Core.UseCases.UserManagement
{
    internal class GetAllUsersInteractor(
        IMembershipService membershipService,
        IGetAllUsersOutputPort presenter) : IGetAllUsersInputPort
    {
        // ✅ CAMBIO AQUÍ: Implementamos la nueva firma con requestingUserRole
        public async Task Handle(int pageNumber, int pageSize, string requestingUserRole)
        {
            // Pasamos el rol al servicio
            var pagedUsers = await membershipService.GetAllUsers(pageNumber, pageSize, requestingUserRole);

            await presenter.Handle(pagedUsers);
        }
    }
}