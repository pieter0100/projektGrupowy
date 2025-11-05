# Strategia gałęzi (branching strategy)

## Istniejące branche

### `main`
Stabilna wersja aplikacji   
→ zawiera tylko sprawdzony, działający kod.

### `dev`
Główna gałąź rozwojowa, do której merguje się ukończone funkcje przed testami.  
→ tutaj łączą się wszystkie nowe funkcjonalności przed trafieniem do `main`.

### `docs`
Dokumentacja projektu (pliki `.md`, raporty, opisy wymagań itp.).  
→ można aktualizować niezależnie od kodu.

---

## Nowe branche

Każda nowa funkcjonalność, poprawka lub test powinny być rozwijane w osobnym branchu tworzonym z `dev`.

#### Nazewnictwo branchy
- Używaj małych liter i myślników zamiast spacji.  
- Unikaj polskich znaków i znaków specjalnych.  
- Nazwa powinna jasno wskazywać cel lub funkcję, np. `feature/add-login-form`.

### 1. Feature branches (funkcje)
- **Nazwa:** `feature/nazwa-funkcji`  
  np. `feature/login-screen`, `feature/leaderboard`, `feature/multiplication-levels`
- **Użycie:** tworzone do rozwoju nowej funkcjonalności.  
- **Po zakończeniu:** merge do `dev`.

---

### 2. Bugfix branches (poprawki błędów)
- **Nazwa:** `bugfix/opis-błędu`  
  np. `bugfix/wrong-password-message`, `bugfix/display-issue`
- **Użycie:** szybkie naprawy błędów znalezionych w `dev`.  
- **Po zakończeniu:** merge do `dev`.

---

### 3. Hotfix branches (nagłe poprawki produkcyjne)
- **Nazwa:** `hotfix/opis`  
  np. `hotfix/crash-on-start`
- **Użycie:** jeśli trzeba coś pilnie naprawić w `main`.  
- **Po zakończeniu:** merge zarówno do `main`, jak i do `dev` (żeby naprawa była też w wersji rozwojowej).

---

### 4. Docs branches (zmiany w dokumentacji)
- **Nazwa:** `docs/opis`  
  np. `docs/test-plan-update`, `docs/user-stories-update`
- **Użycie:** zmiany dokumentacyjne, które potem mergujecie do `docs` lub `dev`.

---

## Przykładowy workflow

### Tworzenie nowej funkcji
```bash
git checkout dev
git pull
git checkout -b feature/leaderboard
```

### Po zakończeniu pracy

```bash
git add .
git commit -m "Add leaderboard system"
git push origin feature/leaderboard
```

### Następnie
Tworzy się **Pull Request** → `feature/leaderboard` → `dev`

Po przetestowaniu zmian w `dev`, można zmergować gałąź do `main` przy nowym wydaniu.

### Dobre praktyki

- Przed utworzeniem nowego brancha zawsze wykonaj:
  ```bash
  git checkout dev
  git pull
  ```
  aby mieć aktualną wersję kodu.

- Każdy commit powinien mieć krótki i opisowy komunikat, np.
`"Add validation for incorrect password message"`.

- Przed zmergowaniem zmian do dev warto wykonać testy lokalne i upewnić się, że nie występują konflikty.

- Pull Requesty powinny być przeglądane (code review) przez innego członka zespołu (również kierownika), zanim zostaną zaakceptowane.

##