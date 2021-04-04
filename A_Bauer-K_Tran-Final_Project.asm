# Aron Bauer and Khoa Tran --  4/29/2020
# FinalProject
# A Hangman game

.data
correctWord: .asciiz  "hangman"
guessWord: .asciiz "_______"
wrongGuesses: .asciiz "      "
msg0: .asciiz "\n\n"
msg1: .asciiz "\nWrong guesses: "
msg2: .asciiz "\nWrong guesses left: "
msg3: .asciiz "\nInput a character: "
msg4: .asciiz "\nYou already tried this incorrect letter."
msg5: .asciiz "\nYou already guessed this correct letter."
msg6: .asciiz "\n\nCongrats!  You guessed the word: "
msg7: .asciiz "\n\nOh no!  You died!"
size: .word 8 		# The size of correctWord and Guessword: must be 1 more than string length of correct word because of the null character at end of string
terminalVal: .word 6	# the allowed number of wrong guesses (also the size of wrongGuesses array)
userInput: .space 2	# storage space for user input it appears 2 bytes is required for 1 char input
#inputTest: .asciiz "\nYou inputted: "
wrong0: .asciiz "\n_________\n    |    |    		\n    0    |    \n   /|\\   |    \n    |    |    \n   / \\   |\n    ____]["
wrong1: .asciiz "\n_________\n    |    |    		\n    0    |    \n   /|\\   |    \n    |    |    \n   /     |\n    ____]["
wrong2: .asciiz "\n_________\n    |    |    		\n    0    |    \n   /|\\   |    \n    |    |    \n         |\n    ____]["
wrong3: .asciiz "\n_________\n    |    |    		\n    0    |    \n   /|    |    \n    |    |    \n         |\n    ____]["
wrong4: .asciiz "\n_________\n    |    |    		\n    0    |    \n    |    |    \n    |    |    \n         |\n    ____]["
wrong5: .asciiz "\n_________\n    |    |    		\n    0    |    \n         |    \n         |    \n         |\n    ____]["
wrong6: .asciiz "\n_________\n    |    |    		\n         |    \n         |    \n         |    \n         |\n    ____]["

