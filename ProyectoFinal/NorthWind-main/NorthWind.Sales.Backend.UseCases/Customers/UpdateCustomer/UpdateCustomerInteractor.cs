using NorthWind.DomainLogs.Entities.Interfaces;
using NorthWind.DomainLogs.Entities.ValueObjects;
using NorthWind.Entities.Guards;
using NorthWind.Entities.Interfaces;
using NorthWind.Sales.Backend.BusinessObjects.Entities;
using NorthWind.Sales.Backend.BusinessObjects.Guards;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Repositories;
using NorthWind.Sales.Backend.UseCases.Resources;
using NorthWind.Transactions.Entities.Interfaces;
using NorthWind.Validation.Entities.Interfaces;
using System.Text;
using System.Security.Cryptography;

namespace NorthWind.Sales.Backend.UseCases.Customers.UpdateCustomer
{
    internal class UpdateCustomerInteractor(
        IUpdateCustomerOutputPort outputPort,
        ICommandsRepository commandsRepository, // Asegúrate de usar el repo de comandos
        IModelValidatorHub<UpdateCustomerDto> modelValidatorHub,
        IDomainLogger domainLogger,
        IDomainTransaction domainTransaction,
        IUserService userService) : IUpdateCustomerInputPort
    {
        public async Task Handle(UpdateCustomerDto dto)
        {
            GuardUser.AgainstUnauthenticated(userService);
            await GuardModel.AgainstNotValid(modelValidatorHub, dto);

            await domainLogger.LogInformation(new DomainLog(
                UpdateCustomerMessages.StartingCustomerUpdate, userService.UserName));

            // ---------------------------------------------------------
            // 📸 1. Lógica de FOTO (Base64 -> Bytes)
            // ---------------------------------------------------------
            byte[]? imageBytes = null;
            if (!string.IsNullOrWhiteSpace(dto.ProfilePictureBase64))
            {
                try
                {
                    // Limpieza del encabezado data:image/...
                    var base64Clean = dto.ProfilePictureBase64.Contains(",")
                        ? dto.ProfilePictureBase64.Split(',')[1]
                        : dto.ProfilePictureBase64;
                    imageBytes = Convert.FromBase64String(base64Clean);
                }
                catch { imageBytes = null; }
            }

            // ---------------------------------------------------------
            // 🔑 2. Lógica de PASSWORD (Hash si es nuevo, NULL si no)
            // ---------------------------------------------------------
            string? hashedPassword = null; // 👈 IMPORTANTE: Iniciar en NULL

            // Solo hasheamos si el usuario escribió algo en el campo "Nueva Contraseña"
            if (!string.IsNullOrWhiteSpace(dto.Password))
            {
                hashedPassword = HashPassword(dto.Password);
            }

            // ---------------------------------------------------------
            // 3. Crear Entidad con los cambios
            // ---------------------------------------------------------
            var customer = new Customer
            {
                Id = dto.Id,
                Name = dto.Name,
                Cedula = dto.Cedula,
                Email = dto.Email,
                CurrentBalance = dto.CurrentBalance,
                ProfilePicture = imageBytes,
                HashedPassword = hashedPassword,
                Address = dto.Address,
                Phone = dto.Phone,
                BirthDate = dto.BirthDate
            };

            try
            {
                domainTransaction.BeginTransaction();

                // 4. Llamada al Repositorio (Ver el paso 2 abajo)
                await commandsRepository.UpdateCustomer(customer);

                await commandsRepository.SaveChanges();

                await domainLogger.LogInformation(new DomainLog(
                    string.Format(UpdateCustomerMessages.CustomerUpdatedTemplate, customer.Id),
                    userService.UserName));

                await outputPort.Handle(customer);
                domainTransaction.CommitTransaction();
            }
            catch
            {
                domainTransaction.RollbackTransaction();
                // ... log de error ...
                throw;
            }
        }

        private string HashPassword(string password)
        {
            using var sha256 = SHA256.Create();
            var bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
    }
}