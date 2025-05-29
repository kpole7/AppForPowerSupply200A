Przewodnik kompilacji aplikacji do sterowania zasilaczami 200A pod linuksem
2025-05-23
wersja 1.0

1. Przed kompilacją należy zainstalować FLTK 1.3 (Fast Light Tool Kit).

2. Wypakować plik Aplikacja_do_zasilaczy_200A_wersja_1_0.tar.gz
   Po wypakowaniu powstanie drzewo:
	    powerSource200A_Svedberg
	    ├── build
	    ├── documentation
	    │   └── Varia
	    ├── freeModbus
	    │   ├── ascii
	    │   ├── functions
	    │   ├── include
	    │   ├── port
	    │   ├── rtu
	    │   └── tcp
	    ├── testing_TCP_master
	    └── testing_TCP_slave

3. W podkatalogu build uruchomić "cmake ..", a następnie "make",
   żeby wykonać kompilację (powinna przebiegać bez błędów i bez ostrzeżeń).

4. Plik wykonywalny "powerSource200A_Svedberg" musi znajdować się w tym samym 
   podkatalogu, co plik konfiguracyjny "powerSource200A_Svedberg.cfg".  
   W podkatalogu "testing_TCP_master" znajduje się przykładowy plik konfiguracyjny
   do aplikacji na komputer zdalny, a w podkatalogu "testing_TCP_slave" - na 
   komputer lokalny.  Pliki konfiguracyjne należy dostosować do swoich potrzeb.

5. Pozostała dokumentacja znajduje się w podkatalogu "documentation" w drzewie 
   katalogowym. 
   
