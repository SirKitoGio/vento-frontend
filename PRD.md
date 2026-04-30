# VENTÖ — Flutter Frontend PRD
**Product:** Inventory POS & Warehouse Engine
**Version:** 1.0
**Stack:** Flutter Web + Go Backend (AWS EC2)
**Prepared for:** Matt, Princess, Mads, Dayer

---

## 1. Project Overview

VENTÖ is a web-based Point of Sale and inventory management dashboard. The frontend is built in Flutter Web and must deliver a fast, non-blocking experience for warehouse analysts and cashiers managing physical storage slots. It visualizes four core data structures: Queue (ingestion pipeline), Matrix (storage grid), BST (search index), and Stack (undo history).

---

## 2. Design Tokens

### 2.1 Color Palette

Define all colors in a single `AppColors` class at `lib/theme/app_colors.dart`.

| Token | Hex | Usage |
|---|---|---|
| `navyDark` | `#0F1628` | App background, sidebar deep fill |
| `navyMid` | `#1B2A4A` | Sidebar surface, panel headers (Add Inventory, Inventory History) |
| `navyLight` | `#243454` | Sidebar icon hover state, card hover |
| `gold` | `#F5C518` | Logo text, primary CTA button fill, active nav icon tint |
| `goldDark` | `#C49B0F` | Gold button pressed state |
| `white` | `#FFFFFF` | Main canvas background, input field fill, card surfaces |
| `offWhite` | `#F4F5F7` | Grid slot background (empty), list row alternating |
| `gridOccupied` | `#E8ECF4` | Grid slot background when occupied (has X) |
| `borderLight` | `#DDE1EA` | Input borders, card outlines, dividers |
| `textPrimary` | `#0F1628` | Body copy, item names, quantities |
| `textSecondary` | `#6B7A99` | Placeholder text, metadata (date, time) |
| `textOnDark` | `#FFFFFF` | Text on navy panels |
| `textMuted` | `#9DACC4` | Muted labels on dark surfaces |
| `highlightSearch` | `#F5C51833` | Grid slot highlight tint during search (gold at 20% opacity) |
| `dimOverlay` | `#FFFFFF99` | Overlay on non-matching grid slots during search |
| `errorRed` | `#E24B4A` | Connection error banner |
| `successGreen` | `#1D9E75` | Successful ingestion toast |

### 2.2 Typography

Use `Google Fonts: Inter` throughout. Define in `AppTextStyles`.

| Token | Size | Weight | Color | Usage |
|---|---|---|---|---|
| `logoText` | 22px | W700 | `gold` | "VENTÖ" wordmark |
| `sectionHeading` | 14px | W700 | `textPrimary` | "WAREHOUSE LOGISTICS", section labels |
| `panelHeading` | 13px | W600 | `textOnDark` | "Add Inventory", "Inventory History" |
| `listItemName` | 14px | W600 | `textPrimary` | Item names in list view |
| `listItemMeta` | 13px | W400 | `textSecondary` | Quantity, price, date, time |
| `inputLabel` | 12px | W400 | `textSecondary` | Placeholder text in form fields |
| `gridSlotLabel` | 10px | W500 | `textSecondary` | Slot coordinate label (optional) |
| `badgeText` | 11px | W600 | `navyDark` | Queue card badge |
| `buttonLabel` | 13px | W600 | `navyDark` | CTA button text ("Add to Inventory") |
| `errorText` | 13px | W500 | `errorRed` | Inline validation and error messages |

### 2.3 Spacing & Radius

```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

class AppRadius {
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 20.0;
  static const Radius cardRadius = Radius.circular(10.0);
  static const Radius panelRadius = Radius.circular(14.0);
  static const Radius inputRadius = Radius.circular(8.0);
  static const Radius slotRadius = Radius.circular(6.0);
}
```

---

## 3. App Architecture

### 3.1 Folder Structure

