# Aplikacja dla dzieci do nauki tabliczki mnożenia - slajd 1

## Autorzy - slajd 2

### Zespół projektowy:

- Marta Kociszewska

- Lidia Zawrzykraj

- Piotr Kierznowski

- Weronika Kankowska

### Opiekun projektu:

- dr inż. Barbara Stawarz - Graczyk

## Cel projektu - slajd 3 i 4

### Innowacyjna edukacja poprzez grywalizację

- zaprojektowanie i zaimplementowanie mobilnej aplikacji edukacyjnej, która wspomaga naukę tabliczki mnożenia u dzieci

- wykorzystanie mechanizmów grywalizacji, takich jak tryby praktyki, sesje egzaminacyjne oraz system odblokowywania kolejnych poziomów trudności

- stworzenie interaktywnego środowiska motywującego do systematycznej nauki

### Rozwój kompetencji inżynierskich i zespołowych

- zdobycie praktycznych umiejętności w zakresie projektowania, implementacji i dokumentacji aplikacji mobilnych

- rozwijanie umiejętności pracy zespołowej, zarządzania projektem oraz efektywnej komunikacji w grupie

- doskonalenie kompetencji technicznych związanych z wykorzystaniem nowoczesnych technologii, takich jak Flutter i Firebase

- nauka profesjonalnych praktyk programistycznych, w tym zarządzania wersjami kodu za pomocą Git i GitHub

## Organizacja pracy i komunikacja - slajd 5 i 6

### Nadzór merytoryczny

- comiesięczne spotkania z opiekunem projektu w celu :
  
  - weryfikacji postępów, 
  
  - uzyskania wskazówek,
  
  - omówienia kluczowych decyzji
  
  - rozwiązywania problemów
  
  - dostosowania planu pracy

### Współpraca wewnątrz zespołu

- systematyczne spotkania zespołowe, na żywo lub online

- dynamiczne rozdzielanie zadań w zależności od aktualnych potrzeb i umiejętności członków zespołu

- synchronizacja wizji projektu i rozwiązywanie problemów technicznych

- kultura feedbacku i otwartej komunikacji - regularne dzielenie się postępami i wyzwaniami, wspólne poszukiwanie rozwiązań

## Wersjonowanie i współpraca zespołowa - slajd 7

- realizacja projektu z wykorzystaniem systemu kontroli wersji Git oraz platformy GitHub

- tworzenie oddzielnych gałęzi (branchy) dla nowych funkcjonalności i poprawek, co umożliwia równoległą pracę nad różnymi aspektami aplikacji

## Organizacja pracy zespołowej - slajd 8

- każdy etap projektu jest planowany i dokumentowany w dedykowanych issue na GitHubie

- stworzone zostały labele (etykiety) do kategoryzacji zadań według ich rodzaju i priorytetu

- przypisywanie issue do konkretnych członków zespołu, co ułatwia śledzenie odpowiedzialności i postępów prac

- regularne aktualizacje statusu issue, co pozwala na bieżąco monitorować realizację zadań i identyfikować ewentualne blokady

## Proces wprowadzania zmian - slajd 9

- każda zmiana w kodzie jest wprowadzana poprzez pull requesty

- pull requesty są przeglądane i zatwierdzane przez innych członków zespołu przed scaleniem z główną gałęzią

- umożliwia to wczesne wykrywanie błędów, zapewnia zgodność z ustalonymi standardami kodowania oraz promuje współpracę i wymianę wiedzy w zespole

- w razie błędów lub konfliktów, project manager koordynuje ich rozwiązanie, zapewniając płynny przebieg prac nad projektem

- dyskusje dotyczące pull requestów odbywają się na platformie GitHub, co umożliwia dokumentowanie decyzji i ułatwia śledzenie historii zmian

## Tech stack - slajd 10

- wykorzystane technologie z podziałem na frontend i backend:
  
Frontend:​

- Flutter ​

- Dart​

Backend:​

- Firebase​

## Wybór technologii - slajd 11

- Architektura "Everything is a Widget"​ 
  
  - architektura Fluttera oparta na komponentach zwanych widgetami, które definiują wygląd i zachowanie interfejsu użytkownika
  
  - umożliwia tworzenie złożonych interfejsów poprzez łączenie prostszych elementów
  
  - ułatwia ponowne wykorzystanie kodu i modularność aplikacji​

- Cross-platformowość
  
    - Flutter umożliwia tworzenie aplikacji mobilnych działających na różnych platformach, takich jak Android i iOS, z jednego kodu źródłowego

- Hot Reload​

    - funkcja Fluttera pozwalająca na natychmiastowe wprowadzanie zmian w kodzie i ich szybkie podglądanie w aplikacji bez konieczności ponownego uruchamiania całego projektu

