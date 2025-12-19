using NorthWind.Membership.Backend.Core.Interfaces.Common; // 👈 Importante: Interfaz del servicio de usuarios
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Repositories;
using NorthWind.Sales.Backend.UseCases.Resources;
using NorthWind.Validation.Entities.Enums;
using NorthWind.Validation.Entities.Interfaces;
using NorthWind.Validation.Entities.ValueObjects;
using System.Text.RegularExpressions;

namespace NorthWind.Sales.Backend.UseCases.Customers.CreateCustomer
{
    internal class CreateCustomerBusinessValidator(
        IQueriesRepository repository,       // Para validar tabla Customers
        IMembershipService membershipService // 👈 Para validar tabla AspNetUsers
        ) : IModelValidator<CreateCustomerDto>
    {
        private readonly List<ValidationError> ErrorsField = [];

        public IEnumerable<ValidationError> Errors => ErrorsField;

        public ValidationConstraint Constraint =>
            ValidationConstraint.ValidateIfThereAreNoPreviousErrors;

        public async Task<bool> Validate(CreateCustomerDto model)
        {
            // ================================================================
            // 1️⃣ VALIDACIONES FORMATO Y REGLAS BÁSICAS
            // ================================================================

            // Validar Algoritmo de Cédula Ecuatoriana
            if (!CedulaEcuatorianaHelper.IsValid(model.Cedula))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Cedula),
                    "La cédula ingresada no es válida (Formato o dígito verificador incorrecto)."));
            }

            // Validar longitud del ID
            if (model.Id.Length > 10) // Ajustado a 5 (estándar Northwind), cámbialo a 10 si tu BD lo permite
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Id),
                    "El código de cliente debe tener máximo 10 caracteres."));
            }

            // Validar saldo negativo
            if (model.CurrentBalance < 0)
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.CurrentBalance),
                    CreateCustomerMessages.NegativeBalanceError));
            }

            // ================================================================
            // 2️⃣ VALIDACIONES CONTRA TABLA DE CLIENTES (SALES DB)
            // ================================================================

            // ID Repetido en Clientes
            if (await repository.CustomerIdExists(model.Id))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Id),
                    $"El ID '{model.Id}' ya está en uso por otro cliente."));
            }

            // Nombre Repetido en Clientes
            if (await repository.CustomerNameExists(model.Name))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Name),
                    string.Format(CreateCustomerMessages.CustomerAlreadyExistsTemplate, model.Name)));
            }

            // Email Repetido en Clientes
            if (await repository.CustomerEmailExists(model.Email))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Email),
                    $"El correo '{model.Email}' ya está registrado como Cliente."));
            }

            // Cédula Repetida en Clientes
            if (await repository.CustomerCedulaExists(model.Cedula))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Cedula),
                    $"La cédula '{model.Cedula}' ya está registrada como Cliente."));
            }

            // ================================================================
            // 3️⃣ VALIDACIONES CONTRA TABLA DE USUARIOS DEL SISTEMA (IDENTITY DB)
            // ================================================================

            // Email ya usado por un Administrador o Empleado
            if (await membershipService.ExistsUserWithEmail(model.Email))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Email),
                    "Este correo ya está en uso por un usuario del sistema (Admin/Empleado)."));
            }

            // Cédula ya usada por un Administrador o Empleado
            if (await membershipService.ExistsUserWithCedula(model.Cedula))
            {
                ErrorsField.Add(new ValidationError(
                    nameof(model.Cedula),
                    "Esta cédula ya está asociada a un usuario del sistema (Admin/Empleado)."));
            }

            // Retorna TRUE si la lista de errores está vacía (Todo correcto)
            return !ErrorsField.Any();
        }
    }

    // 👇 Clase auxiliar para validar la cédula
    public static class CedulaEcuatorianaHelper
    {
        public static bool IsValid(string cedula)
        {
            if (string.IsNullOrWhiteSpace(cedula)) return false;

            // Debe tener exactamente 10 dígitos
            if (!Regex.IsMatch(cedula, @"^\d{10}$")) return false;

            // Los dos primeros dígitos deben estar entre 01 y 24 (provincias)
            if (!int.TryParse(cedula.Substring(0, 2), out int provincia)) return false;
            if (provincia < 1 || provincia > 24) return false;

            // El tercer dígito debe ser menor a 6 para personas naturales
            if (!int.TryParse(cedula.Substring(2, 1), out int tercerDigito)) return false;
            if (tercerDigito >= 6) return false;

            // Algoritmo de validación módulo 10
            int[] coeficientes = { 2, 1, 2, 1, 2, 1, 2, 1, 2 };
            int suma = 0;

            for (int i = 0; i < 9; i++)
            {
                int digito = int.Parse(cedula[i].ToString());
                int resultado = digito * coeficientes[i];

                if (resultado >= 10)
                    resultado -= 9;

                suma += resultado;
            }

            int digitoVerificador = int.Parse(cedula[9].ToString());
            int residuo = suma % 10;
            int valorEsperado = residuo == 0 ? 0 : 10 - residuo;

            return digitoVerificador == valorEsperado;
        }
    }
}