```
lib/
├── main.dart
├── theme/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_spacing.dart
│   └── app_theme.dart
├── config/
│   └── env_config.dart          # Reads API_BASE_URL from .env
├── models/
│   ├── inventory_item.dart
│   ├── grid_slot.dart
│   ├── queue_entry.dart
│   └── action_log.dart
├── services/
│   ├── inventory_service.dart   # All HTTP calls
│   └── api_client.dart          # Base client with try/catch
├── providers/
│   ├── inventory_provider.dart  # Riverpod: grid state
│   ├── queue_provider.dart      # Riverpod: pending queue
│   └── stack_provider.dart      # Riverpod: action history
├── screens/
│   └── dashboard_screen.dart    # Root layout shell
└── widgets/
    ├── sidebar/
    │   ├── app_sidebar.dart
    │   └── sidebar_icon_button.dart
    ├── topbar/
    │   ├── top_bar.dart
    │   └── search_field.dart
    ├── grid/
    │   ├── warehouse_grid.dart
    │   └── grid_slot_card.dart
    ├── sidebar_panels/
    │   ├── add_inventory_panel.dart
    │   ├── inventory_history_panel.dart
    │   └── queue_card.dart
    ├── list/
    │   ├── inventory_list_view.dart
    │   └── inventory_list_tile.dart
    └── shared/
        ├── gold_button.dart
        ├── dark_panel_header.dart
        └── error_banner.dart
```

### 3.2 State Management

Use **Riverpod** (`flutter_riverpod: ^2.x`).

| Provider | Type | Holds |
|---|---|---|
| `inventoryProvider` | `StateNotifierProvider` | `List<GridSlot>` — the full matrix state |
| `queueProvider` | `StateNotifierProvider` | `Queue<QueueEntry>` — pending ingestion items |
| `stackProvider` | `StateNotifierProvider` | `Stack<ActionLog>` — undo history |
| `searchQueryProvider` | `StateProvider<String>` | Current search string |
| `highlightedSlotProvider` | `StateProvider<String?>` | Slot ID returned from BST search |

### 3.3 Environment Configuration

```dart
// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
}
```

`.env` (never commit — add to `.gitignore`):
```
API_BASE_URL=http://localhost:8080
```

Vercel production environment variable:
```
API_BASE_URL=http://<YOUR_AWS_EC2_IP>:8080
```

---

## 4. Screen Layout

### 4.1 Root Shell — `DashboardScreen`

The root scaffold is a `Row` of three zones. No scrolling on the outer shell; scrolling is scoped inside each zone.

```
┌──────────┬────────────────────────────────────────┬──────────────────┐
│  Zone A  │               Zone B                   │     Zone C       │
│ Sidebar  │      Main Content Area                 │  Right Panels    │
│  72px    │      flex: 1                           │    260px         │
└──────────┴────────────────────────────────────────┴──────────────────┘
```

Zone B is subdivided vertically:
```
┌─────────────────────────────────────────┐
│  Top Bar (logo + search)       56px     │
├─────────────────────────────────────────┤
│  "WAREHOUSE LOGISTICS" heading  40px    │
├─────────────────────────────────────────┤
│  Warehouse Grid Matrix         flex: 2  │
├─────────────────────────────────────────┤
│  Inventory List View           flex: 1  │
└─────────────────────────────────────────┘
```

Zone C (right panel) is subdivided vertically:
```
┌──────────────────┐
│  Add Inventory   │  fixed height ~320px
│  Panel           │
├──────────────────┤
│  Inventory       │  flex: 1, scrollable
│  History Panel   │
└──────────────────┘
```

---

## 5. Widget Specifications

### 5.1 Zone A — App Sidebar

