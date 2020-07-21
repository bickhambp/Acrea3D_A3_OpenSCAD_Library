# Acrea3D_A3_OpenSCAD_Library
A Library for OpenSCAD with common features


Acrea3D_Lib is a library to make 3D design simpler

Use it in openSCAD with "use <Acrea3D_Lib.scad>"
You can then call any of the functions within the library itself by calling the name of the functions directly

Rules for writing functions in the Library:
1. Every module and function starts with "A3_" and then we use camelcase lower
	ex. A3_quadConnect()
2. Every parameter called by a function is written by writing the variable name in upper camelcase preceded by "A3_"
	ex. A3_quadConnect(A3_Period, A3_ForkPeriod)
3. Every Parameter made in the module is named by writing the variable name in upper camelcase preceded by "AF_"
	ex. AF_YTrans = ...
4. If there is a module written within another module the child module is named by writing the name of the module in lower camelcase preceded by "AF_" up to the number of parents it has
	ex. 	module A3_quadConnect(){
				module AF_childQuadConnect(){
					module AF_AF_example(){
						...
					}
				}
			}
5. Variables written in a child module must be written as said previously and additionally preceded by "AF_" for the number of parents it has until the parent module
	ex. 	module A3_quadConnect(){
				module AF_childQuadConnect(){
					AF_AF_YTrans = ...
				}
			}
6. All Modules and Functions must have a summary previous to the function itself

**I will probably add more to this list as I discover potential problems