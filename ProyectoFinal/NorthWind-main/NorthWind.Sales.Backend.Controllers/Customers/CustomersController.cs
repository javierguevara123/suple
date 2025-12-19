using System.Security.Claims; // 👈 Necesario para leer el Token
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.CreateCustomer;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.DeleteCustomer;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.GetCustomerById;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.GetCustomers;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.Login;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Customers.UpdateCustomer;
using NorthWind.Sales.Backend.BusinessObjects.Interfaces.Repositories;
using NorthWind.Sales.Entities.Dtos.Customers.CreateCustomer;
using NorthWind.Sales.Entities.Dtos.Customers.DeleteCustomer;
using NorthWind.Sales.Entities.Dtos.Customers.GetCustomerById;
using NorthWind.Sales.Entities.Dtos.Customers.GetCustomers;
using NorthWind.Sales.Entities.Dtos.Customers.Login;
using NorthWind.Sales.Entities.Dtos.Customers.UpdateCustomer;

namespace Microsoft.AspNetCore.Builder;

public static class CustomersController
{
    public static WebApplication UseCustomersController(this WebApplication app)
    {
        // 🛡️ DEFINICIÓN DE ROLES
        const string ROLES_WRITER = "SuperUser,Administrator";
        const string ROLES_READER = "SuperUser,Administrator,Employee";
        // ✅ NUEVO: Roles permitidos para editar (Incluye Customer)
        const string ROLES_EDITOR = "SuperUser,Administrator,Customer";
        const string ROLES_READER_2 = "SuperUser,Administrator,Employee,Customer";

        // ... (Endpoints Públicos igual que antes) ...
        app.MapPost("/api/customers/register", RegisterCustomer)
            .AllowAnonymous().Produces<string>(StatusCodes.Status200OK);

        app.MapPost("/api/customers/login", LoginCustomer)
            .AllowAnonymous().Produces<LoginResponseDto>(StatusCodes.Status200OK);


        // ==========================================
        // 🔒 ENDPOINTS PROTEGIDOS
        // ==========================================

        app.MapPost(Endpoints.CreateCustomer, CreateCustomer)
             .RequireAuthorization(new AuthorizeAttribute { Roles = ROLES_WRITER })
             .Produces<string>(StatusCodes.Status200OK);

        app.MapDelete(Endpoints.DeleteCustomer, DeleteCustomer)
             .RequireAuthorization(new AuthorizeAttribute { Roles = ROLES_WRITER });

        app.MapGet("/api/customers", GetCustomers)
             .RequireAuthorization(new AuthorizeAttribute { Roles = ROLES_READER })
             .Produces<CustomerPagedResultDto>(StatusCodes.Status200OK);

        app.MapGet(Endpoints.GetCustomerById, GetCustomerById)
             .RequireAuthorization(new AuthorizeAttribute { Roles = ROLES_READER_2 });

        // ✅ UPDATE MODIFICADO:
        // 1. Usamos ROLES_EDITOR (que incluye Customer)
        app.MapPut(Endpoints.UpdateCustomer, UpdateCustomer)
            .RequireAuthorization(new AuthorizeAttribute { Roles = ROLES_EDITOR });

        app.MapGet("/api/customers/by-cedula/{cedula}", GetCustomerByCedula)
           .AllowAnonymous() // Permite consultar al registrarse
           .Produces<CustomerDetailDto>(StatusCodes.Status200OK)
           .Produces(StatusCodes.Status404NotFound);

        // Endpoint: /api/customers/by-email/juan@...
        app.MapGet("/api/customers/by-email/{email}", GetCustomerByEmail)
           .AllowAnonymous()
           .Produces<CustomerDetailDto>(StatusCodes.Status200OK)
           .Produces(StatusCodes.Status404NotFound);

        return app;
    }

    #region Handlers

    // Handler de Registro
    public static async Task<IResult> RegisterCustomer(
        CreateCustomerDto customerDto,
        ICreateCustomerInputPort inputPort,
        ICreateCustomerOutputPort presenter)
    {
        await inputPort.Handle(customerDto);
        return Results.Ok(new
        {
            message = "Cliente registrado exitosamente",
            id = presenter.CustomerId
        });
    }