**Widget:** `AppSidebar`
**Width:** 72px
**Background:** `navyMid` (#1B2A4A)
**Layout:** `Column` — logo area at top, nav icons in center, profile at bottom

**Top section (logo icon area):**
- Height: 56px
- Contains a circular amber/globe emoji avatar or brand mark at 32px
- No text label

**Nav icon buttons** (`SidebarIconButton`):
- 4 icons stacked vertically with 8px gap
- Icon size: 24px
- Default tint: `#4A6080` (muted navy-gray)
- Active tint: `gold` (#F5C518)
- Active background: `navyLight` with `BorderRadius.circular(10)`
- Padding: 12px all sides
- Icons (in order): Home (house), Inventory/Box, Chart/Analytics, Settings (circle placeholder in Figma)

**Bottom section (Profile):**
- A `CircleAvatar` of 36px
- White border 1.5px
- "Profile" label in 10px `textMuted` below

### 5.2 Zone B — Top Bar

**Widget:** `TopBar`
**Height:** 56px
**Background:** `white`
**Bottom border:** 1px `borderLight`
**Layout:** `Row` — logo left, search bar center, stretches full width of Zone B

**Logo:**
- Text: "VENTÖ" — style `logoText` (22px, W700, gold)
- Left padding: 20px

**Search Bar** (`SearchField`):
- Width: flexible, `Expanded`
- Height: 36px
- Background: `offWhite`
- Border: 1px `borderLight`, radius 20px (pill shape)
- Left icon: search icon, 16px, `textSecondary`
- Placeholder: "Search inventory..."
- Right icon: clear (X) button — only visible when text is non-empty
- `onChanged`: dispatches to `searchQueryProvider`; debounce 300ms before HTTP call

### 5.3 Zone B — Warehouse Grid

**Widget:** `WarehouseGrid`
**Background:** `white`, border: 1px `borderLight`, radius: `AppRadius.lg`
**Padding:** 16px all sides

**Grid layout:**
- `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`
- `crossAxisCount: 10`
- `crossAxisSpacing: 6`, `mainAxisSpacing: 6`
- `childAspectRatio: 1.0` (square slots)

**Grid Slot Card** (`GridSlotCard`):
- Default (empty): background `offWhite`, border 1px `borderLight`, radius `AppRadius.slotRadius`
- Occupied: background `gridOccupied`, shows a centered `×` character in 18px, W700, `navyMid`
- Highlighted (search match): border 2px `gold`, background `highlightSearch`, scale up to 1.05 via `AnimatedContainer`
- Dimmed (non-match during search): background `dimOverlay` overlay using `ColorFiltered` or `Opacity(0.4)`
- Hover: show `GridSlotTooltip` — a `Material` card with product name, type, date, time in, quantity, price (see Figma screen 2)

**GridSlotTooltip** (on hover):
- Background: `navyMid`
- Border radius: `AppRadius.md`
- Padding: 12px
- Shows: Product Name (bold, white), Place tag (pill), Product Type, Date, Time in, Quantity, Price — all in 12px `textMuted`

### 5.4 Zone B — Inventory List View

**Widget:** `InventoryListView`
**Header row:** "Inventory List View" (left, `sectionHeading`) — "Up-to-date" (right, 12px `successGreen`)
**Columns:** Icon avatar | Item Name | Quantity | Price (₱) | Date | Time

**Inventory List Tile** (`InventoryListTile`):
- Height: 56px
- Background: `white`, border 1px `borderLight`, radius `AppRadius.md`
- Bottom margin: 8px
- Left: `CircleAvatar` 36px, `navyMid` background, category icon in white 18px
- Item name: `listItemName` style
- Quantity, price, date, time: `listItemMeta` style, evenly spaced in `Row`
- Price prefix: ₱ (Philippine Peso symbol)

### 5.5 Zone C — Add Inventory Panel

**Widget:** `AddInventoryPanel`
**Background:** `white`
**Border:** 1px `borderLight`, radius `AppRadius.panelRadius`
**Overflow:** `ClipRRect`

**Panel Header** (`DarkPanelHeader`):
- Background: `navyMid`
- Height: 40px
- Left icon: clipboard icon, 16px, white
- Title: "Add Inventory" — `panelHeading` style
- Right: clock/timer icon, 16px, `textMuted`

**Form fields** (inside white body, 12px padding):

| Field | Type | Placeholder | Width |
|---|---|---|---|
| Date | `TextFormField` | "Date..." | 50% |
| Time in | `TextFormField` | "Time in..." | 50% |
| Product Name | `TextFormField` | "Product Name..." | 100% |
| Product Type | `DropdownButtonFormField` | "Product Type..." | 100% |
| Inventory Place | `TextFormField` | "Inventory Place..." | 100% |
| Unit Price | `TextFormField` | "Unit Price..." | 50% |
| Quantity | `TextFormField` | "Quantity..." | 50% |

All fields:
- Height: 36px
- Background: `white`
- Border: 1px `borderLight`, radius `AppRadius.inputRadius`
- Font: `inputLabel` style for placeholder, `textPrimary` for value
- Keyboard type: `TextInputType.number` for price and quantity fields

**Add to Inventory Button** (`GoldButton`):
- Full width
- Height: 44px
- Background: `gold`
- Border radius: `AppRadius.md`
- Label: "Add to Inventory" — `buttonLabel` style
- Right icon: `+` in a circle outline, 18px, `navyDark`
- Pressed state: background `goldDark`, scale 0.97

### 5.6 Zone C — Inventory History Panel

**Widget:** `InventoryHistoryPanel`
**Header:** Same `DarkPanelHeader` pattern, title "Inventory History", left icon: history/list icon

**Body:**
- `ListView.builder` — scrollable, shows `ActionLog` entries
- Each entry: a rounded rect card (height 44px), `offWhite` background, border `borderLight`
- Shows product name + quantity + timestamp in `listItemMeta` style
- Most recent entry at top (stack order)
- Empty state: show 6 placeholder shimmer bars (use `shimmer` package or `AnimatedContainer` with `offWhite` pulsing opacity)

---

## 6. User Journey Interactions

### 6.1 Journey 1 — Add to Queue (Ingest)

1. User fills Product Name, Product Type, Inventory Place, Unit Price, Quantity, Date, Time in.
2. Taps **Add to Inventory** button.
3. **Optimistic UI:** Before server responds —
   - Form fields clear immediately.
   - A `QueueCard` animates into the bottom of the right panel using `AnimatedList` with a slide-in from right + fade-in.
4. After `HTTP 200`:
   - `QueueCard` animates out (slide-out + fade-out, 300ms).
   - The matching `GridSlotCard` in the matrix animates its state change: empty → occupied via `AnimatedContainer` (background color tween, 250ms).
   - A success `SnackBar` appears: "Burgers added — 500 units" in `successGreen`.
5. `InventoryListView` inserts the new tile at the top of the list using `AnimatedList`.

### 6.2 Journey 2 — Search (BST Query)

1. User types in the `SearchField`.
2. After 300ms debounce, `GET /search?q=<query>` fires.
3. While awaiting — show a subtle `CircularProgressIndicator` (14px, `gold`) inside the search bar right side.
4. On response — `highlightedSlotProvider` is updated with the matching slot ID.
5. Grid re-renders: non-matching slots dim via `Opacity(0.35)`, matching slot gets gold border + scale effect. This is driven by `Consumer` on `highlightedSlotProvider` — only affected slots rebuild.
6. Tapping the highlighted slot shows the `GridSlotTooltip`.
7. Tapping the **Clear (X)** button resets `searchQueryProvider` to empty, and all slots return to normal state.

### 6.3 Journey 3 — Undo Last Action (Stack Pop)

1. User taps **Undo Last Action** (place this as an icon button — a curved-arrow icon — in the top-right of Zone B header area, next to "WAREHOUSE LOGISTICS").
2. **Optimistic UI:** Immediately —
   - The topmost entry in `InventoryHistoryPanel` animates out (slide up + fade, 250ms).
   - The corresponding `GridSlotCard` animates back to empty state.
   - The top row of `InventoryListView` removes via `AnimatedList`.
3. `DELETE /undo` fires in background.
4. If server returns error — all optimistic changes reverse with a shake animation and an error `SnackBar`.

---

## 7. API Service Layer

### 7.1 Base Client

```dart
// lib/services/api_client.dart
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

class ApiClient {
  static final String _base = EnvConfig.apiBaseUrl;

  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$_base$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));
      return response;
    } on TimeoutException {
      throw ApiException('Connection timed out. Check the server status.');
    } on SocketException {
      throw ApiException('Cannot reach the server. Check your network.');
    }
  }

  static Future<http.Response> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$_base$path'),
      ).timeout(const Duration(seconds: 10));
      return response;
    } on TimeoutException {
      throw ApiException('Connection timed out.');
    } on SocketException {
      throw ApiException('Cannot reach the server.');
    }
  }

  static Future<http.Response> delete(String path) async {
    try {
      return await http.delete(Uri.parse('$_base$path'))
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw ApiException('Connection timed out.');
    } on SocketException {
      throw ApiException('Cannot reach the server.');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
```

### 7.2 Endpoint Map

| Action | Method | Endpoint | Payload |
|---|---|---|---|
| Add item to queue | `POST` | `/inventory` | `{ name, type, place, price, quantity, date, time }` |
| Search by name | `GET` | `/search?q=<query>` | — |
| Undo last action | `DELETE` | `/undo` | — |
| Auto-sort (BST traversal) | `GET` | `/sort` | — |
| Get all inventory | `GET` | `/inventory` | — |
| Get grid matrix state | `GET` | `/grid` | — |

---

## 8. Error Handling & Connectivity

**ErrorBanner widget:** A full-width `Container` at the top of the screen in `errorRed` with white text. Shown when `ApiException` is caught. Auto-dismisses after 5 seconds.

**No crash policy:** All HTTP calls are wrapped in try/catch. No unhandled exceptions should bubble to Flutter's error boundary. Use `Result<T>` wrapper pattern or `AsyncValue` from Riverpod.

**Loading states:**
- Grid: show `GridView` of shimmer skeleton slots on first load.
- List: show 4 shimmer skeleton tiles.
- Form button: replace label with `SizedBox(16, 16, child: CircularProgressIndicator(color: navyDark, strokeWidth: 2))` while submitting.

---

## 9. Packages & Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  http: ^1.2.1
  flutter_dotenv: ^5.1.0
  google_fonts: ^6.2.1
  shimmer: ^3.0.0
  intl: ^0.19.0              # Date/time formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 10. Security & Version Control Checklist

- `.env` is listed in `.gitignore` — no exceptions
- No IP addresses or EC2 hostnames in source code
- All sensitive config read exclusively from `EnvConfig`
- HTTP client wraps every call in try/catch with user-facing error messages
- Vercel deployment sets `API_BASE_URL` as an environment variable (not hardcoded in build)

---

## 11. Minimum Screen Width

Target: **1280px minimum** for desktop web. The three-zone layout does not collapse to mobile. For anything below 1280px, show a `LayoutBuilder`-based banner: "VENTÖ is optimised for desktop screens (1280px or wider)."

---

## 12. Team Assignment Reference

| Zone / Area | Suggested Owner |
|---|---|
| App Sidebar + Top Bar | Princess |
| Warehouse Grid + Slot Cards + Tooltip | Matt |
| Add Inventory Panel + Form Validation | Mads |
| Inventory History + Queue Animation + Undo flow | Dayer (Accommodator) |
| API Service Layer + Riverpod Providers + .env | Matt |

---

*End of VENTÖ Flutter Frontend PRD v1.0*
