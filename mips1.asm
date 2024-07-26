#dyrektywa .data chroni w sobie globalne zmienne
.data
# zmienne, przechowuj?ce tekst, .asciiz odpowiada za typ tekstu
message:    .asciiz "Please, choose an expression that you want to count.\n 1) (a+b)/c\n 2) (a + c)*b\n 3) b - (a + c)\n"
messageA:   .asciiz "Please, enter a "
messageB:   .asciiz "Please, enter b "
messageC:   .asciiz "Please, enter c "
messageRes: .asciiz "The result of counting is: " 
newline:    .asciiz "\n"
question:   .asciiz "Do you want to continue? \n 0 - no, 4 - yes "
error:      .asciiz "You cont dividing by zero\n"

#dyrektywa .text odpowiada za pocz?tek segmentu kodu
.text

# g?ówna procedura/funkcja
main:
	# wy?wietlenie czapki, 4 - kod odpowiada za wy?wietlenie ci?gu, registr v0 jest usywany do przechowywania kodu
	li $v0, 4
  la $a0, message # registristr a0, przechowuje w sobie ci?g message
  syscall # wbudowane wywolanie systemowe
  
  # 5 odpowiada za wpisywanie liczb ca?kowitych
  li $v0, 5        
  syscall            

  # skok do lejblów
  beq $v0, 0, exitProgram    
  beq $v0, 1, countTheFirstExpression   
  beq $v0, 2, countTheSecondExpression   
  beq $v0, 3, countTheThirdExpression              

# funkcja koniec programu, 10 odpowiada za wyj?cie z programu
exitProgram:
	li $v0 10
	syscall

# funkcja odpowiadaj?ca za wywolanie pytania o kontynuacji oblicze?
Question:
# wyswietlenie pytania o kontynuacji
    li $v0, 4                 
    la $a0, question
    syscall

#podanie przez u?ytkownika liczby ca?kowitej (wybiór u?ytkownika)
    li $v0, 5        
    syscall 
#przechowujemy w registrze s0 warto?? v0
    move $s0, $v0             
# je?li podana przez u?ytkownika liczba jest 4, to skok do main (condition if)
    beq $s0, 4, main 
#je?li podana liczba nie równa 4, to skok do funkcji exitProgram    
    j exitProgram

#funkcja wy?wietlaj?ca wynik obliczenia
printingTheResult:
# wy?wetlamy tekst ze zmiennej messageRez
    li $v0, 4
    la $a0, messageRes
    syscall
# zapisujemy a registrze a0 warto?? z registra t1    
    move $a0, $t1    
    li $v0, 1  #1 - wy?wietliamy liczby naturalne      
    syscall

#wy?wetlamy tekst "\n"
    li $v0, 4         
    la $a0, newline
    syscall
#wrócamy do tego miejsca od którego by? skok    
    jr $ra

#funkcja obliczaj?ca pierwszy wyraz
countTheFirstExpression:
# wy?wetlamy tekst ze zmiennej messageA
    li $v0, 4
    la $a0, messageA 
    syscall
#U?ytkownik wczytuje liczb? ca?kowit?
    li $v0, 5        
    syscall
# przepisujemy warto?? zmiennej a z registru v0 do registru s0    
    move $s0, $v0      
# robimy to samo tylko dla zmiennej b
    li $v0, 4
    la $a0, messageB 
    syscall
    li $v0, 5        
    syscall
    move $s1, $v0      
# robimy to samotylko dla zmiennej c
    li $v0, 4
    la $a0, messageC 
    syscall
    li $v0, 5        
    syscall
    move $s2, $v0
#je?li  warto?? w registrze s2 równa zero to robimy skok do er
    beq  $s2, 0, er       
#dodajemy warto?? z regitsru s0 do registru s1 i zapisujemy odpowiedz w t0
    add $t0, $s0, $s1
#dzielimy   warto?? z registru t0 przez warto?? z registru s2   
    div $t1, $t0, $s2  
#skok do funkcji która wy?wietla wynik	         
    jal printingTheResult
#skok do funkcji z pytaniem o kontynuacji
    j Question

# obliczamy drugie wyra?enie    
countTheSecondExpression:
# robimy wszystko to samo jak dla wyra?enia 1
    li $v0, 4
    la $a0, messageA 
    syscall
    li $v0, 5        
    syscall
    move $s0, $v0      

    li $v0, 4
    la $a0, messageC 
    syscall
    li $v0, 5        
    syscall
    move $s1, $v0      

    li $v0, 4
    la $a0, messageB 
    syscall
    li $v0, 5        
    syscall
    move $s2, $v0 

    add $t0, $s0, $s1 
#mno?ymy warto?? z registru t0 i s2, przehcowujemy w t1      
    mul $t1, $t0, $s2   
    jal printingTheResult
    j Question

countTheThirdExpression:
# robimy wszystko to samo jak dla wyra?nia 1
    li $v0, 4
    la $a0, messageA 
    syscall
    li $v0, 5        
    syscall
    move $s0, $v0      

    li $v0, 4
    la $a0, messageB 
    syscall
    li $v0, 5        
    syscall
    move $s1, $v0      

    li $v0, 4
    la $a0, messageC 
    syscall
    li $v0, 5        
    syscall
    move $s2, $v0 
    
    add $t0, $s0, $s2 
#odejmujemy od warto?ci s1    warto?? t0, zapisujemy w t1
    sub $t1, $s1, $t0   
    jal printingTheResult
    j Question

#wyswietlenie  tekstu ze zmiennej error    
 er:
 li $v0, 4
 la $a0, error
 syscall
 j  Question  
