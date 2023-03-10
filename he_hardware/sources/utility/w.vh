/** @module : parameters - w
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

// for N = 8, p = 17
// alpha = 3
if (N == 8)
begin
    w[0] <= 1; w[1] <= 9; w[2] <= 13; w[3] <= 15; w[4] <= 16; w[5] <= 8; w[6] <= 4; w[7] <= 2;
    // w[8] == 1
    
    iw[0] <= 1; iw[1] <= 2; iw[2] <= 4; iw[3] <= 8; iw[4] <= 16; iw[5] <= 15; iw[6] <= 13; iw[7] <= 9;
    // iw[8] == 1
end



// for N = 16, p = 97
// alpha = 5
else if (N == 16)
begin
    w[0] <= 1; w[1] <= 8; w[2] <= 64; w[3] <= 27; w[4] <= 22; w[5] <= 79; w[6] <= 50; w[7] <= 12; 
    w[8] <= 96; w[9] <= 89; w[10] <= 33; w[11] <= 70; w[12] <= 75; w[13] <= 18; w[14] <= 47; w[15] <= 85;
    // w[16] <= 1;
    
    iw[0] <= 1; iw[1] <= 85; iw[2] <= 47; iw[3] <= 18; iw[4] <= 75; iw[5] <= 70; iw[6] <= 33; iw[7] <= 89; 
    iw[8] <= 96; iw[9] <= 12; iw[10] <= 50; iw[11] <= 79; iw[12] <= 22; iw[13] <= 27; iw[14] <= 64; iw[15] <= 8;
    // iw[16] <= 1;
end



// for N = 32, p = 193
// alpha = 5
else if (N == 32)
begin
    w[0] <= 1; w[1] <= 185; w[2] <= 64; w[3] <= 67; w[4] <= 43; w[5] <= 42; w[6] <= 50; w[7] <= 179; 
    w[8] <= 112; w[9] <= 69; w[10] <= 27; w[11] <= 170; w[12] <= 184; w[13] <= 72; w[14] <= 3; w[15] <= 169; 
    w[16] <= 192; w[17] <= 8; w[18] <= 129; w[19] <= 126; w[20] <= 150; w[21] <= 151; w[22] <= 143; w[23] <= 14; 
    w[24] <= 81; w[25] <= 124; w[26] <= 166; w[27] <= 23; w[28] <= 9; w[29] <= 121; w[30] <= 190; w[31] <= 24; 
    
    iw[0] <= 1; iw[1] <= 24; iw[2] <= 190; iw[3] <= 121; iw[4] <= 9; iw[5] <= 23; iw[6] <= 166; iw[7] <= 124; 
    iw[8] <= 81; iw[9] <= 14; iw[10] <= 143; iw[11] <= 151; iw[12] <= 150; iw[13] <= 126; iw[14] <= 129; iw[15] <= 8; 
    iw[16] <= 192; iw[17] <= 169; iw[18] <= 3; iw[19] <= 72; iw[20] <= 184; iw[21] <= 170; iw[22] <= 27; iw[23] <= 69; 
    iw[24] <= 112; iw[25] <= 179; iw[26] <= 50; iw[27] <= 42; iw[28] <= 43; iw[29] <= 67; iw[30] <= 64; iw[31] <= 185;
end



// for N = 64, 

else if (N == 64)
begin
    // p = 257, alpha = 3
    /*
    w[0] <= 1; w[1] <= 81; w[2] <= 136; w[3] <= 222; w[4] <= 249; w[5] <= 123; w[6] <= 197; w[7] <= 23; 
    w[8] <= 64; w[9] <= 44; w[10] <= 223; w[11] <= 73; w[12] <= 2; w[13] <= 162; w[14] <= 15; w[15] <= 187; 
    w[16] <= 241; w[17] <= 246; w[18] <= 137; w[19] <= 46; w[20] <= 128; w[21] <= 88; w[22] <= 189; w[23] <= 146; 
    w[24] <= 4; w[25] <= 67; w[26] <= 30; w[27] <= 117; w[28] <= 225; w[29] <= 235; w[30] <= 17; w[31] <= 92; 
    w[32] <= 256; w[33] <= 176; w[34] <= 121; w[35] <= 35; w[36] <= 8; w[37] <= 134; w[38] <= 60; w[39] <= 234; 
    w[40] <= 193; w[41] <= 213; w[42] <= 34; w[43] <= 184; w[44] <= 255; w[45] <= 95; w[46] <= 242; w[47] <= 70; 
    w[48] <= 16; w[49] <= 11; w[50] <= 120; w[51] <= 211; w[52] <= 129; w[53] <= 169; w[54] <= 68; w[55] <= 111; 
    w[56] <= 253; w[57] <= 190; w[58] <= 227; w[59] <= 140; w[60] <= 32; w[61] <= 22; w[62] <= 240; w[63] <= 165;
    
    iw[0] <= 1; iw[1] <= 165; iw[2] <= 240; iw[3] <= 22; iw[4] <= 32; iw[5] <= 140; iw[6] <= 227; iw[7] <= 190; 
    iw[8] <= 253; iw[9] <= 111; iw[10] <= 68; iw[11] <= 169; iw[12] <= 129; iw[13] <= 211; iw[14] <= 120; iw[15] <= 11; 
    iw[16] <= 16; iw[17] <= 70; iw[18] <= 242; iw[19] <= 95; iw[20] <= 255; iw[21] <= 184; iw[22] <= 34; iw[23] <= 213; 
    iw[24] <= 193; iw[25] <= 234; iw[26] <= 60; iw[27] <= 134; iw[28] <= 8; iw[29] <= 35; iw[30] <= 121; iw[31] <= 176; 
    iw[32] <= 256; iw[33] <= 92; iw[34] <= 17; iw[35] <= 235; iw[36] <= 225; iw[37] <= 117; iw[38] <= 30; iw[39] <= 67; 
    iw[40] <= 4; iw[41] <= 146; iw[42] <= 189; iw[43] <= 88; iw[44] <= 128; iw[45] <= 46; iw[46] <= 137; iw[47] <= 246; 
    iw[48] <= 241; iw[49] <= 187; iw[50] <= 15; iw[51] <= 162; iw[52] <= 2; iw[53] <= 73; iw[54] <= 223; iw[55] <= 44; 
    iw[56] <= 64; iw[57] <= 23; iw[58] <= 197; iw[59] <= 123; iw[60] <= 249; iw[61] <= 222; iw[62] <= 136; iw[63] <= 81; 
    */
    
    // p = 1153, alpha = 5
    w[0] <= 1; w[1] <= 943; w[2] <= 286; w[3] <= 1049; w[4] <= 1086; w[5] <= 234; w[6] <= 439; w[7] <= 50; 
    w[8] <= 1030; w[9] <= 464; w[10] <= 565; w[11] <= 109; w[12] <= 170; w[13] <= 43; w[14] <= 194; w[15] <= 768; 
    w[16] <= 140; w[17] <= 578; w[18] <= 838; w[19] <= 429; w[20] <= 997; w[21] <= 476; w[22] <= 351; w[23] <= 82; 
    w[24] <= 75; w[25] <= 392; w[26] <= 696; w[27] <= 271; w[28] <= 740; w[29] <= 255; w[30] <= 641; w[31] <= 291; 
    w[32] <= 1152; w[33] <= 210; w[34] <= 867; w[35] <= 104; w[36] <= 67; w[37] <= 919; w[38] <= 714; w[39] <= 1103; 
    w[40] <= 123; w[41] <= 689; w[42] <= 588; w[43] <= 1044; w[44] <= 983; w[45] <= 1110; w[46] <= 959; w[47] <= 385; 
    w[48] <= 1013; w[49] <= 575; w[50] <= 315; w[51] <= 724; w[52] <= 156; w[53] <= 677; w[54] <= 802; w[55] <= 1071; 
    w[56] <= 1078; w[57] <= 761; w[58] <= 457; w[59] <= 882; w[60] <= 413; w[61] <= 898; w[62] <= 512; w[63] <= 862;
    
    iw[0] <= 1; iw[1] <= 862; iw[2] <= 512; iw[3] <= 898; iw[4] <= 413; iw[5] <= 882; iw[6] <= 457; iw[7] <= 761; 
    iw[8] <= 1078; iw[9] <= 1071; iw[10] <= 802; iw[11] <= 677; iw[12] <= 156; iw[13] <= 724; iw[14] <= 315; iw[15] <= 575; 
    iw[16] <= 1013; iw[17] <= 385; iw[18] <= 959; iw[19] <= 1110; iw[20] <= 983; iw[21] <= 1044; iw[22] <= 588; iw[23] <= 689; 
    iw[24] <= 123; iw[25] <= 1103; iw[26] <= 714; iw[27] <= 919; iw[28] <= 67; iw[29] <= 104; iw[30] <= 867; iw[31] <= 210; 
    iw[32] <= 1152; iw[33] <= 291; iw[34] <= 641; iw[35] <= 255; iw[36] <= 740; iw[37] <= 271; iw[38] <= 696; iw[39] <= 392; 
    iw[40] <= 75; iw[41] <= 82; iw[42] <= 351; iw[43] <= 476; iw[44] <= 997; iw[45] <= 429; iw[46] <= 838; iw[47] <= 578; 
    iw[48] <= 140; iw[49] <= 768; iw[50] <= 194; iw[51] <= 43; iw[52] <= 170; iw[53] <= 109; iw[54] <= 565; iw[55] <= 464; 
    iw[56] <= 1030; iw[57] <= 50; iw[58] <= 439; iw[59] <= 234; iw[60] <= 1086; iw[61] <= 1049; iw[62] <= 286; iw[63] <= 943;
    
    
