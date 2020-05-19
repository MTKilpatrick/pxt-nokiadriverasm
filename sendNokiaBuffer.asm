sendNokiaBufferAsm:

 	; arguments are: r0 - buffer, r1 - data pin, r2 - clock pin
    push {r4,r5,r6,r7,lr}
    
    mov r6, r1
    mov r7, r2

    mov r4, r0 ; save buff
    mov r0, r4
    bl BufferMethods::length
    mov r5, r0          ; r5 contains buffer length
    
    mov r0, r4
    bl BufferMethods::getBytes
    mov r4, r0          ; r4 points to the data
    
    ; setup 1st pin as digital (data)
    mov r0, r6
    movs r1, #0
    bl pins::digitalWritePin
    ; setup 2nd pin as digital (clock)
    mov r0, r7
    movs r1, #0
    bl pins::digitalWritePin

    ; load pin address
    mov r0, r6
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r1, [r0, #4] ; r1-mask for this pin
    ldr r2, [r0, #16] ; r2-clraddr
    ldr r3, [r0, #12] ; r3-setaddr
    str r1, [r2, #0] ; set data pin low
    mov r6, r1   ; r6 is the mask data pin
    mov r8, r2   ;  r8 is for set low data pin
    mov r9, r3  ;  r9 is for set high data pin

	

    ; load clock pin address into r0 and get addrs/mask
    mov r0, r7
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r1, [r0, #4] ; r1-mask for this pin
    ldr r2, [r0, #16] ; r2-clraddr
    ldr r3, [r0, #12] ; r3-setaddr
    str r1, [r2, #0] ; set clock pin low  (unnecessary)
    mov r11, r2   ; r11 is for set low clock pin
    mov r12, r3   ;  r12 is for set high clock pin

    ; STATUS:
    ; r0    loaded with buffer data
    ; r1    mask byte for clock pin
    ; r3    used for temp storage of clr/set addr for pins
    ; r4    buffer address
    ; r5    counter
    ; r6    mask byte for data pin
    ; r7    bitmask

.start:
    movs r7, #0x80      ; reset mask 
    ldrb r0, [r4, #0]  ; r0 := *r4               ; C2
.common:                      
    mov r3, r11     ; prepare r3 for clock low      ; C1 
    str r1, [r3, #0]    ; clock pin := lo
    nop
    nop
    nop
    nop
	mov r3, r9      ; get the setaddr for datapin   ; C1
    tst r7, r0     
    bne .nextone                                    ; C1 + p
	mov r3, r8      ; get the clraddr for data pin  ; C1
.nextone:
    str r6, [r3, #0]    ; set data pin                  ; C2
    nop
    nop
    nop
    nop
    mov r3, r12     ; get the setaddr for clock     ; C1   
    lsrs r7, r7, #1     ; r6 >>= 1   C7             ; C1
    str r1, [r3, #0]    ; clock pin := high             ; C2
    nop
    nop
    nop
    nop
    bne .common       ;            C8             ; C1 + p
    ; not just a bit - need new byte
    adds r4, #1         ; r4++       C9
    subs r5, #1         ; r5--       C10
    bcs .start           ; if (r5>=0) goto .start  C11

.stop:
    nop
    nop
    mov r3, r11     ; prepare r3 for clock low      ; C1 
    str r1, [r3, #0]    ; clock pin := lo

    pop {r4,r5,r6,r7,pc}


