# CotizaDePrisa 

## ¿Qué es CotizaDePrisa?

CotizaDePrisa permite a emprendedores y profesionistas independientes en México:

1. **Crear cotizaciones** — documento comercial simple, sin datos fiscales.
2. **Facturar** — convertir la cotización en un CFDI 4.0 válido ante el SAT, timbrado automáticamente via Facturapi.
3. **Generar PDFs** — cotizaciones y facturas con logo de empresa, datos fiscales y UUID del timbre.

El flujo es:

```
Crear cotización → Seleccionar categoría/producto SAT → Revisar → Facturar → Timbrar → PDF
```

---

## Características principales

- **Cotizaciones** sin campos fiscales — UX limpia y rápida.
-  **Catálogo SAT dinámico** — 13 categorías, más de 60 subcategorías con clave c_ClaveProdServ asignada automáticamente.
-  **Facturación CFDI 4.0** con validación de campos requeridos por el SAT.
-  **Timbrado en un paso** via Facturapi — sin XML manual, sin criptografía en la app.
-  **PDFs profesionales** con logo de empresa, datos fiscales y UUID del timbre.
-  **Historial en tiempo real** — streams de Firestore, sin cerrar sesión para ver cambios.
-  **Modo oscuro** integrado.
-  **Autenticación** con email/contraseña y Google Sign-In.
-  **Logo de empresa** almacenado localmente (sin Firebase Storage).

---

## Tecnologías

| Tecnología | Versión | Uso |
|---|---|---|
| Flutter | 3.x | Framework principal — iOS y Android |
| Dart | 3.x | Lenguaje de programación |
| Firebase Auth | ^6.4.0 | Autenticación de usuarios |
| Cloud Firestore | ^6.3.0 | Base de datos en tiempo real |
| Facturapi REST | v2 | PAC — timbrado CFDI 4.0 |
| Provider | ^6.1.2 | Gestión de estado global |
| pdf + printing | ^3.8.2 / ^5.11.0 | Generación y visualización de PDFs |
| SharedPreferences | ^2.3.2 | Persistencia local (logo, prefs) |
| http | ^1.2.1 | Llamadas REST a Facturapi |
| url_launcher | ^6.3.0 | Abrir PDF desde URL de Facturapi |
| file_picker | ^8.1.2 | Selección de certificados CSD (.cer/.key) |
| image_picker | ^1.0.4 | Selección del logo de empresa |
| path_provider | ^2.1.3 | Directorio local del dispositivo |
| intl | ^0.20.2 | Formato de fechas, moneda y números |
| lucide_icons_flutter | ^3.1.10 | Iconos vectoriales |
| lottie | ^3.1.2 | Animaciones (pantalla de bienvenida) |
| pull_down_button | ^0.10.1 | Menús contextuales estilo iOS |
| smooth_page_indicator | ^2.0.1 | Indicador de onboarding |

---

## Estructura del proyecto

```
lib/
├── main.dart
├── firebase_options.dart
└── app/
    ├── app.dart                        # Widget raíz + tema
    ├── auth_gate.dart                  # Guarda de autenticación
    ├── config/
    │   ├── app_config.dart             # Constantes globales (API key Facturapi)
    │   └── sat_catalog.dart            # Catálogo SAT c_ClaveProdServ
    ├── models/
    │   ├── cotizacion.dart             # Modelo cotización + ConceptoCotizacion
    │   ├── factura.dart                # Modelo factura CFDI + ConceptoFactura
    │   ├── cliente.dart                # Modelo cliente (receptor)
    │   └── empresa_perfil.dart         # Modelo emisor (perfil de empresa)
    ├── services/
    │   ├── cotizacion_service.dart     # CRUD cotizaciones en Firestore
    │   ├── factura_service.dart        # CRUD facturas en Firestore
    │   ├── cliente_service.dart        # CRUD clientes en Firestore
    │   ├── empresa_perfil_service.dart # Perfil emisor en Firestore
    │   ├── facturapi_service.dart      # API REST Facturapi (timbrado)
    │   ├── logo_service.dart           # Logo local (SharedPreferences)
    │   ├── auth_service.dart           # Firebase Auth
    │   └── theme_service.dart          # Modo oscuro/claro
    ├── providers/
    │   └── app_provider.dart           # Estado global — streams Firestore
    ├── screens/
    │   ├── newInvoice.dart             # Crear/editar cotización
    │   ├── cotizacionDetalle.dart      # Detalle cotización + acciones
    │   ├── facturacionPage.dart        # Facturación CFDI + timbrado
    │   ├── historial.dart              # Cotizaciones y facturas (2 tabs)
    │   ├── pdfInvoice.dart             # PDF de cotización
    │   ├── pdfFactura.dart             # PDF de factura (con UUID)
    │   ├── selectClient.dart           # Selector de cliente
    │   ├── profile.dart                # Perfil de empresa
    │   ├── profileSettings.dart        # Configuración perfil + CSD
    │   ├── sat.dart                    # Resumen de facturas timbradas
    │   ├── homePage.dart               # Navegación principal
    │   ├── intro_screens/              # Onboarding (5 páginas)
    │   └── login_process/              # Login y Registro
    └── widgets/
        ├── product.dart                # Fila de producto (con categoría SAT)
        ├── productsBottomSheetModal.dart # Modal agregar/editar producto + dropdowns SAT
        ├── customCard.dart
        ├── customTextField.dart
        └── ...
```

---

## Instalación

### Prerrequisitos

- Flutter SDK 3.x
- Dart 3.x
- Android Studio o Xcode (para emuladores)
- Cuenta de [Firebase](https://console.firebase.google.com)
- Cuenta de [Facturapi](https://facturapi.io)

### 1. Clonar el repositorio

```bash
git clone https://github.com/[tu-usuario]/cotizadeprisa.git
cd cotizadeprisa
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com).
2. Agrega apps para Android e iOS.
3. Descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS).
4. Colócalos en sus rutas correspondientes.
5. El archivo `lib/firebase_options.dart` ya está configurado — actualízalo con `flutterfire configure` si usas un proyecto nuevo.

### 4. Habilitar en Firebase

- **Authentication**: Activa Email/Contraseña y Google Sign-In.
- **Cloud Firestore**: Crea la base de datos en modo producción.
- **Firestore Rules**: Aplica las reglas del archivo `firestore.rules`.

### 5. Configurar Facturapi

Edita `lib/app/config/app_config.dart`:

```dart
class AppConfig {
  // Reemplaza con tu API key de Facturapi
  static const String facturapiApiKey = 'sk_live_TU_API_KEY_AQUI';

  // true = producción SAT, false = sandbox Facturapi
  static const bool facturapiModoProduccion = true;
}
```

### 6. Ejecutar

```bash
flutter run
```