.text
main:   
	lw $s0, terminalVal 	# allowed number of wrong guesses
	li $s1, 0		# counter up to terminal value
	li $s2, 0		# boolean guessed = 0
	addi $s3, $s0, 0	# this num will count down from terminal val per each wrong guess (is outputted)
	lw $s4, size 		# load size
	addi $s4, $s4, -1	# get correctWord string length (is size -1 cause of null character at the end of strings)
	
	mainLoop:		# main game loop
	
	# Table for the different stages of the stick man of being hung based off the wrong guess counter ($s3)
	beq $s3, 6, l6
	beq $s3, 5, l5
	beq $s3, 4, l4
	beq $s3, 3, l3
	beq $s3, 2, l2
	beq $s3, 1, l1
	
	
	l1: # 1 wrong guess left
	la $a0, wrong1		
	li $v0,4			
	syscall
	j start
	
	l2: # 2 wrong guesses left
	la $a0, wrong2		
	li $v0,4			
	syscall
	j start
	
	l3: # 3 wrong guesses left
	la $a0, wrong3		
	li $v0,4			
	syscall
	j start
	
	l4: # 4 wrong guesses left
	la $a0, wrong4		
	li $v0,4			
	syscall
	j start
	
	l5: # 5 wrong guesses left
	la $a0, wrong5		
	li $v0,4			
	syscall
	j start
	
	l6: # 6 wrong guesses left
	la $a0, wrong6		
	li $v0,4			
	syscall
	
	start:
	la $a0, msg0		# print 2 newLines
	li $v0,4			
	syscall
	la $a0, guessWord	# print correct guesses
	li $v0,4			
	syscall	
	la $a0, msg1		# print wrong guesses 	
	li $v0,4			
	syscall
	la $a0, wrongGuesses			
	li $v0,4			
	syscall
	la $a0, msg2		# print num of wrong guesses left
	li $v0,4			
	syscall
	li $v0,1
	move $a0, $s3,
	syscall
	la $a0, msg3		# get input
	li $v0,4			
	syscall
	li $v0, 8		# code 8 is used for this input
	la $a0, userInput	# save location for input
	li $a1, 2		# number of bytes to save
	syscall
	
	# input test
	#lb $t0, userInput
	#la $a0, inputTest
	#li $v0, 4
	#syscall
	#la $a0, userInput
	#li $v0, 4
	#syscall
	
	lb $t0, userInput	# load user's char input
	li $t1, 0		# set index to zero
	la $t4, correctWord	# set $t4 to base address of correctWord
	
	firstCheckLoop:		# check if user's input is in correctWord
	lb $t5, 0($t4)		# load next char of correctWord
	sne $t3, $t0, $t5	# $t3 = (user char != correctWord[i]
	addi $s7, $s4, -1	# set $s7 to last index of correct word string
	sne $t6, $t1, $s7	# $t6 = (index != the last index of correct word string)
	add $t7, $t3, $t6	# $t7 = ($t3 + $t6) adding both booleans
	li $t2, 2
	blt $t7, $t2, done1	# if one of the booleans is false the loop is done
	addi $t4, $t4, 1	# move to next char in correctWord
	addi $t1,$t1, 1		# increment index
	j firstCheckLoop	# continue search
	
	done1:			# finished intial search
	li $t2, 1		# we have either found a correct or incorrect word
	blt $t3, $t2, else 	# branch if letter guessed was correct ($t3 would be false)
	li $t1, 0 		# reset index to zero (we are at the case of a wrong guess here)
	li $t3, 0 		# bool alreadyGuessed = false
	la $t4, wrongGuesses 	# load base address of wrongGuesses
	
	alreadyGuessedCheck: 	# for incorrect guesses, check if this char was previiously guessed
	lb $t5, 0($t4)		# load next character of wrong guesses
	bne $t0, $t5, continue1	# continue search if input != wrongGuesses[i]
	li $v0, 4		# else notify user they alreday guessed this wrong letter
	la $a0, msg4
	syscall
	li $t3, 1		# set alreadyGuessed to true
	
	continue1:		# will this search for a previously incorrect guess continue?
	seq $t6, $t1, $s0	# check if index = term value (the end of wrongGuesses array)
	add $t7, $t6, $t3	# add the two booleans	
	bgt $t7, $zero, done2	# if either is true loop is done
	addi $t4, $t4, 1	# move to the next char in wrongGuesses
	addi $t1,$t1, 1		# increment index
	j alreadyGuessedCheck	# continue search
	
	done2:			# finished checking if wrong guess was previously guessed
	bgt $t3, $zero, mainLoop# continue game normally if that letter was previously guessed
				# else add the guess to the incrrect guess list, and decrement the number of wrong guesses left
	la $t4, wrongGuesses	# load address of wrongGuesses
	add $t4, $t4, $s1	# go to the address specified by the wrong guess counter index (started from zero)
	sb $t0, 0($t4)		# add that wrong guess to the list of wrongGuesses
	addi $s1, $s1, 1	# increment the counter of wrong guesses made
	addi $s3, $s3, -1	# subtract amount of wrong guesses left (for output)
	j mainLoopCheck		# now check if all wrong guesses are used up
	
	else: 			# the correct guess case
	li $t1, 0 		# reset index to zero
	li $t3, 0 		# bool alreadyGuessed = false
	la $t4, correctWord 	# load base address of correctWord
	la $t5, guessWord   	# load base address of guessword	
	
	alreadyGuessedCheck2: 	# check if this correct word was already guessed and find the correct index(indecies) where this letter will be placed in guessWord
	lb $t6, 0($t4)		# load next character of correctWord
	bne $t0, $t6, continue2	# continue search if input != correctWord[i]
	lb $t7, 0($t5)		# we've found the correct spot for the letter, so load next character of guessWord
	bne $t6, $t7, skipNotify # now check if user already guessed this correct letter
	li $v0, 4		# notify user they alreday guessed this correct letter
	la $a0, msg5
	syscall
	li $t3, 1		# set alreadyGuessed to true
	skipNotify:
	sb $t0, 0($t5)		# save the corect letter to guessWord[i] (overwriting the letter if it was already guessed doesn't matter since it's the same letter)
	
	continue2:		# here we check if we need to continue the search if the letter was already guessed
	addi $t2, $s4, -1	# get last index of the correctWord string (ignoring null char)
	seq $t6, $t1, $t2	# check if index = guessWord's length -1	
	add $t7, $t6, $t3	# add the two booleans	
	bgt $t7, $zero, done3	# if either is true loop is done
	addi $t4, $t4, 1	# move to next char in correctWord
	addi $t5, $t5, 1	# move to next char in guessWord
	addi $t1,$t1, 1		# increment index
	j alreadyGuessedCheck2 # continue search
	
	done3:			# we've finished putting the correct input into its proper spot in the guessWord array, now we check if the user has guessed entire word
	li $t1, 0 		# reset index to zero
	la $t4, correctWord 	# load base address of correctWord
	la $t5, guessWord   	# load base address of guessword
	li $s2, 1 		# guessed is temproarily set to true
	wordIsGuessedCheck: 	# loop for checking if entire word has been guessed
	lb $t2, 0($t4)		# load next char in correctWord
	lb $t3, 0 ($t5) 	# load next char in guessWord
	seq $s2, $t2, $t3	# boolean guessed = (correctWord[i] == guessWord[i])
	addi $s7, $s4, -1	# get last index of correctWord array
	slt $t6, $t1, $s7	# set boolean $t6 to (index < size -1)
	add $t7, $s2, $t6 	# add both booleans
	li $s7, 2		
	beq $t7, $s7, continue3 # continue search if both booleans are true
	j isGameDone		# else do the final check after parsing through input string to determine if user has guessed entire word
	
	continue3:		# continuing search through guessWord and correctWord to determine if user has guessed entire word
	addi $t1, $t1, 1	# increment index
	addi $t4, $t4, 1	# move to next char in correctWord
	addi $t5, $t5, 1	# move to next char in guessWord
	j wordIsGuessedCheck	# continue the search
	
	
	isGameDone:		# the final check if the user has beat the game
	beq $s2, $zero, mainLoop # continue game if boolean guessed is false
	li $v0, 4		# else congradulate user, show the full correct word, then exit
	la $a0, msg6
	syscall
	li $v0, 4
	la $a0, correctWord
	syscall
	j gameOver
	
	mainLoopCheck:		# checking if user used up all their wrong guesses (part of the incorrect guess branch)
	seq $t1, $s0, $s1	# does the wrong guess counter equal the terminal value?
	beq $t1, $zero, mainLoop# if that's false continue game
	li $v0, 4		# else print the complete hangning stick figure image, and tell user game over
	la $a0, wrong0		
	li $v0,4			
	syscall
	la $a0, msg7
	syscall
		
	gameOver:
	li $v0, 10	  # syscall code 10 is for exit
	syscall 	  # make the syscall

# end of FinalProject
