using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NorthWind.Sales.Backend.DataContexts.EFCore.Migrations
{
    /// <inheritdoc />
    public partial class AddFecha : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "JG_Fecha",
                table: "JG_TaskEntities",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "JG_Fecha",
                table: "JG_TaskEntities");
        }
    }
}
