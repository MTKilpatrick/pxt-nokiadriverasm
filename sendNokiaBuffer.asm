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
    ldr r6, [r0, #4] ; r1-mask for this pin    

    ; load clock pin address into r0 and get addrs/mask
    mov r0, r7
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r1, [r0, #4] ; r1-mask for this pin
    ldr r2, [r0, #16] ; r2-clraddr
    ldr r3, [r0, #12] ; r3-setaddr

    ; REGISTERS:
    ; r0    to bloaded with buffer data
    ; r1    mask byte for clock pin
    ; r2    address for set  low
    ; r3    used for temp storage of clr/set addr for pins
    ; r4    buffer address
    ; r5    counter
    ; r6    mask byte for data pin
    ; r7    bitmask

; r2 is low
; r3 is high
.start2:
    movs r7, #0x80      ; reset mask 
    ldrb r0, [r4, #0]  ; r0 := *r4               ; C2
.common2:
    str r1, [r2, #0]    ; clock pin := lo     ; C1
    nop
    nop
    tst r7, r0     
    bne .dohigh     ; r3 is already high set so move on...  ; C1 + p
.dolow:
    str r6, [r2, #0]
    b .setclockhigh
.dohigh:
    str r6, [r3, #0]    ; set data pin                  ; C2
.setclockhigh:
    nop
    nop
    lsrs r7, r7, #1     ; r6 >>= 1   C7             ; C1
    str r1, [r3, #0]    ; clock pin := high             ; C2
    bne .common2       ;            C8             ; C1 + p
    ; not just a bit - need new byte
    adds r4, #1         ; r4++       C9
    subs r5, #1         ; r5--       C10
    bne .start2          ; if (r5>=0) goto .start  C11
.stop:
    str r1, [r2, #0]    ; clock pin := lo

    pop {r4,r5,r6,r7,pc}