end



// for N = 128, p = 769
else if (N == 128)
begin
    //if (q == 769) // alpha = 7
    //begin
        w[0] <= 1; w[1] <= 761; w[2] <= 64; w[3] <= 257; w[4] <= 251; w[5] <= 299; w[6] <= 684; w[7] <= 680; 
        w[8] <= 712; w[9] <= 456; w[10] <= 197; w[11] <= 731; w[12] <= 304; w[13] <= 644; w[14] <= 231; w[15] <= 459; 
        w[16] <= 173; w[17] <= 154; w[18] <= 306; w[19] <= 628; w[20] <= 359; w[21] <= 204; w[22] <= 675; w[23] <= 752; 
        w[24] <= 136; w[25] <= 450; w[26] <= 245; w[27] <= 347; w[28] <= 300; w[29] <= 676; w[30] <= 744; w[31] <= 200; 
        w[32] <= 707; w[33] <= 496; w[34] <= 646; w[35] <= 215; w[36] <= 587; w[37] <= 687; w[38] <= 656; w[39] <= 135; 
        w[40] <= 458; w[41] <= 181; w[42] <= 90; w[43] <= 49; w[44] <= 377; w[45] <= 60; w[46] <= 289; w[47] <= 764; 
        w[48] <= 40; w[49] <= 449; w[50] <= 253; w[51] <= 283; w[52] <= 43; w[53] <= 425; w[54] <= 445; w[55] <= 285; 
        w[56] <= 27; w[57] <= 553; w[58] <= 190; w[59] <= 18; w[60] <= 625; w[61] <= 383; w[62] <= 12; w[63] <= 673; 
        w[64] <= 768; w[65] <= 8; w[66] <= 705; w[67] <= 512; w[68] <= 518; w[69] <= 470; w[70] <= 85; w[71] <= 89; 
        w[72] <= 57; w[73] <= 313; w[74] <= 572; w[75] <= 38; w[76] <= 465; w[77] <= 125; w[78] <= 538; w[79] <= 310; 
        w[80] <= 596; w[81] <= 615; w[82] <= 463; w[83] <= 141; w[84] <= 410; w[85] <= 565; w[86] <= 94; w[87] <= 17; 
        w[88] <= 633; w[89] <= 319; w[90] <= 524; w[91] <= 422; w[92] <= 469; w[93] <= 93; w[94] <= 25; w[95] <= 569; 
        w[96] <= 62; w[97] <= 273; w[98] <= 123; w[99] <= 554; w[100] <= 182; w[101] <= 82; w[102] <= 113; w[103] <= 634; 
        w[104] <= 311; w[105] <= 588; w[106] <= 679; w[107] <= 720; w[108] <= 392; w[109] <= 709; w[110] <= 480; w[111] <= 5; 
        w[112] <= 729; w[113] <= 320; w[114] <= 516; w[115] <= 486; w[116] <= 726; w[117] <= 344; w[118] <= 324; w[119] <= 484; 
        w[120] <= 742; w[121] <= 216; w[122] <= 579; w[123] <= 751; w[124] <= 144; w[125] <= 386; w[126] <= 757; w[127] <= 96;
        
        iw[0] <= 1; iw[1] <= 96; iw[2] <= 757; iw[3] <= 386; iw[4] <= 144; iw[5] <= 751; iw[6] <= 579; iw[7] <= 216; 
        iw[8] <= 742; iw[9] <= 484; iw[10] <= 324; iw[11] <= 344; iw[12] <= 726; iw[13] <= 486; iw[14] <= 516; iw[15] <= 320; 
        iw[16] <= 729; iw[17] <= 5; iw[18] <= 480; iw[19] <= 709; iw[20] <= 392; iw[21] <= 720; iw[22] <= 679; iw[23] <= 588; 
        iw[24] <= 311; iw[25] <= 634; iw[26] <= 113; iw[27] <= 82; iw[28] <= 182; iw[29] <= 554; iw[30] <= 123; iw[31] <= 273; 
        iw[32] <= 62; iw[33] <= 569; iw[34] <= 25; iw[35] <= 93; iw[36] <= 469; iw[37] <= 422; iw[38] <= 524; iw[39] <= 319; 
        iw[40] <= 633; iw[41] <= 17; iw[42] <= 94; iw[43] <= 565; iw[44] <= 410; iw[45] <= 141; iw[46] <= 463; iw[47] <= 615; 
        iw[48] <= 596; iw[49] <= 310; iw[50] <= 538; iw[51] <= 125; iw[52] <= 465; iw[53] <= 38; iw[54] <= 572; iw[55] <= 313; 
        iw[56] <= 57; iw[57] <= 89; iw[58] <= 85; iw[59] <= 470; iw[60] <= 518; iw[61] <= 512; iw[62] <= 705; iw[63] <= 8; 
        iw[64] <= 768; iw[65] <= 673; iw[66] <= 12; iw[67] <= 383; iw[68] <= 625; iw[69] <= 18; iw[70] <= 190; iw[71] <= 553; 
        iw[72] <= 27; iw[73] <= 285; iw[74] <= 445; iw[75] <= 425; iw[76] <= 43; iw[77] <= 283; iw[78] <= 253; iw[79] <= 449; 
        iw[80] <= 40; iw[81] <= 764; iw[82] <= 289; iw[83] <= 60; iw[84] <= 377; iw[85] <= 49; iw[86] <= 90; iw[87] <= 181; 
        iw[88] <= 458; iw[89] <= 135; iw[90] <= 656; iw[91] <= 687; iw[92] <= 587; iw[93] <= 215; iw[94] <= 646; iw[95] <= 496; 
        iw[96] <= 707; iw[97] <= 200; iw[98] <= 744; iw[99] <= 676; iw[100] <= 300; iw[101] <= 347; iw[102] <= 245; iw[103] <= 450; 
        iw[104] <= 136; iw[105] <= 752; iw[106] <= 675; iw[107] <= 204; iw[108] <= 359; iw[109] <= 628; iw[110] <= 306; iw[111] <= 154; 
        iw[112] <= 173; iw[113] <= 459; iw[114] <= 231; iw[115] <= 644; iw[116] <= 304; iw[117] <= 731; iw[118] <= 197; iw[119] <= 456; 
        iw[120] <= 712; iw[121] <= 680; iw[122] <= 684; iw[123] <= 299; iw[124] <= 251; iw[125] <= 257; iw[126] <= 64; iw[127] <= 761;
    //end
    
    //else if (q == 3329)  // alpha = 3
    //begin
        w[0] <= 1; w[1] <= 1915; w[2] <= 1996; w[3] <= 648; w[4] <= 2532; w[5] <= 1756; w[6] <= 450; w[7] <= 2868; 
        w[8] <= 2699; w[9] <= 1977; w[10] <= 882; w[11] <= 1227; w[12] <= 2760; w[13] <= 2277; w[14] <= 2794; w[15] <= 807; 
        w[16] <= 749; w[17] <= 2865; w[18] <= 283; w[19] <= 2647; w[20] <= 2267; w[21] <= 289; w[22] <= 821; w[23] <= 927; 
        w[24] <= 848; w[25] <= 2697; w[26] <= 1476; w[27] <= 219; w[28] <= 3260; w[29] <= 1025; w[30] <= 2094; w[31] <= 1894; 
        w[32] <= 1729; w[33] <= 2009; w[34] <= 2240; w[35] <= 1848; w[36] <= 193; w[37] <= 76; w[38] <= 2393; w[39] <= 1891; 
        w[40] <= 2642; w[41] <= 2679; w[42] <= 296; w[43] <= 910; w[44] <= 1583; w[45] <= 2055; w[46] <= 447; w[47] <= 452; 
        w[48] <= 40; w[49] <= 33; w[50] <= 3273; w[51] <= 2617; w[52] <= 1410; w[53] <= 331; w[54] <= 1355; w[55] <= 1534; 
        w[56] <= 1432; w[57] <= 2513; w[58] <= 1990; w[59] <= 2474; w[60] <= 543; w[61] <= 1197; w[62] <= 1903; w[63] <= 2319; 
        w[64] <= 3328; w[65] <= 1414; w[66] <= 1333; w[67] <= 2681; w[68] <= 797; w[69] <= 1573; w[70] <= 2879; w[71] <= 461; 
        w[72] <= 630; w[73] <= 1352; w[74] <= 2447; w[75] <= 2102; w[76] <= 569; w[77] <= 1052; w[78] <= 535; w[79] <= 2522; 
        w[80] <= 2580; w[81] <= 464; w[82] <= 3046; w[83] <= 682; w[84] <= 1062; w[85] <= 3040; w[86] <= 2508; w[87] <= 2402; 
        w[88] <= 2481; w[89] <= 632; w[90] <= 1853; w[91] <= 3110; w[92] <= 69; w[93] <= 2304; w[94] <= 1235; w[95] <= 1435; 
        w[96] <= 1600; w[97] <= 1320; w[98] <= 1089; w[99] <= 1481; w[100] <= 3136; w[101] <= 3253; w[102] <= 936; w[103] <= 1438; 
        w[104] <= 687; w[105] <= 650; w[106] <= 3033; w[107] <= 2419; w[108] <= 1746; w[109] <= 1274; w[110] <= 2882; w[111] <= 2877; 
        w[112] <= 3289; w[113] <= 3296; w[114] <= 56; w[115] <= 712; w[116] <= 1919; w[117] <= 2998; w[118] <= 1974; w[119] <= 1795; 
        w[120] <= 1897; w[121] <= 816; w[122] <= 1339; w[123] <= 855; w[124] <= 2786; w[125] <= 2132; w[126] <= 1426; w[127] <= 1010;
        
        iw[0] <= 1; iw[1] <= 1010; iw[2] <= 1426; iw[3] <= 2132; iw[4] <= 2786; iw[5] <= 855; iw[6] <= 1339; iw[7] <= 816; 
        iw[8] <= 1897; iw[9] <= 1795; iw[10] <= 1974; iw[11] <= 2998; iw[12] <= 1919; iw[13] <= 712; iw[14] <= 56; iw[15] <= 3296; 
        iw[16] <= 3289; iw[17] <= 2877; iw[18] <= 2882; iw[19] <= 1274; iw[20] <= 1746; iw[21] <= 2419; iw[22] <= 3033; iw[23] <= 650; 
        iw[24] <= 687; iw[25] <= 1438; iw[26] <= 936; iw[27] <= 3253; iw[28] <= 3136; iw[29] <= 1481; iw[30] <= 1089; iw[31] <= 1320; 
        iw[32] <= 1600; iw[33] <= 1435; iw[34] <= 1235; iw[35] <= 2304; iw[36] <= 69; iw[37] <= 3110; iw[38] <= 1853; iw[39] <= 632; 
        iw[40] <= 2481; iw[41] <= 2402; iw[42] <= 2508; iw[43] <= 3040; iw[44] <= 1062; iw[45] <= 682; iw[46] <= 3046; iw[47] <= 464; 
        iw[48] <= 2580; iw[49] <= 2522; iw[50] <= 535; iw[51] <= 1052; iw[52] <= 569; iw[53] <= 2102; iw[54] <= 2447; iw[55] <= 1352; 
        iw[56] <= 630; iw[57] <= 461; iw[58] <= 2879; iw[59] <= 1573; iw[60] <= 797; iw[61] <= 2681; iw[62] <= 1333; iw[63] <= 1414; 
        iw[64] <= 3328; iw[65] <= 2319; iw[66] <= 1903; iw[67] <= 1197; iw[68] <= 543; iw[69] <= 2474; iw[70] <= 1990; iw[71] <= 2513; 
        iw[72] <= 1432; iw[73] <= 1534; iw[74] <= 1355; iw[75] <= 331; iw[76] <= 1410; iw[77] <= 2617; iw[78] <= 3273; iw[79] <= 33; 
        iw[80] <= 40; iw[81] <= 452; iw[82] <= 447; iw[83] <= 2055; iw[84] <= 1583; iw[85] <= 910; iw[86] <= 296; iw[87] <= 2679; 
        iw[88] <= 2642; iw[89] <= 1891; iw[90] <= 2393; iw[91] <= 76; iw[92] <= 193; iw[93] <= 1848; iw[94] <= 2240; iw[95] <= 2009; 
        iw[96] <= 1729; iw[97] <= 1894; iw[98] <= 2094; iw[99] <= 1025; iw[100] <= 3260; iw[101] <= 219; iw[102] <= 1476; iw[103] <= 2697; 
        iw[104] <= 848; iw[105] <= 927; iw[106] <= 821; iw[107] <= 289; iw[108] <= 2267; iw[109] <= 2647; iw[110] <= 283; iw[111] <= 2865; 
        iw[112] <= 749; iw[113] <= 807; iw[114] <= 2794; iw[115] <= 2277; iw[116] <= 2760; iw[117] <= 1227; iw[118] <= 882; iw[119] <= 1977; 
        iw[120] <= 2699; iw[121] <= 2868; iw[122] <= 450; iw[123] <= 1756; iw[124] <= 2532; iw[125] <= 648; iw[126] <= 1996; iw[127] <= 1915;    
    //end
    
    /*
    else if (p == 9473)
    begin
        
    end
    */
