using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace NorthWind.Sales.Backend.DataContexts.EFCore.Migrations
{
    /// <inheritdoc />
    public partial class AddExamen : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "JG_TaskEntities",
                columns: table => new
                {
                    JG_Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JG_Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    JG_Notes = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    JG_Type = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    JG_IsCompleted = table.Column<bool>(type: "bit", nullable: false),
                    JG_UserId = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_JG_TaskEntities", x => x.JG_Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "JG_TaskEntities");
        }
    }
}
