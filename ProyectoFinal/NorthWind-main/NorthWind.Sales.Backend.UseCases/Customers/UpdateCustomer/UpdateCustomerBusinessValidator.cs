using NorthWind.Membership.Backend.Core.Interfaces.Common; // 👈 Para validar contra usuarios del sistema
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Repositories;
using NorthWind.Sales.Backend.UseCases.Customers.CreateCustomer; // Para usar el Helper de Cedula si está ahí, o muévelo a Shared
using NorthWind.Sales.Backend.UseCases.Resources;
using NorthWind.Validation.Entities.Enums;
using NorthWind.Validation.Entities.Interfaces;
using NorthWind.Validation.Entities.ValueObjects;

namespace NorthWind.Sales.Backend.UseCases.Customers.UpdateCustomer
{
    internal class UpdateCustomerBusinessValidator(
        IQueriesRepository repository,
        IMembershipService membershipService) : IModelValidator<UpdateCustomerDto>
    {
        private readonly List<ValidationError> ErrorsField = [];

        public IEnumerable<ValidationError> Errors => ErrorsField;

        public ValidationConstraint Constraint =>
            ValidationConstraint.ValidateIfThereAreNoPreviousErrors;

        public async Task<bool> Validate(UpdateCustomerDto model)
        {
            // ================================================================
            // 1️⃣ VALIDAR EXISTENCIA (CRÍTICO EN UPDATE)
            // ================================================================

            // Primero, aseguramos que el cliente que intentamos editar exista
            var currentCustomer = await repository.GetCustomerById(model.Id);

            if (currentCustomer == null)
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Id),
                    string.Format(UpdateCustomerMessages.CustomerNotFoundTemplate, model.Id)));
                return false; // Si no existe, no tiene sentido seguir validando
            }

            // ================================================================
            // 2️⃣ VALIDACIONES DE FORMATO
            // ================================================================

            // Validar Cédula Ecuatoriana (Usando el mismo Helper que en Create)
            // Asegúrate que CedulaEcuatorianaHelper sea accesible aquí
            if (!CedulaEcuatorianaHelper.IsValid(model.Cedula))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Cedula),
                    "La cédula ingresada no es válida (Formato o dígito verificador incorrecto)."));
            }

            // Validar saldo negativo
            if (model.CurrentBalance < 0)
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.CurrentBalance),
                    UpdateCustomerMessages.CustomerBalanceCannotBeNegative));
            }

            // ================================================================
            // 3️⃣ VALIDACIONES DE DUPLICADOS (Lógica Inteligente)
            // ================================================================

            // --- VALIDAR NOMBRE ---
            // Solo verificamos si el nombre CAMBIÓ. Si es el mismo, no hacemos nada.
            if (!string.Equals(currentCustomer.Name, model.Name, StringComparison.OrdinalIgnoreCase))
            {
                if (await repository.CustomerNameExists(model.Name))
                {
                    ErrorsField.Add(new ValidationError(
                        nameof(model.Name),
                        string.Format(UpdateCustomerMessages.CustomerNameAlreadyExistsTemplate, model.Name)));
                }
            }

            // --- VALIDAR EMAIL ---
            // Solo verificamos si el email CAMBIÓ.
            if (!string.Equals(currentCustomer.Email, model.Email, StringComparison.OrdinalIgnoreCase))
            {
                // 1. Verificar si otro CLIENTE ya tiene ese email
                if (await repository.CustomerEmailExists(model.Email))
                {
                    ErrorsField.Add(new ValidationError(
                        nameof(model.Email),
                        $"El correo '{model.Email}' ya está en uso por otro Cliente."));
                }

                // 2. Verificar si un USUARIO DEL SISTEMA (Admin) tiene ese email
                if (await membershipService.ExistsUserWithEmail(model.Email))
                {
                    ErrorsField.Add(new ValidationError(
                        nameof(model.Email),
                        "Este correo ya está registrado en el sistema administrativo."));
                }
            }

            // --- VALIDAR CÉDULA ---
            // Solo verificamos si la cédula CAMBIÓ.
            if (!string.Equals(currentCustomer.Cedula, model.Cedula, StringComparison.OrdinalIgnoreCase))
            {
                // 1. Verificar si otro CLIENTE ya tiene esa cédula
                if (await repository.CustomerCedulaExists(model.Cedula))
                {
                    ErrorsField.Add(new ValidationError(
                        nameof(model.Cedula),
                        $"La cédula '{model.Cedula}' ya está registrada por otro Cliente."));
                }

                // 2. Verificar si un USUARIO DEL SISTEMA (Admin) tiene esa cédula
                if (await membershipService.ExistsUserWithCedula(model.Cedula))
                {
                    ErrorsField.Add(new ValidationError(
                        nameof(model.Cedula),
                        "Esta cédula ya está registrada en el sistema administrativo."));
                }
            }

            return !ErrorsField.Any();
        }
    }
}