end




// for N = 256, p = 1049089
else if (N == 256)
begin
    // w = 462262 for N = 256, p = 1049089
    w[0] <= 1; w[1] <= 462262; w[2] <= 365501; w[3] <= 390723; w[4] <= 1036830; w[5] <= 308920; w[6] <= 1031449; w[7] <= 267117; 
    w[8] <= 263354; w[9] <= 161010; w[10] <= 136426; w[11] <= 668555; w[12] <= 639256; w[13] <= 563908; w[14] <= 850621; w[15] <= 716612; 
    w[16] <= 55526; w[17] <= 548338; w[18] <= 181821; w[19] <= 124778; w[20] <= 165527; w[21] <= 486770; w[22] <= 370486; w[23] <= 967349; 
    w[24] <= 791722; w[25] <= 953891; w[26] <= 767496; w[27] <= 170665; w[28] <= 451430; w[29] <= 445314; w[30] <= 545777; w[31] <= 750320; 
    w[32] <= 913194; w[33] <= 354830; w[34] <= 409399; w[35] <= 239472; w[36] <= 1032562; w[37] <= 711113; w[38] <= 19435; w[39] <= 712863; 
    w[40] <= 130316; w[41] <= 395323; w[42] <= 938627; w[43] <= 972942; w[44] <= 218703; w[45] <= 526523; w[46] <= 828848; w[47] <= 845952; 
    w[48] <= 391407; w[49] <= 399160; w[50] <= 628422; w[51] <= 768286; w[52] <= 274673; w[53] <= 697745; w[54] <= 684318; w[55] <= 302968; 
    w[56] <= 359383; w[57] <= 615751; w[58] <= 510371; w[59] <= 739437; w[60] <= 497603; w[61] <= 752935; w[62] <= 128707; w[63] <= 419866; 
    w[64] <= 337358; w[65] <= 703946; w[66] <= 10743; w[67] <= 742429; w[68] <= 886205; w[69] <= 132100; w[70] <= 486777; w[71] <= 459053; 
    w[72] <= 378589; w[73] <= 379516; w[74] <= 868078; w[75] <= 831758; w[76] <= 47185; w[77] <= 223071; w[78] <= 190614; w[79] <= 623758; 
    w[80] <= 656213; w[81] <= 347634; w[82] <= 633266; w[83] <= 160399; w[84] <= 948374; w[85] <= 803401; w[86] <= 50706; w[87] <= 710534; 
    w[88] <= 936521; w[89] <= 1003762; w[90] <= 504923; w[91] <= 149661; w[92] <= 419077; w[93] <= 695612; w[94] <= 823132; w[95] <= 162462; 
    w[96] <= 972979; w[97] <= 536973; w[98] <= 411903; w[99] <= 598353; w[100] <= 392369; w[101] <= 281468; w[102] <= 795569; w[103] <= 20861; 
    w[104] <= 21494; w[105] <= 986598; w[106] <= 500062; w[107] <= 242717; w[108] <= 875482; w[109] <= 242199; w[110] <= 616058; w[111] <= 797790; 
    w[112] <= 695721; w[113] <= 853418; w[114] <= 136689; w[115] <= 549137; w[116] <= 249831; w[117] <= 513335; w[118] <= 773771; w[119] <= 133630; 
    w[120] <= 661651; w[121] <= 511146; w[122] <= 204049; w[123] <= 506848; w[124] <= 376539; w[125] <= 69783; w[126] <= 640574; w[127] <= 304515; 
    w[128] <= 1049088; w[129] <= 586827; w[130] <= 683588; w[131] <= 658366; w[132] <= 12259; w[133] <= 740169; w[134] <= 17640; w[135] <= 781972; 
    w[136] <= 785735; w[137] <= 888079; w[138] <= 912663; w[139] <= 380534; w[140] <= 409833; w[141] <= 485181; w[142] <= 198468; w[143] <= 332477; 
    w[144] <= 993563; w[145] <= 500751; w[146] <= 867268; w[147] <= 924311; w[148] <= 883562; w[149] <= 562319; w[150] <= 678603; w[151] <= 81740; 
    w[152] <= 257367; w[153] <= 95198; w[154] <= 281593; w[155] <= 878424; w[156] <= 597659; w[157] <= 603775; w[158] <= 503312; w[159] <= 298769; 
    w[160] <= 135895; w[161] <= 694259; w[162] <= 639690; w[163] <= 809617; w[164] <= 16527; w[165] <= 337976; w[166] <= 1029654; w[167] <= 336226; 
    w[168] <= 918773; w[169] <= 653766; w[170] <= 110462; w[171] <= 76147; w[172] <= 830386; w[173] <= 522566; w[174] <= 220241; w[175] <= 203137; 
    w[176] <= 657682; w[177] <= 649929; w[178] <= 420667; w[179] <= 280803; w[180] <= 774416; w[181] <= 351344; w[182] <= 364771; w[183] <= 746121; 
    w[184] <= 689706; w[185] <= 433338; w[186] <= 538718; w[187] <= 309652; w[188] <= 551486; w[189] <= 296154; w[190] <= 920382; w[191] <= 629223; 
    w[192] <= 711731; w[193] <= 345143; w[194] <= 1038346; w[195] <= 306660; w[196] <= 162884; w[197] <= 916989; w[198] <= 562312; w[199] <= 590036; 
    w[200] <= 670500; w[201] <= 669573; w[202] <= 181011; w[203] <= 217331; w[204] <= 1001904; w[205] <= 826018; w[206] <= 858475; w[207] <= 425331; 
    w[208] <= 392876; w[209] <= 701455; w[210] <= 415823; w[211] <= 888690; w[212] <= 100715; w[213] <= 245688; w[214] <= 998383; w[215] <= 338555; 
    w[216] <= 112568; w[217] <= 45327; w[218] <= 544166; w[219] <= 899428; w[220] <= 630012; w[221] <= 353477; w[222] <= 225957; w[223] <= 886627; 
    w[224] <= 76110; w[225] <= 512116; w[226] <= 637186; w[227] <= 450736; w[228] <= 656720; w[229] <= 767621; w[230] <= 253520; w[231] <= 1028228; 
    w[232] <= 1027595; w[233] <= 62491; w[234] <= 549027; w[235] <= 806372; w[236] <= 173607; w[237] <= 806890; w[238] <= 433031; w[239] <= 251299; 
    w[240] <= 353368; w[241] <= 195671; w[242] <= 912400; w[243] <= 499952; w[244] <= 799258; w[245] <= 535754; w[246] <= 275318; w[247] <= 915459; 
    w[248] <= 387438; w[249] <= 537943; w[250] <= 845040; w[251] <= 542241; w[252] <= 672550; w[253] <= 979306; w[254] <= 408515; w[255] <= 744574; 
    // w[256] == 1
    
    // iw = 744574 for N = 256, p = 1049089
    iw[0] <= 1; iw[1] <= 744574; iw[2] <= 408515; iw[3] <= 979306; iw[4] <= 672550; iw[5] <= 542241; iw[6] <= 845040; iw[7] <= 537943; 
    iw[8] <= 387438; iw[9] <= 915459; iw[10] <= 275318; iw[11] <= 535754; iw[12] <= 799258; iw[13] <= 499952; iw[14] <= 912400; iw[15] <= 195671; 
    iw[16] <= 353368; iw[17] <= 251299; iw[18] <= 433031; iw[19] <= 806890; iw[20] <= 173607; iw[21] <= 806372; iw[22] <= 549027; iw[23] <= 62491; 
    iw[24] <= 1027595; iw[25] <= 1028228; iw[26] <= 253520; iw[27] <= 767621; iw[28] <= 656720; iw[29] <= 450736; iw[30] <= 637186; iw[31] <= 512116; 
    iw[32] <= 76110; iw[33] <= 886627; iw[34] <= 225957; iw[35] <= 353477; iw[36] <= 630012; iw[37] <= 899428; iw[38] <= 544166; iw[39] <= 45327; 
    iw[40] <= 112568; iw[41] <= 338555; iw[42] <= 998383; iw[43] <= 245688; iw[44] <= 100715; iw[45] <= 888690; iw[46] <= 415823; iw[47] <= 701455; 
    iw[48] <= 392876; iw[49] <= 425331; iw[50] <= 858475; iw[51] <= 826018; iw[52] <= 1001904; iw[53] <= 217331; iw[54] <= 181011; iw[55] <= 669573; 
    iw[56] <= 670500; iw[57] <= 590036; iw[58] <= 562312; iw[59] <= 916989; iw[60] <= 162884; iw[61] <= 306660; iw[62] <= 1038346; iw[63] <= 345143; 
    iw[64] <= 711731; iw[65] <= 629223; iw[66] <= 920382; iw[67] <= 296154; iw[68] <= 551486; iw[69] <= 309652; iw[70] <= 538718; iw[71] <= 433338; 
    iw[72] <= 689706; iw[73] <= 746121; iw[74] <= 364771; iw[75] <= 351344; iw[76] <= 774416; iw[77] <= 280803; iw[78] <= 420667; iw[79] <= 649929; 
    iw[80] <= 657682; iw[81] <= 203137; iw[82] <= 220241; iw[83] <= 522566; iw[84] <= 830386; iw[85] <= 76147; iw[86] <= 110462; iw[87] <= 653766; 
    iw[88] <= 918773; iw[89] <= 336226; iw[90] <= 1029654; iw[91] <= 337976; iw[92] <= 16527; iw[93] <= 809617; iw[94] <= 639690; iw[95] <= 694259; 
    iw[96] <= 135895; iw[97] <= 298769; iw[98] <= 503312; iw[99] <= 603775; iw[100] <= 597659; iw[101] <= 878424; iw[102] <= 281593; iw[103] <= 95198; 
    iw[104] <= 257367; iw[105] <= 81740; iw[106] <= 678603; iw[107] <= 562319; iw[108] <= 883562; iw[109] <= 924311; iw[110] <= 867268; iw[111] <= 500751; 
    iw[112] <= 993563; iw[113] <= 332477; iw[114] <= 198468; iw[115] <= 485181; iw[116] <= 409833; iw[117] <= 380534; iw[118] <= 912663; iw[119] <= 888079; 
    iw[120] <= 785735; iw[121] <= 781972; iw[122] <= 17640; iw[123] <= 740169; iw[124] <= 12259; iw[125] <= 658366; iw[126] <= 683588; iw[127] <= 586827; 
    iw[128] <= 1049088; iw[129] <= 304515; iw[130] <= 640574; iw[131] <= 69783; iw[132] <= 376539; iw[133] <= 506848; iw[134] <= 204049; iw[135] <= 511146; 
    iw[136] <= 661651; iw[137] <= 133630; iw[138] <= 773771; iw[139] <= 513335; iw[140] <= 249831; iw[141] <= 549137; iw[142] <= 136689; iw[143] <= 853418; 
    iw[144] <= 695721; iw[145] <= 797790; iw[146] <= 616058; iw[147] <= 242199; iw[148] <= 875482; iw[149] <= 242717; iw[150] <= 500062; iw[151] <= 986598; 
    iw[152] <= 21494; iw[153] <= 20861; iw[154] <= 795569; iw[155] <= 281468; iw[156] <= 392369; iw[157] <= 598353; iw[158] <= 411903; iw[159] <= 536973; 
    iw[160] <= 972979; iw[161] <= 162462; iw[162] <= 823132; iw[163] <= 695612; iw[164] <= 419077; iw[165] <= 149661; iw[166] <= 504923; iw[167] <= 1003762; 
    iw[168] <= 936521; iw[169] <= 710534; iw[170] <= 50706; iw[171] <= 803401; iw[172] <= 948374; iw[173] <= 160399; iw[174] <= 633266; iw[175] <= 347634; 
    iw[176] <= 656213; iw[177] <= 623758; iw[178] <= 190614; iw[179] <= 223071; iw[180] <= 47185; iw[181] <= 831758; iw[182] <= 868078; iw[183] <= 379516; 
    iw[184] <= 378589; iw[185] <= 459053; iw[186] <= 486777; iw[187] <= 132100; iw[188] <= 886205; iw[189] <= 742429; iw[190] <= 10743; iw[191] <= 703946; 
    iw[192] <= 337358; iw[193] <= 419866; iw[194] <= 128707; iw[195] <= 752935; iw[196] <= 497603; iw[197] <= 739437; iw[198] <= 510371; iw[199] <= 615751; 
    iw[200] <= 359383; iw[201] <= 302968; iw[202] <= 684318; iw[203] <= 697745; iw[204] <= 274673; iw[205] <= 768286; iw[206] <= 628422; iw[207] <= 399160; 
    iw[208] <= 391407; iw[209] <= 845952; iw[210] <= 828848; iw[211] <= 526523; iw[212] <= 218703; iw[213] <= 972942; iw[214] <= 938627; iw[215] <= 395323; 
    iw[216] <= 130316; iw[217] <= 712863; iw[218] <= 19435; iw[219] <= 711113; iw[220] <= 1032562; iw[221] <= 239472; iw[222] <= 409399; iw[223] <= 354830; 
    iw[224] <= 913194; iw[225] <= 750320; iw[226] <= 545777; iw[227] <= 445314; iw[228] <= 451430; iw[229] <= 170665; iw[230] <= 767496; iw[231] <= 953891; 
    iw[232] <= 791722; iw[233] <= 967349; iw[234] <= 370486; iw[235] <= 486770; iw[236] <= 165527; iw[237] <= 124778; iw[238] <= 181821; iw[239] <= 548338; 
    iw[240] <= 55526; iw[241] <= 716612; iw[242] <= 850621; iw[243] <= 563908; iw[244] <= 639256; iw[245] <= 668555; iw[246] <= 136426; iw[247] <= 161010; 
    iw[248] <= 263354; iw[249] <= 267117; iw[250] <= 1031449; iw[251] <= 308920; iw[252] <= 1036830; iw[253] <= 390723; iw[254] <= 365501; iw[255] <= 462262; 
    // iw[256] == 1
