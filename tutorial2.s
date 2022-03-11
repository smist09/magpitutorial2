// Program to add to numbers and print
// the results. Most of the program is to print
// the contents of register X0 in hex and decimal.
// This is in ARM 64-bit Assembly Language.
//

.global _start // Standard starting address label

_start:
// Load first number from memory into X0 and save in X19
	LDR		X0, num1
	MOV		X19, X0
	
	BL		printReg0	// Print the value of X0
	
// Load the second number from memory into X0 and save to X20
	LDR		X0, num2
	MOV		X20, X0
	BL		printReg0	// Print the new value of X0
	
// The the two orignal numbers
	ADD		X0, X19, X20
	BL		printReg0	// Print the sum, now in X0
	
// Setup the parameters to exit the program
// and then call the Raspberry Pi OS to do it.
	MOV		X0, #0		// Return code is 0
	MOV		X8, #93		// Service to terminate
	SVC		0			// Call Linux to perform

// Function: printReg0
// Purpose: print out the contents of register X0 in both
// hexadecimal and decimal to stdout.
// Builds the string:
//		Reg0: 0xhexvalue decimalvalue
//		Registers overwritten: X0, X1, X2, X7, X8, X9
//

printReg0:
	STR		LR, [SP, #-16]! // Save the return address
	LDR		X1, =label1		// Load address of label and buffer
	MOV		X7, X1			// Keep a backup for later
	MOV		X9, X0			// Keep a backup of register to print
	ADD		X1, X1, #7		// Skipp "Reg0: 0x"
	BL		printHex		// Print X0 in hex
	MOV		X0, X9			// Restore original value of X0
	MOV		X1, X7			// Restore original buffer
	ADD		X1, X1, #24		// After hex value and a space
	BL		printDec		// Print the value in decimal

// Print out the finished string using the Linux service	
	MOV		X0, #0		// Stdout
	MOV		X1, X7		// Original address of the string
	MOV		X2, #46     // Length of the string
	MOV		X8, #64		// Linux service to write to a file
	SVC		0			// Perform the operation
	LDR	    LR, [SP], #16 // Restore the return address
	RET
	
// printHex: print register X0 in hex to buffer pointed to by X1
// 		Registers overwritten: X0, X1, X2, X3	
printHex:
	MOV		X2, #16		// 16 hex chars in 64-bit
	ADD		X1, X1, #16 // Print in reverse so start at back
LOOP:
	AND		X3, X0, #0xF // And off the low order nibble
	CMP		X3, #10		// Is the character 0-9 or A-F?
	B.PL	HEX			// if >=10 branch
	ADD		X3, X3, #'0' // Convert to ASCII
	B		STORE		// Jump ahead to store
HEX:
	ADD		X3, X3, #('A' - 10) // Convert to ASCII
STORE:
	STRB		W3, [X1], #-1	// Save and post decrement
	MOV		X0, X0, LSR 4	// Divide by 16 by shifting 4 bits
	SUBS 	X2, X2, #1		// Decement loop counter
	B.NE	LOOP			// Loop if not zero
	RET

// printDec: print register X0 in decimal to buffer X1
//		Registers overwritten: X0, X1, X2, X3, X8 
printDec:
	MOV		X2, #20		// 20 decimal chars in 64-bit
	ADD		X1, X1, #20 // Fill in buffer in reverse
LOOP2:
	MOV		X8, #10		// Decimal is base 10
	MOV		X3, X0		// Keep original number	
	UDIV	X0, X0, X8	// X0 = X0 / 10
	// Calculate the remainder using MSUB.
	MSUB	X3, X0, X8, X3 // X3 = X3 - (X0 * 10)
	ADD		X3, X3, #'0'// Convert digit to ASCII 
	STRB	W3, [X1], #-1 // Store the value and post decrement
	SUBS 	X2, X2, #1	// Decrement loop counter
	B.NE	LOOP2		// Loop if not zero
	RET

num1: .quad 0x1234567890ABCDEF	// first number
num2: .quad 0xfedcba90			// second number

.data
label1: .ascii "Reg0: 0x                                     \n\n\n"

