using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using Microsoft.Maui.ApplicationModel;

namespace RapiMesaApp.ViewModels;

public class LoginViewModel : INotifyPropertyChanged
{
    private string _restaurante = string.Empty;
    private string _usuario = string.Empty;
    private string _password = string.Empty;

    public string Restaurante
    {
        get => _restaurante;
        set => SetProperty(ref _restaurante, value);
    }

    public string Usuario
    {
        get => _usuario;
        set => SetProperty(ref _usuario, value);
    }

    public string Password
    {
        get => _password;
        set => SetProperty(ref _password, value);
    }

    public string AppVersion => $"Versión {AppInfo.Current.VersionString}";

    public ICommand LoginCommand { get; }
    public ICommand RegisterCommand { get; }

    public LoginViewModel()
    {
        LoginCommand = new Command(OnLogin);
        RegisterCommand = new Command(OnRegister);
    }

    private async void OnLogin()
    {
        if (string.IsNullOrWhiteSpace(Restaurante) || string.IsNullOrWhiteSpace(Usuario) || string.IsNullOrWhiteSpace(Password))
        {
            if (Shell.Current != null)
            {
                // Manejo de la alerta evitando el método obsoleto en .NET 9+
                await Shell.Current.DisplayAlert("Error", "Por favor, completa todos los campos.", "OK");
            }
            return;
        }

        if (Shell.Current != null)
        {
            await Shell.Current.DisplayAlert("Login", $"Iniciando turno para {Usuario} en {Restaurante}...", "OK");
            
            // Navegamos a la pantalla del menú usando el enrutador de MAUI
            await Shell.Current.GoToAsync(nameof(Views.MenuCategoriesPage));
        }
    }

    private async void OnRegister()
    {
        if (Shell.Current != null)
        {
            await Shell.Current.DisplayAlert("Registro", "Aquí abriremos la pantalla de registro para el restaurante o administrador.", "OK");
        }
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    protected bool SetProperty<T>(ref T backingStore, T value, [CallerMemberName] string? propertyName = null)
    {
        if (EqualityComparer<T>.Default.Equals(backingStore, value))
            return false;

        backingStore = value;
        OnPropertyChanged(propertyName);
        return true;
    }
}