end

else if (N == 1024)
begin
    // w = 462262 for N = 256, p = 1049089
    w[0] <= 1; w[1] <= 462262; w[2] <= 365501; w[3] <= 390723; w[4] <= 1036830; w[5] <= 308920; w[6] <= 1031449; w[7] <= 267117; 
    w[8] <= 263354; w[9] <= 161010; w[10] <= 136426; w[11] <= 668555; w[12] <= 639256; w[13] <= 563908; w[14] <= 850621; w[15] <= 716612; 
    w[16] <= 55526; w[17] <= 548338; w[18] <= 181821; w[19] <= 124778; w[20] <= 165527; w[21] <= 486770; w[22] <= 370486; w[23] <= 967349; 
    w[24] <= 791722; w[25] <= 953891; w[26] <= 767496; w[27] <= 170665; w[28] <= 451430; w[29] <= 445314; w[30] <= 545777; w[31] <= 750320; 
    w[32] <= 913194; w[33] <= 354830; w[34] <= 409399; w[35] <= 239472; w[36] <= 1032562; w[37] <= 711113; w[38] <= 19435; w[39] <= 712863; 
    w[40] <= 130316; w[41] <= 395323; w[42] <= 938627; w[43] <= 972942; w[44] <= 218703; w[45] <= 526523; w[46] <= 828848; w[47] <= 845952; 
    w[48] <= 391407; w[49] <= 399160; w[50] <= 628422; w[51] <= 768286; w[52] <= 274673; w[53] <= 697745; w[54] <= 684318; w[55] <= 302968; 
    w[56] <= 359383; w[57] <= 615751; w[58] <= 510371; w[59] <= 739437; w[60] <= 497603; w[61] <= 752935; w[62] <= 128707; w[63] <= 419866; 
    w[64] <= 337358; w[65] <= 703946; w[66] <= 10743; w[67] <= 742429; w[68] <= 886205; w[69] <= 132100; w[70] <= 486777; w[71] <= 459053; 
    w[72] <= 378589; w[73] <= 379516; w[74] <= 868078; w[75] <= 831758; w[76] <= 47185; w[77] <= 223071; w[78] <= 190614; w[79] <= 623758; 
    w[80] <= 656213; w[81] <= 347634; w[82] <= 633266; w[83] <= 160399; w[84] <= 948374; w[85] <= 803401; w[86] <= 50706; w[87] <= 710534; 
    w[88] <= 936521; w[89] <= 1003762; w[90] <= 504923; w[91] <= 149661; w[92] <= 419077; w[93] <= 695612; w[94] <= 823132; w[95] <= 162462; 
    w[96] <= 972979; w[97] <= 536973; w[98] <= 411903; w[99] <= 598353; w[100] <= 392369; w[101] <= 281468; w[102] <= 795569; w[103] <= 20861; 
    w[104] <= 21494; w[105] <= 986598; w[106] <= 500062; w[107] <= 242717; w[108] <= 875482; w[109] <= 242199; w[110] <= 616058; w[111] <= 797790; 
    w[112] <= 695721; w[113] <= 853418; w[114] <= 136689; w[115] <= 549137; w[116] <= 249831; w[117] <= 513335; w[118] <= 773771; w[119] <= 133630; 
    w[120] <= 661651; w[121] <= 511146; w[122] <= 204049; w[123] <= 506848; w[124] <= 376539; w[125] <= 69783; w[126] <= 640574; w[127] <= 304515; 
    w[128] <= 1049088; w[129] <= 586827; w[130] <= 683588; w[131] <= 658366; w[132] <= 12259; w[133] <= 740169; w[134] <= 17640; w[135] <= 781972; 
    w[136] <= 785735; w[137] <= 888079; w[138] <= 912663; w[139] <= 380534; w[140] <= 409833; w[141] <= 485181; w[142] <= 198468; w[143] <= 332477; 
    w[144] <= 993563; w[145] <= 500751; w[146] <= 867268; w[147] <= 924311; w[148] <= 883562; w[149] <= 562319; w[150] <= 678603; w[151] <= 81740; 
    w[152] <= 257367; w[153] <= 95198; w[154] <= 281593; w[155] <= 878424; w[156] <= 597659; w[157] <= 603775; w[158] <= 503312; w[159] <= 298769; 
    w[160] <= 135895; w[161] <= 694259; w[162] <= 639690; w[163] <= 809617; w[164] <= 16527; w[165] <= 337976; w[166] <= 1029654; w[167] <= 336226; 
    w[168] <= 918773; w[169] <= 653766; w[170] <= 110462; w[171] <= 76147; w[172] <= 830386; w[173] <= 522566; w[174] <= 220241; w[175] <= 203137; 
    w[176] <= 657682; w[177] <= 649929; w[178] <= 420667; w[179] <= 280803; w[180] <= 774416; w[181] <= 351344; w[182] <= 364771; w[183] <= 746121; 
    w[184] <= 689706; w[185] <= 433338; w[186] <= 538718; w[187] <= 309652; w[188] <= 551486; w[189] <= 296154; w[190] <= 920382; w[191] <= 629223; 
    w[192] <= 711731; w[193] <= 345143; w[194] <= 1038346; w[195] <= 306660; w[196] <= 162884; w[197] <= 916989; w[198] <= 562312; w[199] <= 590036; 
    w[200] <= 670500; w[201] <= 669573; w[202] <= 181011; w[203] <= 217331; w[204] <= 1001904; w[205] <= 826018; w[206] <= 858475; w[207] <= 425331; 
    w[208] <= 392876; w[209] <= 701455; w[210] <= 415823; w[211] <= 888690; w[212] <= 100715; w[213] <= 245688; w[214] <= 998383; w[215] <= 338555; 
    w[216] <= 112568; w[217] <= 45327; w[218] <= 544166; w[219] <= 899428; w[220] <= 630012; w[221] <= 353477; w[222] <= 225957; w[223] <= 886627; 
    w[224] <= 76110; w[225] <= 512116; w[226] <= 637186; w[227] <= 450736; w[228] <= 656720; w[229] <= 767621; w[230] <= 253520; w[231] <= 1028228; 
    w[232] <= 1027595; w[233] <= 62491; w[234] <= 549027; w[235] <= 806372; w[236] <= 173607; w[237] <= 806890; w[238] <= 433031; w[239] <= 251299; 
    w[240] <= 353368; w[241] <= 195671; w[242] <= 912400; w[243] <= 499952; w[244] <= 799258; w[245] <= 535754; w[246] <= 275318; w[247] <= 915459; 
    w[248] <= 387438; w[249] <= 537943; w[250] <= 845040; w[251] <= 542241; w[252] <= 672550; w[253] <= 979306; w[254] <= 408515; w[255] <= 744574; 
    // w[256] == 1
    
    // iw = 744574 for N = 256, p = 1049089
    iw[0] <= 1; iw[1] <= 744574; iw[2] <= 408515; iw[3] <= 979306; iw[4] <= 672550; iw[5] <= 542241; iw[6] <= 845040; iw[7] <= 537943; 
    iw[8] <= 387438; iw[9] <= 915459; iw[10] <= 275318; iw[11] <= 535754; iw[12] <= 799258; iw[13] <= 499952; iw[14] <= 912400; iw[15] <= 195671; 
    iw[16] <= 353368; iw[17] <= 251299; iw[18] <= 433031; iw[19] <= 806890; iw[20] <= 173607; iw[21] <= 806372; iw[22] <= 549027; iw[23] <= 62491; 
    iw[24] <= 1027595; iw[25] <= 1028228; iw[26] <= 253520; iw[27] <= 767621; iw[28] <= 656720; iw[29] <= 450736; iw[30] <= 637186; iw[31] <= 512116; 
    iw[32] <= 76110; iw[33] <= 886627; iw[34] <= 225957; iw[35] <= 353477; iw[36] <= 630012; iw[37] <= 899428; iw[38] <= 544166; iw[39] <= 45327; 
    iw[40] <= 112568; iw[41] <= 338555; iw[42] <= 998383; iw[43] <= 245688; iw[44] <= 100715; iw[45] <= 888690; iw[46] <= 415823; iw[47] <= 701455; 
    iw[48] <= 392876; iw[49] <= 425331; iw[50] <= 858475; iw[51] <= 826018; iw[52] <= 1001904; iw[53] <= 217331; iw[54] <= 181011; iw[55] <= 669573; 
    iw[56] <= 670500; iw[57] <= 590036; iw[58] <= 562312; iw[59] <= 916989; iw[60] <= 162884; iw[61] <= 306660; iw[62] <= 1038346; iw[63] <= 345143; 
    iw[64] <= 711731; iw[65] <= 629223; iw[66] <= 920382; iw[67] <= 296154; iw[68] <= 551486; iw[69] <= 309652; iw[70] <= 538718; iw[71] <= 433338; 
    iw[72] <= 689706; iw[73] <= 746121; iw[74] <= 364771; iw[75] <= 351344; iw[76] <= 774416; iw[77] <= 280803; iw[78] <= 420667; iw[79] <= 649929; 
    iw[80] <= 657682; iw[81] <= 203137; iw[82] <= 220241; iw[83] <= 522566; iw[84] <= 830386; iw[85] <= 76147; iw[86] <= 110462; iw[87] <= 653766; 
    iw[88] <= 918773; iw[89] <= 336226; iw[90] <= 1029654; iw[91] <= 337976; iw[92] <= 16527; iw[93] <= 809617; iw[94] <= 639690; iw[95] <= 694259; 
    iw[96] <= 135895; iw[97] <= 298769; iw[98] <= 503312; iw[99] <= 603775; iw[100] <= 597659; iw[101] <= 878424; iw[102] <= 281593; iw[103] <= 95198; 
    iw[104] <= 257367; iw[105] <= 81740; iw[106] <= 678603; iw[107] <= 562319; iw[108] <= 883562; iw[109] <= 924311; iw[110] <= 867268; iw[111] <= 500751; 
    iw[112] <= 993563; iw[113] <= 332477; iw[114] <= 198468; iw[115] <= 485181; iw[116] <= 409833; iw[117] <= 380534; iw[118] <= 912663; iw[119] <= 888079; 
    iw[120] <= 785735; iw[121] <= 781972; iw[122] <= 17640; iw[123] <= 740169; iw[124] <= 12259; iw[125] <= 658366; iw[126] <= 683588; iw[127] <= 586827; 
    iw[128] <= 1049088; iw[129] <= 304515; iw[130] <= 640574; iw[131] <= 69783; iw[132] <= 376539; iw[133] <= 506848; iw[134] <= 204049; iw[135] <= 511146; 
    iw[136] <= 661651; iw[137] <= 133630; iw[138] <= 773771; iw[139] <= 513335; iw[140] <= 249831; iw[141] <= 549137; iw[142] <= 136689; iw[143] <= 853418; 
    iw[144] <= 695721; iw[145] <= 797790; iw[146] <= 616058; iw[147] <= 242199; iw[148] <= 875482; iw[149] <= 242717; iw[150] <= 500062; iw[151] <= 986598; 
    iw[152] <= 21494; iw[153] <= 20861; iw[154] <= 795569; iw[155] <= 281468; iw[156] <= 392369; iw[157] <= 598353; iw[158] <= 411903; iw[159] <= 536973; 
    iw[160] <= 972979; iw[161] <= 162462; iw[162] <= 823132; iw[163] <= 695612; iw[164] <= 419077; iw[165] <= 149661; iw[166] <= 504923; iw[167] <= 1003762; 
    iw[168] <= 936521; iw[169] <= 710534; iw[170] <= 50706; iw[171] <= 803401; iw[172] <= 948374; iw[173] <= 160399; iw[174] <= 633266; iw[175] <= 347634; 
    iw[176] <= 656213; iw[177] <= 623758; iw[178] <= 190614; iw[179] <= 223071; iw[180] <= 47185; iw[181] <= 831758; iw[182] <= 868078; iw[183] <= 379516; 
    iw[184] <= 378589; iw[185] <= 459053; iw[186] <= 486777; iw[187] <= 132100; iw[188] <= 886205; iw[189] <= 742429; iw[190] <= 10743; iw[191] <= 703946; 
    iw[192] <= 337358; iw[193] <= 419866; iw[194] <= 128707; iw[195] <= 752935; iw[196] <= 497603; iw[197] <= 739437; iw[198] <= 510371; iw[199] <= 615751; 
    iw[200] <= 359383; iw[201] <= 302968; iw[202] <= 684318; iw[203] <= 697745; iw[204] <= 274673; iw[205] <= 768286; iw[206] <= 628422; iw[207] <= 399160; 
    iw[208] <= 391407; iw[209] <= 845952; iw[210] <= 828848; iw[211] <= 526523; iw[212] <= 218703; iw[213] <= 972942; iw[214] <= 938627; iw[215] <= 395323; 
    iw[216] <= 130316; iw[217] <= 712863; iw[218] <= 19435; iw[219] <= 711113; iw[220] <= 1032562; iw[221] <= 239472; iw[222] <= 409399; iw[223] <= 354830; 
    iw[224] <= 913194; iw[225] <= 750320; iw[226] <= 545777; iw[227] <= 445314; iw[228] <= 451430; iw[229] <= 170665; iw[230] <= 767496; iw[231] <= 953891; 
    iw[232] <= 791722; iw[233] <= 967349; iw[234] <= 370486; iw[235] <= 486770; iw[236] <= 165527; iw[237] <= 124778; iw[238] <= 181821; iw[239] <= 548338; 
    iw[240] <= 55526; iw[241] <= 716612; iw[242] <= 850621; iw[243] <= 563908; iw[244] <= 639256; iw[245] <= 668555; iw[246] <= 136426; iw[247] <= 161010; 
    iw[248] <= 263354; iw[249] <= 267117; iw[250] <= 1031449; iw[251] <= 308920; iw[252] <= 1036830; iw[253] <= 390723; iw[254] <= 365501; iw[255] <= 462262; 
    // iw[256] == 1
end




