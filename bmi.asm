data segment
    ; add your data here!
    msgWeight db "Please enter your weight(Kg): $"
    msgHeight db "Please enter your Height(cm): $"
    msgHEquals db "H = $"
    msgOverWeight db "Over weight$"
    msgUnderWeight db "Under weight$"
    msgNormal db "Normal$"
    number dw 0
    weight dw 0
    height dw 0
    H_int dw 0
    H_float dw 0
    
ends

stack segment
    dw   256  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    main proc far
        mov dx, offset msgWeight
        mov ah, 9
        int 21h
        call GetNumber ; => in
        mov ax, number
        mov weight, ax

        mov dx, offset msgHeight
        mov ah, 9
        int 21h
        call GetNumber ; => in
        mov ax, number
        mov height, ax
        
        call BMI

        mov al, 0
        mov ah, 9
        mov cx, 9
        mov bl, 13
        mov bh, 0
        int 10h
        mov dx, offset msgHEquals
        mov ah, 9
        int 21h

        mov ax, H_int
        mov number, ax
        call PrintNumber
        mov dx, '.'
        mov ah, 2
        int 21h
        
        mov ax, H_float
        cmp ax, 10
        jge printFloatingPart
        ; example: 21.06
        mov dx, '0'
        mov ah, 2
        int 21h
        mov ax, H_float
        
        printFloatingPart:
        mov number, ax
        call PrintNumber

        mov dx, 0ah ; next line character
        mov ah, 02h ; dos function for printing characters in 21h
        int 21h
        mov dx, 0dh ; return to line start character
        mov ah, 02h ; dos function for printing characters in 21h
        int 21h
        
        cmp H_int, 25
        jge overweight
        cmp H_int, 18
        jl underweight
        jg normal
        cmp H_float, 50
        jge normal
        jl underweight

        overweight: mov al, 0
            mov ah, 9
            mov cx, 11
            mov bl, 4
            mov bh, 0
            int 10h
            mov dx, offset msgOverWeight
            mov ah, 9
            int 21h
            jmp close


        underweight: mov al, 0
            mov ah, 9
            mov cx, 12
            mov bl, 12
            mov bh, 0
            int 10h
            mov dx, offset msgUnderWeight
            mov ah, 9
            int 21h
            jmp close


        normal: mov al, 0
            mov ah, 9
            mov cx, 7
            mov bl, 2
            mov bh, 0
            int 10h
            mov dx, offset msgNormal
            mov ah, 9
            int 21h

        close: mov ax, 4c00h ; return to DOS
        int 21h  
    endp

    BMI proc
        mov ax, weight
        mov si, 100
        mul si ; height must be in meters, the input was in cm => so we multiply weight by 100 too
        mov dx, 0

        mov si, height
        div si ; div ax/si === weight / height
        ; ax is the integer part of division
        mov cx, dx
        mov bx, 100
        mul bx

        mov di, ax ; add the final result of this term calculation -> to word:integer_part
        ; dx is the remainder
        ; for calculating floating_part we use this formula:
        ; term_floating_part = remainder * PRECISION / cx! = dx * 100 / denominator
        mov ax, cx
        mov dx, 0
        mov bx, 100
        mul bx ; ax = dx * 100
        ; now divide ax by weight=si
        div si
        add ax, di

        mov dx, 0
        div si
        mov H_int, ax
        
        mov ax, dx
        mov dx, 0
        mov bx, 100
        mul bx
        div si
        mov H_float, ax
        ret
    endp

    GetNumber proc
        mov si, 0

        nextDigit: mov al, 0
            mov ah, 9
            mov cx, 1
            mov bl, 5
            mov bh, 0
            int 10h
            
            mov ah, 1
            int 21h
            mov ah, 0
            
            cmp al, 0dh
            je endInput
            cmp al, ' '
            je endInput

            cmp al, '0'
            jl nextDigit
            cmp al, '9'
            jg nextDigit
            sub al, '0' ; convert pressed key to a digit
            mov ah, 0
            mov bx, ax
            mov ax, si
            mov dx, 10
            mul dx
            mov si, ax
            add si, bx
        jmp nextDigit

        endInput: mov number, si
        mov dx, 0ah ; next line character
        mov ah, 02h ; dos function for printing characters in 21h
        int 21h
        ret
    endp

    PrintNumber proc
        ; offset address must be in si
        mov ax, number
        
        mov bx, 00ffh ; last digit address
        mov di, bx; 
        mov [bx], '$' ;end of the string

        mov cx, 0
        mov dx, 0
       
        extractDigits: mov si, 10d
            mov dx, 0
            div si
            mov dh, 0
            add dl, '0'
            dec di
            mov [di], dl
            
            cmp ax, 0000h
            jne extractDigits

        ; now print it via 2109
        mov dx, di ;offset number string

        mov ah, 09h
        int 21h
        ret
    endp
ends

end start ; set entry point and stop the assembler.
