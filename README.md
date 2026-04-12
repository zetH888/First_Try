# First_Try - System Nawigacji i Radaru 3D dla Roblox

Projekt demonstracyjny implementujący zaawansowany system nawigacyjny oraz dynamiczny radar 3D w środowisku Roblox, zintegrowany przy użyciu narzędzia **Rojo**.

## 🚀 Kluczowe Funkcje

### 1. Zaawansowany Radar 3D (Styl GTA V / Cyberpunk 2077)
- **Synchronizacja z Kamerą**: Radar obraca się płynnie wraz z ruchami kamery gracza.
- **Wizualizacja Obiektów**: 
    - Zielone punkty reprezentujące innych graczy.
    - Szare prostokąty odwzorowujące rzeczywisty kształt i orientację budynków/struktur.
- **Siatka Pomocnicza**: Subtelna siatka co 10 jednostek ułatwiająca ocenę odległości.
- **Oznaczenia Kardynalne**: Statyczne litery N, E, S, W na obwodzie radaru.
- **Perfect Clipping**: Dzięki użyciu `CanvasGroup`, wszystkie elementy są idealnie przycięte do kształtu koła.

### 2. System Współrzędnych Geograficznych
- Konwersja pozycji Roblox (X, Z) na format geograficzny (np. `15.4°N, 30.2°E`).
- Środek mapy (0,0) służy jako punkt odniesienia (równik/południk zerowy).

### 3. Optymalizacja i Wydajność
- **Object Pooling**: System reużywa markery na radarze, zamiast tworzyć nowe co klatkę.
- **Culling**: Wyświetlane są tylko obiekty w zasięgu 100 jednostek.
- **Update Rate**: Logika radarowa odświeżana co 100ms, przy zachowaniu płynności UI 60 FPS.

## ⌨️ Sterowanie
- **F1**: Ukryj / Pokaż cały system nawigacji.
- **F2**: Przełącz tryb wyświetlania punktów graczy (Radar Active/Hidden).

## 🛠 Technologia
- **Język**: Luau (dialekt Lua dla Roblox).
- **Toolchain**: Rojo (synchronizacja kodu z VS Code/Trae).
- **Zarządzanie pakietami**: Aftman.
- **Testy**: Wbudowany system testów jednostkowych dla logiki nawigacyjnej.

## 📂 Struktura Projektu
- `src/client/`: Główna implementacja UI i logiki radaru.
- `src/shared/`: Narzędzia matematyczne i konwersja współrzędnych.
- `src/server/`: Skrypty serwerowe i inicjalizacja.

## ⚙️ Instalacja i Uruchomienie
1. Zainstaluj narzędzia za pomocą Aftman:
   ```bash
   aftman install
   ```
2. Uruchom serwer Rojo:
   ```bash
   rojo serve
   ```
3. W Roblox Studio otwórz wtyczkę Rojo i kliknij **Connect**.

---
*Projekt rozwijany jako "First_Try" w celu przetestowania profesjonalnych narzędzi inżynierii oprogramowania w Roblox.*
