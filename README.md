# jRDC3 Client Template for B4X

A cross-platform client template for [jRDC3 Server v3.60](https://github.com/pyhoon/jrdc3-server-template) which is a modified version from the original [jRDC3 Server](https://github.com/AnywhereSoftware/B4X_Forum_Resources/tree/main/B4X/Libraries/jRDC%203%20-%20remote%20database%20connector) (Remote Database Connector version 3) created by Erel. This template provides a complete, ready-to-use foundation for building database-driven applications that work on Android, iOS, and Desktop (Windows, macOS, Linux) from a single codebase.

## Features

- **Cross-Platform**: Single codebase for B4A (Android), B4i (iOS), and B4J (Desktop)
- **Modern UI**: Built with [B4XPages](https://www.b4x.com/android/forum/threads/b4x-b4xpages-cross-platform-and-simple-framework-for-managing-multiple-pages.118901/) for consistent navigation and lifecycle management
- **Database Operations**: Complete CRUD (Create, Read, Update, Delete) for Categories and Products
- **Async Communication**: Non-blocking HTTP requests to jRDC3 server using `Wait For` / resumable subs
- **Batch Operations**: Execute multiple commands in a single request
- **Image Support**: Built-in utilities for converting images to/from byte arrays
- **Data Binding**: JSON-based form definitions using PreferencesDialog
- **Custom ListViews**: Optimized list views for displaying categories and products
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Requirements

- [B4X IDE](https://www.b4x.com/) (B4A, B4i, and/or B4J)
- B4X libraries (included in B4X installation):
  - XUI
  - XUI Views (CustomListView, B4XLoadingIndicator, PreferencesDialog)
  - B4XCollections
  - HttpUtils2 / OkHttpUtils2
  - B4XSerializator
  - iHttp / jHttp / Http (platform-specific)
- A running [jRDC3 server](https://github.com/pyhoon/jrdc3-server-template) (v3.60)

## Installation

### Option 1: Use as B4X Template (Recommended)

1. Copy the `.b4xtemplate` file from the `release` folder to your B4X templates folder:
   - **Windows**: `%APPDATA%\Anywhere Software\B4X\Templates`
   - **macOS**: `~/Library/Application Support/Anywhere Software/B4X/Templates`
   - **Linux**: `~/.config/Anywhere Software/B4X/Templates`

2. Restart B4X IDE

3. Create new project: `File` → `New` → Select "jRDC3 Client"

### Option 2: Manual Setup

1. Clone or download this repository
2. Open the desired platform project in `source/B4A`, `source/B4i`, or `source/B4J`
3. Update the server URL in `B4XMainPage.bas`:
   ```b4x
   Private Const ServerUrl As String = "http://YOUR_SERVER_IP:17178/rdc"
   ```

## Quick Start

1. **Configure jRDC3 Server**: Ensure your jRDC3 server is running with the required SQL queries/commands defined in `config.properties`:
   ```properties
   sql.SELECT_ALL_CATEGORIES=SELECT id, name FROM categories
   sql.SELECT_PRODUCT_BY_CATEGORY_ID=SELECT id, category_id, category_name, code, name, price FROM products WHERE category_id = ?
   sql.INSERT_NEW_CATEGORY=INSERT INTO categories (name) VALUES (?)
   sql.UPDATE_CATEGORY_BY_ID=UPDATE categories SET name = ? WHERE id = ?
   sql.DELETE_CATEGORY_BY_ID=DELETE FROM categories WHERE id = ?
   sql.INSERT_NEW_PRODUCT=INSERT INTO products (category_id, code, name, price) VALUES (?, ?, ?, ?)
   sql.UPDATE_PRODUCT_BY_ID=UPDATE products SET category_id = ?, code = ?, name = ?, price = ? WHERE id = ?
   sql.DELETE_PRODUCT_BY_ID=DELETE FROM products WHERE id = ?
   ```

2. **Update Server URL**: In `B4XMainPage.bas`, change the `ServerUrl` constant to point to your jRDC3 server

3. **Run**: Build and run on your target platform

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      B4XMainPage                            │
│  (Cross-platform UI logic using B4XPages)                   │
├─────────────────────────────────────────────────────────────┤
│  CustomListView → Category/Product Items                    │
│  PreferencesDialog → Add/Edit Forms (JSON-defined)          │
│  B4XLoadingIndicator → Loading states                       │
├─────────────────────────────────────────────────────────────┤
│                      RDCManager                             │
│  • ExecuteQuery   - Single SELECT queries                   │
│  • ExecuteCommand - Single INSERT/UPDATE/DELETE             │
│  • ExecuteBatch   - Multiple commands in one request        │
│  • ImageToBytes / BytesToImage - Image serialization        │
├─────────────────────────────────────────────────────────────┤
│                    HTTP Layer (HttpJob)                     │
├─────────────────────────────────────────────────────────────┤
│                      jRDC3 Server                           │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Description |
|-----------|-------------|
| **RDCManager** | Handles all communication with jRDC3 server. Supports queries, commands, and batch operations. Uses B4XSerializator for object serialization. |
| **B4XMainPage** | Main UI controller. Manages category/product views, dialogs, and user interactions. |
| **PreferencesDialog** | Dynamic forms defined in JSON (`category.json`, `product.json`). Supports text fields, dropdowns, and validation. |
| **CustomListView** | Efficient list rendering with custom layouts for categories (90dip) and products (180dip). |

## Project Structure

```
jrdc3-client-template/
├── release/
│   └── jRDC3 Client (3.60).b4xtemplate   # B4X template file
├── source/
│   ├── Shared Files/                      # Shared across all platforms
│   │   ├── RDCManager.bas                # Server communication class
│   │   ├── B4XMainPage.bas               # Main UI logic (B4XPages)
│   │   ├── category.json                 # Category form definition
│   │   ├── product.json                  # Product form definition
│   │   ├── icon.png                      # App icon
│   │   ├── category.json                 # Category form JSON
│   │   └── product.json                  # Product form JSON
│   ├── B4A/                              # Android project
│   ├── B4i/                              # iOS project
│   └── B4J/                              # Desktop (Java) project
└── LICENSE                               # CC0 1.0 Universal
```

## Usage Examples

### Execute a Query
```b4x
Wait For (rdc.ExecuteQuery("SELECT_ALL_CATEGORIES", Null)) Complete (Result As RDCResult)
If Result.Success Then
    For Each row() As Object In Result.Data.IterateRows
        Log($"Category: ${row(1)} (ID: ${row(0)})"$)
    Next
Else
    Log("Error: " & Result.ErrorMessage)
End If
```

### Execute a Command
```b4x
Wait For (rdc.ExecuteCommand("INSERT_NEW_CATEGORY", Array("Electronics"))) Complete (Result As RDCResult)
If Result.Success Then
    Log("Category created!")
End If
```

### Execute Batch
```b4x
Dim commands As List = Array(
    rdc.CreateRDCCommand("INSERT_NEW_CATEGORY", Array("Cat 1")),
    rdc.CreateRDCCommand("INSERT_NEW_CATEGORY", Array("Cat 2"))
)
Wait For (rdc.ExecuteBatch(commands)) Complete (Result As RDCResult)
```

### Image Handling
```b4x
' Convert image to bytes for storage
Dim imgBytes() As Byte = rdc.ImageToBytes(myImage)

' Convert bytes back to image
Dim img As B4XBitmap = rdc.BytesToImage(imgBytes)
```

## Customization

### Adding New Entities
1. Add SQL queries/commands to jRDC3 server `config.properties`
2. Create a new JSON form definition in `Shared Files/`
3. Add layout file (`.bjl`, `.bal`, `.bil`) for list items
4. Extend `B4XMainPage` with new methods for CRUD operations

### Modifying Forms
Edit `category.json` and `product.json` to change form fields:
```json
{
    "Version": 1.1,
    "Theme": "Light Theme",
    "Items": [
        {"title": "Name", "type": "Text", "key": "Category Name", "required": true},
        {"title": "Description", "type": "MultilineText", "key": "Description", "required": false}
    ]
}
```

Supported field types: `Text`, `MultilineText`, `Numbers`, `Options`, `Date`, `Time`, `Switch`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under **CC0 1.0 Universal** (Public Domain Dedication) - see the [LICENSE](LICENSE) file for details.

This means you can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

## Resources

- [B4X Forum - jRDC3](https://www.b4x.com/android/forum/threads/b4x-jrdc-3-remote-database-connector.171345/)
- [B4XPages Documentation](https://www.b4x.com/android/forum/threads/b4x-b4xpages-cross-platform-and-simple-framework-for-managing-multiple-pages.118901/)
- [B4XPreferencesDialog](https://www.b4x.com/android/forum/threads/b4xpreferencesdialog-cross-platform-forms.103842/)
- [jRDC3 GitHub](https://github.com/AnywhereSoftware/B4X_Forum_Resources/tree/main/B4X/Libraries/jRDC%203%20-%20remote%20database%20connector)
- [B4X Homepage](https://www.b4x.com/)

*Generated by Nemotron 3 Ultra Free using OpenCode Desktop v1.17.11*