    // Handler de Login
    public static async Task<IResult> LoginCustomer(
        LoginCustomerDto loginDto,
        ILoginCustomerInputPort inputPort)
    {
        try
        {
            var response = await inputPort.Handle(loginDto);
            return Results.Ok(response);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Results.Json(new { error = ex.Message }, statusCode: StatusCodes.Status401Unauthorized);
        }
        catch (Exception ex)
        {
            return Results.Problem($"Error interno: {ex.Message}");
        }
    }

    // Handler Create (Admin)
    public static async Task<IResult> CreateCustomer(
        CreateCustomerDto customerDto,
        ICreateCustomerInputPort inputPort,
        ICreateCustomerOutputPort presenter)
    {
        await inputPort.Handle(customerDto);
        return Results.Ok(new { id = presenter.CustomerId });
    }

    // Handler Get All
    private static async Task<IResult> GetCustomers(
        [AsParameters] GetCustomersQueryDto query,
        IGetCustomersInputPort inputPort,
        IGetCustomersOutputPort presenter)
    {
        await inputPort.Handle(query);
        return Results.Ok(presenter.Result);
    }

    // Handler Delete
    private static async Task DeleteCustomer(
        string id,
        IDeleteCustomerInputPort inputPort,
        IDeleteCustomerOutputPort presenter)
    {
        var dto = new DeleteCustomerDto(id);
        await inputPort.Handle(dto);
        _ = presenter.CustomerId;
    }

    // Handler Get By ID
    private static async Task<IResult> GetCustomerById(
        string id,
        IGetCustomerByIdInputPort inputPort,
        IGetCustomerByIdOutputPort presenter)
    {
        var dto = new GetCustomerByIdDto(id);
        await inputPort.Handle(dto);

        return presenter.Customer is null
            ? Results.NotFound(new { error = $"Cliente con Id {id} no encontrado" })
            : Results.Ok(presenter.Customer);
    }

    // Handler Update
    // Handler Update
    private static async Task<IResult> UpdateCustomer(
    string id,
    UpdateCustomerDto dto,
    IUpdateCustomerInputPort inputPort,
    IUpdateCustomerOutputPort presenter,
    ClaimsPrincipal user)
    {
        // 1. Validar consistencia de IDs
        if (id != dto.Id)
            return Results.BadRequest(new { error = "El Id de la URL no coincide con el cuerpo." });

        // 2. 🛡️ SEGURIDAD: Verificar identidad
        bool isAdmin = user.IsInRole("SuperUser") || user.IsInRole("Administrator");

        if (!isAdmin)
        {
            var tokenUserId = user.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            // Si el ID del token no es igual al ID que intentan editar -> 403 Forbidden
            if (tokenUserId != null && tokenUserId != id)
            {
                return Results.Forbid();
            }
        }

        // 3. 🚨 AQUÍ ESTÁ EL CAMBIO CLAVE: ENVOLVER EN TRY-CATCH
        try
        {
            // Ejecutamos la lógica de negocio (aquí es donde valida si el ID es correcto)
            await inputPort.Handle(dto);

            // Si pasa, retornamos éxito
            return Results.Ok(new
            {
                id = presenter.CustomerId,
                message = "Perfil actualizado exitosamente"
            });
        }
        // Capturamos específicamente la excepción de validación de NorthWind
        catch (NorthWind.Exceptions.Entities.Exceptions.ValidationException ex)
        {
            return Results.BadRequest(new
            {
                Status = 400,
                Title = "Error de validación",
                // Devolvemos la lista de errores para que Vue sepa qué falló (ej: "Id debe tener 5 caracteres")
                Errors = ex.Errors.Select(e => new { e.PropertyName, e.ErrorMessage })
            });
        }
        // Capturamos cualquier otro error inesperado
        catch (Exception ex)
        {
            return Results.Problem(detail: ex.Message, statusCode: 500);
        }
    }

    private static async Task<IResult> GetCustomerByCedula(
        string cedula,
        IQueriesRepository repository) // 👈 Inyección directa del repo
    {
        var customer = await repository.GetCustomerByCedula(cedula);

        return customer is null
            ? Results.NotFound() // 404: Vue sabe que está libre
            : Results.Ok(customer); // 200 + Datos: Vue sabe que ya existe y puede chequear ID
    }

    private static async Task<IResult> GetCustomerByEmail(
        string email,
        IQueriesRepository repository)
    {
        var customer = await repository.GetCustomerByEmail(email);

        return customer is null
            ? Results.NotFound()
            : Results.Ok(customer);
    }
    #endregion
}