/** @module : pars
 *  @author : Secure Trusted and Assured Microelectronics (STAM) Center

 *  Copyright (c) 2023 PQC.Secure (STAM/SCAI/ASU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

/*********************************************************************************
*                                      paramters                                 *
*********************************************************************************/


// p: Ring element size
// Make p this size so that the (A * B) % p will be correct
// N: Polynomial length: # of coefficients in the polynomial



/*
// N = 8
parameter [9:0] p = 17; 
parameter N = 8;
parameter N_inv = 15; // 1/N mod p
*/


/*
// N = 16
parameter [13:0] p = 97; 
parameter N = 16;
parameter N_inv = 91; // 1/N mod p
*/


/*
// N = 32
parameter [15:0] p = 193; 
parameter N = 32;
parameter N_inv = 187; // 1/N mod p
*/



/*
// N = 64
parameter [16:0] p = 257; 
parameter N = 64;
parameter N_inv = 253; // 1/N mod p
*/

/*
parameter [20:0] p = 1153; 
parameter N = 64;
parameter N_inv = 1135; // 1/N mod p
*/

// N = 128

/*
parameter [19:0] p = 769; 
parameter N = 128;
parameter N_inv = 763; // 1/N mod p
*/

/*
parameter [23:0] p = 3329; 
parameter N = 128;
parameter N_inv = 3303; // 1/N mod p
*/

/*
parameter [27:0] p = 9473; 
parameter N = 128;
parameter N_inv = 9399; // 1/N mod p
*/

/*
// N = 256
parameter [41:0] p = 1049089; 
parameter N = 256;
parameter N_inv = 1044991; // 1/N mod p
*/


// N = 256
parameter [27:0] p = 10753; 
parameter N = 256;
parameter N_inv = 10711; // 1/N mod p


/*
// N = 512
parameter [27:0] p = 12289;
parameter N = 512;
parameter N_inv = 12265; //1/N mod p
*/

/*
// N = 1024
parameter [29:0] p = 18433;
parameter N = 1024;
parameter N_inv = 18415; //1/N mod p
*/


//Different n and p = 12289
/*
//N = 8
parameter [27:0] p = 12289;
parameter N = 8;
parameter N_inv = 10753; //1/N mod p
*/

/*
//N = 16
parameter [27:0] p = 12289;
parameter N = 16;
parameter N_inv = 11521; //1/N mod p
*/

/*
//N = 32
parameter [27:0] p = 12289;
parameter N = 32;
parameter N_inv = 11905; //1/N mod p
*/

/*
//N = 64
parameter [27:0] p = 12289;
parameter N = 64;
parameter N_inv = 12097; //1/N mod p
*/

/*
//N = 128
parameter [27:0] p = 12289;
parameter N = 128;
parameter N_inv = 12193; //1/N mod p
*/

/*
//N = 256
parameter [27:0] p = 12289;
parameter N = 256;
parameter N_inv = 12241; //1/N mod p
*/

/*
//N = 512
parameter [27:0] p = 12289;
parameter N = 512;
parameter N_inv = 12265; //1/N mod p
*/

/*
//N = 1024
parameter [27:0] p = 12289;
parameter N = 1024;
parameter N_inv = 12277; //1/N mod p
*/


//N = 64 and varying p
/*
//p = 12289
parameter [27:0] p = 12289;
parameter N = 64;
parameter N_inv = 12097; //1/N mod p
*/

/*
//p = 18433
parameter [29:0] p = 18433;
parameter N = 64;
parameter N_inv = 18145; //1/N mod p
*/

/*
//p = 40961
parameter [31:0] p = 40961;
parameter N = 64;
parameter N_inv = 40321; //1/N mod p
*/

/*
//p = 59393
parameter [31:0] p = 59393;
parameter N = 64;
parameter N_inv = 58465; //1/N mod p
*/
/*
//p = 65537
parameter [33:0] p = 65537;
parameter N = 64;
parameter N_inv = 64513; //1/N mod p
*/

/*
//N = 128 and varying p
//p = 12289
parameter [27:0] p = 12289;
parameter N = 128;
parameter N_inv = 12193; //1/N mod p
*/
/*
//p = 18433
parameter [29:0] p = 18433;
parameter N = 128;
parameter N_inv = 18289; //1/N mod p
*/
/*
//p = 40961
parameter [31:0] p = 40961;
parameter N = 128;
parameter N_inv = 40641; //1/N mod p
*/
/*
//p = 59393
parameter [31:0] p = 59393;
parameter N = 128;
parameter N_inv = 58929; //1/N mod p
*/
/*
//p = 65537
parameter [33:0] p = 65537;
parameter N = 128;
parameter N_inv = 65025; //1/N mod p
*/

/*
//N = 256 and varying p
//p = 12289
parameter [27:0] p = 12289;
parameter N = 256;
parameter N_inv = 12241; //1/N mod p
*/
/*
//p = 18433
parameter [29:0] p = 18433;
parameter N = 256;
parameter N_inv = 18361; //1/N mod p
*/
/*
//p = 40961
parameter [31:0] p = 40961;
parameter N = 256;
parameter N_inv = 40801; //1/N mod p
*/
/*
//p = 59393
parameter [31:0] p = 59393;
parameter N = 256;
parameter N_inv = 59161; //1/N mod p
*/
/*
//p = 65537
parameter [33:0] p = 65537;
parameter N = 256;
parameter N_inv = 65281; //1/N mod p
*/

/*
//N = 512 and varying p
//p = 12289
parameter [27:0] p = 12289;
parameter N = 512;
parameter N_inv = 12265; //1/N mod p
*/
/*
//p = 18433
parameter [29:0] p = 18433;
parameter N = 512;
parameter N_inv = 18397; //1/N mod p
*/
/*
//p = 40961
parameter [31:0] p = 40961;
parameter N = 512;
parameter N_inv = 40881; //1/N mod p
*/
/*
//p = 59393
parameter [31:0] p = 59393;
parameter N = 512;
parameter N_inv = 59277; //1/N mod p
*/
/*
//p = 65537
parameter [33:0] p = 65537;
parameter N = 512;
parameter N_inv = 65409; //1/N mod p
*/

/*
//N = 1024 and varying p
//p = 12289
parameter [27:0] p = 12289;
parameter N = 1024;
parameter N_inv = 12277; //1/N mod p
*/
/*
//p = 18433
parameter [29:0] p = 18433;
parameter N = 1024;
parameter N_inv = 18415; //1/N mod p
*/
/*
//p = 40961
parameter [31:0] p = 40961;
parameter N = 1024;
parameter N_inv = 40921; //1/N mod p
*/
/*
//p = 59393
parameter [31:0] p = 59393;
parameter N = 1024;
parameter N_inv = 59335; //1/N mod p
*/

/*
//p = 65537
parameter [33:0] p = 65537;
parameter N = 1024;
parameter N_inv = 65473; //1/N mod p
*/