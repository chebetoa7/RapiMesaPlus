using System.Collections.ObjectModel;

namespace RapiMesaApp.Views;

public partial class MenuCategoriesPage : ContentPage
{
    // Datos de prueba (Fase A y B)
    public ObservableCollection<CategoryMock> Categories { get; set; }

	public MenuCategoriesPage()
	{
		InitializeComponent();

        Categories = new ObservableCollection<CategoryMock>
        {
            new CategoryMock { Name = "Pizza", ItemsCount = 12, ImageUrl = "https://cdn-icons-png.flaticon.com/512/3595/3595458.png" },
            new CategoryMock { Name = "Ensaladas", ItemsCount = 8, ImageUrl = "https://cdn-icons-png.flaticon.com/512/3716/3716694.png" },
            new CategoryMock { Name = "Postres", ItemsCount = 15, ImageUrl = "https://cdn-icons-png.flaticon.com/512/3081/3081162.png" },
            new CategoryMock { Name = "Pastas", ItemsCount = 10, ImageUrl = "https://cdn-icons-png.flaticon.com/512/2619/2619565.png" },
            new CategoryMock { Name = "Bebidas", ItemsCount = 20, ImageUrl = "https://cdn-icons-png.flaticon.com/512/3183/3183063.png" }
        };

        BindingContext = this;
	}

    private async void OnCategoryTapped(object sender, EventArgs e)
    {
        // Obtener el frame que fue tapeado y extraer la categoría
        var frame = sender as Frame;
        var category = frame?.GestureRecognizers.OfType<TapGestureRecognizer>().FirstOrDefault()?.CommandParameter as CategoryMock;

        if (category != null)
        {
            await DisplayAlert("Navegación", $"Abriendo menú de {category.Name}...", "OK");
            // TODO: Navegar a MenuItemsPage pasando la categoría seleccionada
        }
    }
}

public class CategoryMock
{
    public string Name { get; set; }
    public int ItemsCount { get; set; }
    public string ImageUrl { get; set; }
}
