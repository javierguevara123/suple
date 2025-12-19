using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using NorthWind.Sales.Backend.DataContexts.EFCore.DataContexts;
using NorthWind.Sales.Backend.Repositories.Entities;

namespace Microsoft.AspNetCore.Builder;

public static class JG_TasksController
{
    public static WebApplication UseJG_TasksController(this WebApplication app)
    {
        const string DEFAULT_USER = "JG_DefaultUser";

        // 1. GET: Trae TODAS las tareas (Pendientes Check=0 y Completadas Check=1)
        app.MapGet("/api/jg_tasks", async ([FromServices] NorthWindContext db) =>
        {
            var tasks = await db.JG_TaskEntities
                                .Where(t => t.JG_UserId == DEFAULT_USER)
                                .OrderBy(t => t.JG_Fecha) // Ordena del más viejo al más nuevo
                                .ToListAsync();
            return Results.Ok(new { items = tasks });
        });

        // 2. POST: Crear
        app.MapPost("/api/jg_tasks", async ([FromServices] NorthWindContext db, [FromBody] JG_TaskEntity task) =>
        {
            task.JG_UserId = DEFAULT_USER;
            task.JG_IsCompleted = false;
            if (task.JG_Fecha == default) task.JG_Fecha = DateTime.UtcNow;
            db.JG_TaskEntities.Add(task);
            await db.SaveChangesAsync();
            return Results.Ok(task);
        });

        // 3. PUT: Actualizar (Aquí es donde cambiamos de 0 a 1)
        app.MapPut("/api/jg_tasks/{id}", async ([FromServices] NorthWindContext db, int id, [FromBody] JG_TaskEntity input) =>
        {
            var task = await db.JG_TaskEntities.FirstOrDefaultAsync(t => t.JG_Id == id);
            if (task is null) return Results.NotFound();

            task.JG_Name = input.JG_Name;
            task.JG_Notes = input.JG_Notes;
            task.JG_Type = input.JG_Type;
            task.JG_IsCompleted = input.JG_IsCompleted;
            task.JG_Fecha = input.JG_Fecha; // Actualiza la fecha si se edita

            await db.SaveChangesAsync();
            return Results.Ok(task);
        });

        // 4. DELETE: Eliminar (Solo si usas el botón de basura para limpiar DE VERDAD)
        app.MapDelete("/api/jg_tasks/completed", async ([FromServices] NorthWindContext db) =>
        {
            var completedTasks = await db.JG_TaskEntities
                                         .Where(t => t.JG_UserId == DEFAULT_USER && t.JG_IsCompleted == true)
                                         .ToListAsync();

            db.JG_TaskEntities.RemoveRange(completedTasks);
            await db.SaveChangesAsync();
            return Results.Ok(new { deleted = completedTasks.Count });
        });

        return app;
    }
}