- Backend as a Service​

    - Firebase oferuje gotowe rozwiązania backendowe, takie jak bazy danych, uwierzytelnianie użytkowników i hosting
    
    - przyspiesza rozwój aplikacji 
    
    - redukuje potrzebę zarządzania infrastrukturą serwerową

- Firestore – realtime database​

    - baza danych NoSQL oferująca synchronizację danych w czasie rzeczywistym między klientami a serwerem
    
    - umożliwia tworzenie dynamicznych aplikacji z aktualizacjami danych na żywo

## Od projektu w Figma do aplikacji - slajd 12 i 13

- w pierwszej fazie projektu zaprojektowano interfejs użytkownika aplikacji w Figma
  
  - uwzględniono potrzeby i preferencje docelowej grupy użytkowników, czyli dzieci uczących się tabliczki mnożenia

- Figma jako narzędzie do projektowania interfejsu użytkownika
  
  - umożliwia tworzenie prototypów i wizualizacji aplikacji przed rozpoczęciem implementacji
  
  - ułatwia współpracę zespołową poprzez możliwość komentowania i udostępniania projektów
  
- Integracja projektu z implementacją
  
  - przeniesienie zaprojektowanych elementów interfejsu z Figmy do kodu Fluttera
  
  - zapewnienie spójności wizualnej i funkcjonalnej między projektem a finalną aplikacją

- Proces implementacji
  
  - podział pracy na moduły odpowiadające poszczególnym ekranom i funkcjonalnościom aplikacji
  
  - iteracyjne testowanie i dostosowywanie interfejsu w trakcie implementacji, aby zapewnić intuicyjność i atrakcyjność dla użytkowników końcowych

## Architektura aplikacji - slajd 14

- architektura zdarzeniowa

  - aplikacja reaguje na zdarzenia generowane przez użytkownika lub system, co pozwala na dynamiczne i responsywne działanie
  
  - ułatwia zarządzanie stanem aplikacji i przepływem danych

- Baas (Backend as a Service)

  - wykorzystanie Firebase jako gotowego rozwiązania backendowego, co przyspiesza rozwój aplikacji i redukuje potrzebę zarządzania infrastrukturą serwerową

- Real-time data flow

  - synchronizacja danych w czasie rzeczywistym między klientami a serwerem

- Warstwa bezpieczeństwa

  - implementacja mechanizmów uwierzytelniania i autoryzacji użytkowników
  
  - zabezpieczenie danych przechowywanych w bazie Firestore poprzez reguły bezpieczeństwa danych

## Backend i zarządzanie danymi - slajd 15
- struktura cloud Firestore

  - kolekcje i dokumenty przechowujące dane użytkowników, wyniki nauki oraz postępy w aplikacji

- cloud functions

  - funkcje serwerowe obsługujące logikę biznesową, takie jak obliczanie wyników, zarządzanie poziomami trudności i nagrodami

- uwierzytelnianie użytkowników (firebase authentication)

  - mechanizmy rejestracji, logowania i zarządzania sesjami użytkowników
  
  - zapewnienie bezpieczeństwa danych osobowych i dostępu do aplikacji
  
- automatyzacja statystyk

  - zbieranie i analiza danych dotyczących postępów użytkowników w nauce tabliczki mnożenia
  
## Synchronizacja danych - slajd 16

- mechanizmy synchronizacji danych między urządzeniem użytkownika a bazą Firestore wymagają połączenia z internetem

- zaimplementowano funkcjonalność trybu offline, umożliwiającą kontynuację nauki bez dostępu do sieci

- lokalny storage

  - przechowywanie danych tymczasowych na urządzeniu użytkownika podczas braku połączenia z internetem
  
  - umożliwia dostęp do ostatnio pobranych danych i kontynuację nauki

  - aplikacja działa w trybie offline

- kolejka synchronizacji

  - po przywróceniu połączenia z internetem, dane zgromadzone w lokalnym storage są automatycznie synchronizowane z bazą Firestore
  
  - kolejka persystowana - przetrwa zamknięcie aplikacji i ponowne uruchomienie urządzenia

- wyzwalacze i proces synchronizacji

  - synchronizacja okresowa (co 15 minut) lub po zdarzeniowa (po wykryciu połączenia z internetem)

  - automatyczne rozwiązywanie konfliktów danych podczas synchronizacji
  
  - zapewnienie integralności i spójności danych między lokalnym storage a bazą Firestore 
  
  - pełna funkcjonalność aplikacji zarówno w trybie online, jak i offline

## Baza danych - slajd 17

- struktura bazy danych w Firestore

- kolekcja "users" - dane użytkowników

- kolekcja "users results" - historia wyników
  
  - przechowująca wyniki z sesji po każdej ukończonej sesji gry

- kolekcja "game progress" - synchronizacja postępów gry
  
  - przechowująca informacje o postępach w trakcie trwania rozgrywki w trybie offline, umożliwiająca kontynuację gry po przerwaniu lub utracie połączenia internetowego