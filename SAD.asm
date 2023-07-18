# =================================================================
#	 
#	Image Compare
#
# Shell code by: GT ECE 2035 
# Created by: Ignatius Djaynurdin
# Date: 03/05/2023
# 
# ECE 2035 Homework 2-2
#
# This program takes in two 32x32 image arrays (selected by swi 600 
# from two larger images and placed into memory at ImageA and ImageB)
# and computes a 3rd image array (stored at Result) that is the result
# of comparing the two input image arrays.
# The comparison between two pixels is done by computing the
# sum of absolute differences (or SAD) of the pixels' color components:
#    SAD = | A_r - B_r | + | A_g - B_g | + | A_b - B_b |
# where each subscript indicates the red, green or blue component of color A or B.
# 
# Each pixel P_i of the resulting comparison image is set to a different fully
# saturated color value (white, blue, green, or red), depending on the degree of
# difference in the corresponding i_th pixels in the input images:
#  white (0xFFFFFF) if 0 <= SAD < 100,
#  blue  (0x0000FF) if 100 <= SAD < 200, 
#  green (0x00FF00) if 200 <= SAD < 300, 
#  red   (0xFF0000) if 300 <= SAD < 766
#
# The output of this program should be:
# 1) the elements of Result should be the appropriate color value based on SAD
# 2) register $6 should hold the total number of Result pixels that are not WHITE.
#    This gives a quick difference metric.
# To report these outputs, call swi 533.
# The oracle will then provide info to allow you to validate your answer:
# 1) $2 will give the number of incorrect pixels your program stored in Result
#    (So you want $2 == 0.)
# 2) $3 will give you the correct number of Result pixels that are not WHITE.
#    (So you want $3 == $6.)
# ===========================================================================


.data
ImageA:      .alloc	1024		# allocate image data space
ImageB:	     .alloc 1024		# allocate image data space
Result:      .alloc	1024		# allocate output data space

.text
Compare: addi	$1, $0, ImageA	# set memory base
		################################################################
		 addi    $2, $0, 0		# optional: set starting TileNum 
			    				# (you can change it to any num
								# btwn 0 and 135). Or comment
								# out: if $2 is undefined,
								# random Tiles are picked.
		################################################################					
		swi		600				# create and display images
								# stored in memory starting at
								# address in $1
		################################################################					

		addi 	$3, $0, 0 				# Create new counter for the loop1
		addi 	$6, $0, 0				# Count not white
		
		addi 	$23, $0, 0x0000FF 		# Blue color assignment
		lui		$21, 0x0000FF 			# Red color assignment
		addi	$20, $0, 0xFFFFFF 		# White color assignment
		sll		$22, $23, 8 			# Green color assignment

Loop1:	lw 		$5, ImageA($3)	# get the int value for image A
		lw		$9, ImageB($3)	# get the int value for image B

		slti	$4, $3, 4096 	# Loop1 command
		beq		$4, $0, Report 	# Base case exit the loop

		addi	$7, $0, 0 		# Create new counter for the loop2
		addi	$28, $0, 0		# Reset SAD
		addi	$27, $0, 255	# for Masking 

Loop2:	slti	$8, $7, 3 		# Loop2 command. Loop 2 is calculating B and then the difference, and then SAD. Then do the G then R.
		beq		$8, $0, White 	# Base case exit the inner loop

		and		$10, $5, $27	# Blue value for A then green then red
		and 	$11, $9, $27	# Blue value for B then green then red

		slt		$12, $10, $11	# This slt and beq set that if A is bigger, jump to Abigger. Else, jump to Bbigger.
		beq		$12, $0, Abigger

Bbigger: sub	$13, $11, $10	# Calculate the difference if B is the bigger int
		 add	$28, $28, $13	
		 j		After1

Abigger: sub	$13, $10, $11	# Calculate the difference if A is the bigger int
		 add	$28, $28, $13
		 j		After1

After1: srl 	$5, $5, 8		# Shift 8 A for green then red
		srl		$9, $9, 8		# Shift 8 B for green then red

Inc2:	addi 	$7, $7, 1 		# Loop increment just like i++ in java for loop
		j 		Loop2 			# Jump to Loop2

White:	slti	$19, $28, 100	# Assign white if SAD is in the range
		beq		$19, $0, Blue
		sw		$20, Result($3)
		j		Inc1

Blue: 	slti	$19, $28, 200	# Assign blue if SAD is in the range
		beq		$19, $0, Green
		addi	$6, $6, 1
		sw		$23, Result($3)
		j		Inc1

Green: 	slti	$19, $28, 300	# Assign green if SAD is in the range
		beq		$19, $0, Red
		addi	$6, $6, 1
		sw		$22, Result($3)
		j		Inc1

Red:	slti	$19, $28, 766	# Assign red if SAD is in the range
		addi	$6, $6, 1
		sw		$21, Result($3)
		j		Inc1

Inc1:	addi 	$3, $3, 4 		# Loop increment just like i++ in java for loop
		j 		Loop1 			# Jump to Loop1

		################################################################
Report:	addi	$1, $0, Result	# Set base address of Result image.
		swi		533				# Display Result output image.
								# This checks that the Result image
								# matches the correct answer and
								# reports num incorrect pixels in $2.
								# This also reports the correct number
								# of nonmatching pixels in $3, so
								# you can confirm that your $6 == $3.
		################################################################					
		jr      $31				# return to OS (don't delete)


